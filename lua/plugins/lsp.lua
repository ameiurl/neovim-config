return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
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
        local diagnostic_icons = {
            [vim.diagnostic.severity.ERROR] = { icon = " ", hl = "DiagnosticError" },
            [vim.diagnostic.severity.WARN]  = { icon = " ", hl = "DiagnosticWarn" },
            [vim.diagnostic.severity.INFO]  = { icon = " ", hl = "DiagnosticInfo" },
            [vim.diagnostic.severity.HINT]  = { icon = "", hl = "DiagnosticHint" },
        }

        vim.diagnostic.config({
            virtual_text = {
                severity = { min = vim.diagnostic.severity.WARN },
                spacing = 2,
                prefix = "⋮",
                format = function(diagnostic)
                    local icon_entry = diagnostic_icons[diagnostic.severity]
                    if icon_entry then
                        return string.format("%s%s: %s", icon_entry.icon, diagnostic.source, diagnostic.message:gsub("\n", " "))
                    else
                        return string.format("%s: %s", diagnostic.source, diagnostic.message:gsub("\n", " "))
                    end
                end,
            },
            signs = {
                active = true,
                text = {
                    [vim.diagnostic.severity.ERROR] = diagnostic_icons[vim.diagnostic.severity.ERROR].icon,
                    [vim.diagnostic.severity.WARN]  = diagnostic_icons[vim.diagnostic.severity.WARN].icon,
                    [vim.diagnostic.severity.INFO]  = diagnostic_icons[vim.diagnostic.severity.INFO].icon,
                    [vim.diagnostic.severity.HINT]  = diagnostic_icons[vim.diagnostic.severity.HINT].icon,
                },
            },
            update_in_insert = false,
            severity_sort = true,
            underline = { severity = { min = vim.diagnostic.severity.HINT } },
            float = {
                border = "rounded",
                source = "always",
                format = function(diagnostic)
                    return string.format("%s (%s) [%s]", diagnostic.message, diagnostic.source, diagnostic.code or "")
                end
            }
        })

        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities() or {}
        )

        -- 1. Mason Setup
        require("mason").setup()

        -- 2. Mason-LSPConfig Setup
        require("mason-lspconfig").setup({
            ensure_installed = { "intelephense", "pyright", "gopls", "ts_ls", "vue_ls" },
            automatic_installation = true,
        })

        -- 3. LSP Config Setup
        local simple_servers = { "intelephense", "pyright", "gopls" }
        for _, server in ipairs(simple_servers) do
            vim.lsp.config(server, { capabilities = capabilities })
        end

        -- ts_ls 配置
        vim.lsp.config("ts_ls", {
            capabilities = capabilities,
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
            init_options = {
                plugins = {
                    {
                        name = "@vue/typescript-plugin",
                        location = vim.fn.stdpath("data")
                            .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                        languages = { "vue" },
                    },
                },
            },
        })

        -- vim.lsp.config("vtsls", {
        --     capabilities = capabilities,
        --     settings = {
        --         vtsls = {
        --             tsserver = {
        --                 globalPlugins = {
        --                     {
        --                         name = "@vue/typescript-plugin",
        --                         location = vim.fn.stdpath("data")
        --                             .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
        --                         languages = { "vue" },
        --                         configNamespace = "typescript",
        --                     },
        --                 },
        --             },
        --         },
        --     },
        --     filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        -- })

        -- vue_ls 配置
        vim.lsp.config("vue_ls", {
            capabilities = capabilities,
            -- filetypes = { "vue" },
            init_options = {
                vue = {
                    hybridMode = true,
                },
                typescript = {
                    tsdk = vim.fn.stdpath("data")
                        .. "/mason/packages/vue-language-server/node_modules/typescript/lib"
                },
            },
        })

        -- vue_ls 配置
        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        -- enable = false, -- 禁用所有 Lua 诊断（不推荐）
                        -- 或只禁用全局变量检查
                        disable = { 'undefined-global' },
                    },
                },
            },
        })

        -- 4. Enable Servers
        vim.lsp.enable({ "intelephense", "pyright", "gopls", "ts_ls", "vue_ls" })

        -- 5. Keymaps
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(ev)
                local b = ev.buf
                local o = { buffer = b, silent = true }

                -- vim.keymap.set("n", "<leader>e", vim.diagnostic.goto_next, o)
                vim.keymap.set("n", "gk", vim.lsp.buf.hover, o)
                vim.keymap.set("n", "go", "<cmd>FzfLua lsp_definitions<CR>", o)
                -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
                vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<CR>", o)
                -- vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
                vim.keymap.set({ "n", "v" }, "<A-enter>", vim.lsp.buf.code_action, o)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
                vim.keymap.set({ "n", "v" }, "<leader>F", function()
                    vim.lsp.buf.format({ async = false })
                end, o)
            end,
        })

        require("lsp-overloads").setup()
        require('fidget').setup()
    end
}
