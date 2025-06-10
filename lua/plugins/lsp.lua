return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "Issafalcon/lsp-overloads.nvim",
        {
            "williamboman/mason.nvim",
            opts = {
                ui = {
                    border = "rounded",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            }
        },
        {
            "williamboman/mason-lspconfig.nvim",
            version = "^1.20.0", -- You can keep this if you strictly need it
            opts = {
                automatic_installation = true,
                ensure_installed = {
                    "intelephense",
                    "lua_ls",
                    "pyright",
                    "rust_analyzer",
                    "gopls",
                    "volar",
                }
            }
        },
        {
            "j-hui/fidget.nvim",
            opts = {
                text = {
                    spinner = "dots" -- or "moon", "pipe", "line", etc.
                },
                window = {
                    blend = 0, -- Transparency of the Fidget window
                }
            }
        },
    },
    config = function()
        -- 定义诊断图标
        local diagnostic_icons = {
            [vim.diagnostic.severity.ERROR] = { icon = " ", hl = "DiagnosticError" },
            [vim.diagnostic.severity.WARN]  = { icon = " ", hl = "DiagnosticWarn" },
            [vim.diagnostic.severity.INFO]  = { icon = " ", hl = "DiagnosticInfo" },
            [vim.diagnostic.severity.HINT]  = { icon = " ", hl = "DiagnosticHint" },
        }

        -- 诊断全局配置
        vim.diagnostic.config({
            virtual_text = {
                severity = { min = vim.diagnostic.severity.WARN },
                spacing = 2,
                prefix = "⋮", -- You can also use '●' or other symbols
                format = function(diagnostic)
                    local icon_entry = diagnostic_icons[diagnostic.severity]
                    if icon_entry then
                        return string.format(
                            "%s%s: %s",
                            icon_entry.icon,
                            diagnostic.source,
                            diagnostic.message:gsub("\n", " ")
                        )
                    else
                        return string.format(
                            "%s: %s",
                            diagnostic.source,
                            diagnostic.message:gsub("\n", " ")
                        )
                    end
                end,
            },
            signs = {
                active = true, -- This is the default, can be omitted
                text = {
                    [vim.diagnostic.severity.ERROR] = diagnostic_icons[vim.diagnostic.severity.ERROR].icon,
                    [vim.diagnostic.severity.WARN]  = diagnostic_icons[vim.diagnostic.severity.WARN].icon,
                    [vim.diagnostic.severity.INFO]  = diagnostic_icons[vim.diagnostic.severity.INFO].icon,
                    [vim.diagnostic.severity.HINT]  = diagnostic_icons[vim.diagnostic.severity.HINT].icon,
                },
            },
            update_in_insert = false,
            severity_sort = true,
            underline = { severity = { min = vim.diagnostic.severity.WARN } }, -- Underline only warnings and errors
            float = {
                border = "rounded",
                source = "always", -- Or "if_many"
                format = function(diagnostic)
                    return string.format(
                        "%s (%s) [%s]",
                        diagnostic.message,
                        diagnostic.source,
                        diagnostic.code or (diagnostic.user_data and diagnostic.user_data.lsp and diagnostic.user_data.lsp.code) or ""
                    )
                end
            }
        })

        -- LSP全局处理程序
        local lsp_handlers = {
            ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
            ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
        }

        for event, handler in pairs(lsp_handlers) do
            vim.lsp.handlers[event] = handler
        end

        -- 能力配置
        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities() or {}
        )

        -- 通用on_attach配置
        local on_attach = function(client, bufnr)
            local nmap = function(keys, func, desc)
                if desc then
                    desc = "LSP: " .. desc
                end
                vim.keymap.set("n", keys, func, { buffer = bufnr, noremap = true, silent = true, desc = desc })
            end

            nmap("gD", vim.lsp.buf.definition, "跳转到定义 (gD)") -- Alternative to Telescope
            nmap("go", require("telescope.builtin").lsp_definitions, "跳转到定义 (Telescope)")
            nmap("gr", require("telescope.builtin").lsp_references, "查看引用")
            nmap("gI", require("telescope.builtin").lsp_implementations, "查看实现")
            nmap("gt", require("telescope.builtin").lsp_type_definitions, "类型定义")
            nmap("gk", vim.lsp.buf.hover, "显示文档 (K)") -- Standard Neovim keymap for hover
            nmap("gH", vim.lsp.buf.hover, "显示文档 (gH)")
            nmap("<leader>ca", vim.lsp.buf.code_action, "代码操作")
            nmap("<leader>rn", vim.lsp.buf.rename, "重命名")
            nmap("<leader>fs", vim.lsp.buf.document_symbol, "文档符号") -- Consider telescope.builtin.lsp_document_symbols
            nmap("<leader>ws", vim.lsp.buf.workspace_symbol, "工作区符号") -- Consider telescope.builtin.lsp_dynamic_workspace_symbols

            -- 诊断导航
            local diagnostic_goto = function(next, severity_str)
                return function()
                    local severity_val = severity_str and vim.diagnostic.severity[severity_str] or nil
                    local opts = {
                        severity = severity_val,
                        wrap = false, -- Don't wrap around the buffer
                        float = false, -- You can set this to true for a floating window
                    }
                    if next then
                        vim.diagnostic.goto_next(opts)
                    else
                        vim.diagnostic.goto_prev(opts)
                    end
                end
            end

            nmap("]d", diagnostic_goto(true), "下一个诊断")
            nmap("[d", diagnostic_goto(false), "上一个诊断")
            nmap("]e", diagnostic_goto(true, "ERROR"), "下一个错误")
            nmap("[e", diagnostic_goto(false, "ERROR"), "上一个错误")
            nmap("]w", diagnostic_goto(true, "WARN"), "下一个警告")
            nmap("[w", diagnostic_goto(false, "WARN"), "上一个警告")
            nmap("<leader>do", vim.diagnostic.open_float, "打开诊断浮窗") -- Open diagnostics float

            -- Formatting command (remains the same, good)
            vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(opts)
                local format_opts = { async = true, timeout_ms = 5000 } -- Added timeout
                if opts.range > 0 then
                    format_opts.range = {
                        start = { line = opts.line1 - 1, character = 0 }, -- LSP uses 0-based indexing
                        ["end"] = { line = opts.line2, character = 0 },
                    }
                end
                vim.lsp.buf.format(format_opts)
            end, { range = true, desc = "Format current buffer (or selection)" })

            vim.keymap.set({ 'n', 'v' }, '<leader>F', "<Cmd>Format<CR>", { buffer = bufnr, noremap = true, silent = true, desc = "LSP: Format" })
        end

        -- Initialize Mason and Mason-LSPConfig
        require("mason").setup()
        require("mason-lspconfig").setup({
            handlers = {
                -- 默认处理器，用于所有未被特殊处理的LSP
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end,

                ["volar"] = function()
                    -- 构建指向你全局 TypeScript 库的完整路径
                    local tsdk_path = vim.fn.expand("~/.nvm/versions/node/v20.19.2/lib/node_modules/typescript/lib")

                    require("lspconfig").volar.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        filetypes = {"typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json"},
                        init_options = {
                            -- 明确告诉 Volar 在哪里可以找到 TypeScript
                            typescript = {
                                tsdk = tsdk_path
                            },
                            vue = {
                                hybridMode = false
                            }
                        }
                    })
                end,

                -- Example for another server if it needed special setup
                ["lua_ls"] = function ()
                  require("lspconfig").lua_ls.setup({
                    capabilities = capabilities,
                    on_attach = on_attach,
                    settings = {
                      Lua = {
                        diagnostics = { globals = {'vim'} },
                        workspace = { checkThirdParty = false }
                      }
                    }
                  })
                end,
            }
        })

        -- Advanced features
        require("lsp-overloads").setup() -- Make sure this is loaded after lspconfig setups
        require('fidget').setup() -- Fidget setup can usually go here
    end
}
