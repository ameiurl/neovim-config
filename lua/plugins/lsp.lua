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
            dependencies = { "williamboman/mason.nvim" },
        },
        {
            "j-hui/fidget.nvim",
            opts = {
                text = { spinner = "dots" },
                window = { blend = 0 }
            }
        },
    },
    config = function()
        -- 定义诊断图标
        local diagnostic_icons = {
            [vim.diagnostic.severity.ERROR] = { icon = " ", hl = "DiagnosticError" },
            [vim.diagnostic.severity.WARN]  = { icon = " ", hl = "DiagnosticWarn" },
            [vim.diagnostic.severity.INFO]  = { icon = " ", hl = "DiagnosticInfo" },
            [vim.diagnostic.severity.HINT]  = { icon = "", hl = "DiagnosticHint" },
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
            underline = { severity = { min = vim.diagnostic.severity.HINT } }, -- Underline only warnings and errors
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

        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities() or {}
        )

        local function on_attach(client, bufnr)
            -- 你的 on_attach 函数内容
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

        -- 1. 启动 Mason
        require("mason").setup()

        -- 2. 启动 Mason-LSPConfig
        require("mason-lspconfig").setup({
            ensure_installed = {
                "intelephense",
                "pyright",
                "rust_analyzer",
                "gopls",
                "ts_ls",
            },
            automatic_installation = true,

            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({ capabilities = capabilities, on_attach = on_attach })
                end,

                ["ts_ls"] = function()
                    require("lspconfig").ts_ls.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        -- 移除 vue 文件类型，移除插件配置
                        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
                    })
                end,

                ["volar"] = function()
                    require("lspconfig").volar.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
                        init_options = {
                            vue = {
                                -- [[ 核心修改 ]] 关闭混合模式，不再依赖 ts_ls
                                hybridMode = false,
                            },
                            typescript = {
                                -- 依然需要 TSDK 路径来解析 TS 语法
                                tsdk = (function()
                                    local found_ts = vim.fs.find('node_modules/typescript/lib', {
                                        path = vim.fn.getcwd(),
                                        upward = true,
                                        type = 'directory'
                                    })[1]
                                    if found_ts then return found_ts end
                                    return "/home/amei/.nvm/versions/node/v22.21.1/lib/node_modules/typescript/lib"
                                end)()
                            }
                        }
                    })
                end,

            }
        })

        -- Advanced features 保持不变
        require("lsp-overloads").setup()
        require('fidget').setup()
    end
}
