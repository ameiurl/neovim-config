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
            version = "^1.20.0", -- 明确指定最低版本要求
            opts = {
                automatic_installation = true,
                ensure_installed = {
                    -- "lua_ls",
                    -- "pyright",
                    -- "rust_analyzer",
                    -- "tsserver",
                    -- "gopls",
                    -- "gleam"
                }
            }
        },
        {
            "j-hui/fidget.nvim",
            opts = {
                text = {
                    spinner = "dots"
                }
            }
        },
    },
    config = function()
        -- 定义诊断图标（新方法）
        local diagnostic_icons = {
            [vim.diagnostic.severity.ERROR] = { icon = " ", color = "DiagnosticError" },
            [vim.diagnostic.severity.WARN]  = { icon = " ", color = "DiagnosticWarn" },
            [vim.diagnostic.severity.INFO]  = { icon = " ", color = "DiagnosticInfo" },
            [vim.diagnostic.severity.HINT]  = { icon = " ", color = "DiagnosticHint" },
        }

        -- 诊断全局配置
        vim.diagnostic.config({
            virtual_text = {
                severity = { min = vim.diagnostic.severity.WARN },
                spacing = 2,
                prefix = "⋮",
                format = function(diagnostic)
                    return string.format(
                        "%s %s: %s",
                        diagnostic_icons[vim.diagnostic.severity[diagnostic.severity]],
                        diagnostic.source,
                        diagnostic.message:gsub("\n", " ")
                    )
                end,
            },
            signs = {
                active = true,
                text = {
                    [vim.diagnostic.severity.ERROR] = diagnostic_icons[vim.diagnostic.severity.ERROR].icon,
                    [vim.diagnostic.severity.WARN]  = diagnostic_icons[vim.diagnostic.severity.WARN].icon,
                    [vim.diagnostic.severity.INFO]  = diagnostic_icons[vim.diagnostic.severity.INFO].icon,
                    [vim.diagnostic.severity.HINT]  = diagnostic_icons[vim.diagnostic.severity.HINT].icon,
                }
            },
            update_in_insert = false,  -- 推荐设置为false以获得更好性能
            severity_sort = true,
            underline = { severity = { min = vim.diagnostic.severity.HINT } },
            float = {
                border = "rounded",
                format = function(diagnostic)
                    return string.format(
                        "%s (%s) [%s]",
                        diagnostic.message,
                        diagnostic.source,
                        diagnostic.code or diagnostic.user_data.lsp.code
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

        require("lspconfig.ui.windows").default_options.border = "rounded"

        -- 能力配置
        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities() or {}
        )

        -- 增强能力配置
        capabilities.textDocument = capabilities.textDocument or {}
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true
        }

        -- 通用on_attach配置
        local on_attach = function(client, bufnr)
            if client.supports_method("textDocument/formatting") then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
                    end
                })
            end

            local nmap = function(keys, func, desc)
                vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
            end

            nmap("go", require("telescope.builtin").lsp_definitions, "跳转到定义")
            nmap("gr", require("telescope.builtin").lsp_references, "查看引用")
            nmap("gI", require("telescope.builtin").lsp_implementations, "查看实现")
            nmap("gt", require("telescope.builtin").lsp_type_definitions, "类型定义")
            nmap("K", vim.lsp.buf.hover, "显示文档")
            nmap("<leader>ca", vim.lsp.buf.code_action, "代码操作")
            nmap("<leader>rn", vim.lsp.buf.rename, "重命名")
            nmap("<leader>fs", vim.lsp.buf.document_symbol, "文档符号")
            nmap("<leader>ws", vim.lsp.buf.workspace_symbol, "工作区符号")

            -- 诊断导航
            local diagnostic_goto = function(next, severity)
                return function()
                    local opts = {
                        severity = severity and vim.diagnostic.severity[severity] or nil,
                        wrap = false,
                        float = false,
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

            local function map(mode, lhs, rhs, opts)
                opts = vim.tbl_extend("force", opts or {}, { remap = false, silent = true, buffer = bufnr })
                vim.keymap.set(mode, lhs, rhs, opts)
            end

            -- Formatting commands
            vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(opts)
                local format_opts = { async = true }
                if opts.range > 0 then
                    format_opts.range = {
                        { opts.line1, 0 },
                        { opts.line2, 0 },
                    }
                end
                vim.lsp.buf.format(format_opts)
            end, { range = true })
            map({ 'n', 'v' }, '<leader>F', [[<Cmd>Format<CR>]])

            -- 高级功能
            -- if client.supports_method("textDocument/documentHighlight") then
            --     vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            --         buffer = bufnr,
            --         callback = vim.lsp.buf.document_highlight,
            --     })
            --
            --     vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            --         buffer = bufnr,
            --         callback = vim.lsp.buf.clear_references,
            --     })
            -- end
        end

        -- Mason配置 (更新后的正确配置方式)
        require("mason").setup()
        require("mason-lspconfig").setup() -- 确保先调用基础setup

        -- LSP服务器通用配置
        local lsp_config = require("lspconfig")
        local default_config = {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        -- 服务器特定配置
        local servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false
                        },
                        telemetry = { enable = false }
                    }
                }
            },
            pyright = {
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true
                        }
                    }
                }
            }
        }

        -- 自动配置服务器 (新版兼容写法)
        require("mason-lspconfig").setup_handlers({
            function(server_name)
                local config = servers[server_name] or {}
                config = vim.tbl_deep_extend("force", {}, default_config, config)
                lsp_config[server_name].setup(config)
            end
        })

        -- 高级功能配置
        require("lsp-overloads").setup()
        require('fidget').setup()
    end
}
