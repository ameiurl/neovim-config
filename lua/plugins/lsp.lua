return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
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
            [vim.diagnostic.severity.ERROR] = { icon = " ", hl = "DiagnosticError" },
            [vim.diagnostic.severity.WARN]  = { icon = " ", hl = "DiagnosticWarn" },
            [vim.diagnostic.severity.INFO]  = { icon = " ", hl = "DiagnosticInfo" },
            [vim.diagnostic.severity.HINT]  = { icon = "", hl = "DiagnosticHint" },
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

        local capabilities = require("blink.cmp").get_lsp_capabilities()

        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {"intelephense", "pyright", "gopls", "ts_ls", "vue_ls", "lua_ls" },
            automatic_installation = true,
        })

        -- Simple servers
        local simple_servers = { "intelephense", "pyright", "gopls" }
        for _, server in ipairs(simple_servers) do
            vim.lsp.config(server, { capabilities = capabilities })
        end

        -- TypeScript/JavaScript (不处理 Vue)
        vim.lsp.config("ts_ls", {
            capabilities = capabilities,
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
        })

        -- Vue (Takeover 模式)
        vim.lsp.config("volar", {  -- 或 "vue_ls"，根据你系统中的名称
            capabilities = capabilities,
            filetypes = { "vue" },
            init_options = {
                vue = {
                    hybridMode = false,
                },
                typescript = {
                    tsdk = vim.fn.stdpath("data")
                        .. "/mason/packages/vue-language-server/node_modules/typescript/lib"
                },
            },
        })

        -- Lua
        vim.lsp.config("lua_ls", {
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    telemetry = { enable = false },
                },
            },
        })

        -- Keymaps
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(ev)
                local b = ev.buf
                local o = { buffer = b, silent = true }

                vim.keymap.set("n", "gk", vim.lsp.buf.hover, o)
                vim.keymap.set("n", "go", "<cmd>FzfLua lsp_definitions<CR>", o)
                vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<CR>", o)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
                vim.keymap.set({ "n", "v" }, "<A-enter>", vim.lsp.buf.code_action, o)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
                vim.keymap.set({ "n", "v" }, "<leader>F", function()
                    vim.lsp.buf.format({ async = false })
                end, o)
            end,
        })
    end
}
