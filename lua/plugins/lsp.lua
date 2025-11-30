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

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

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
        --                         enableForWorkspaceTypeScriptVersions = true,
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

        -- 4. Enable Servers
        vim.lsp.enable({ "intelephense", "pyright", "gopls", "ts_ls", "vue_ls" })

        -- 5. Keymaps
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
            callback = function(ev)
                local bufnr = ev.buf
                local nmap = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, noremap = true, silent = true, desc = "LSP: " .. (desc or "") })
                end

                nmap("gD", vim.lsp.buf.definition, "跳转到定义 (gD)")
                nmap("go", require("telescope.builtin").lsp_definitions, "跳转到定义 (Telescope)")
                nmap("gr", require("telescope.builtin").lsp_references, "查看引用")
                nmap("gk", vim.lsp.buf.hover, "显示文档")
                nmap("<leader>ca", vim.lsp.buf.code_action, "代码操作")
                nmap("<leader>rn", vim.lsp.buf.rename, "重命名")
                nmap("<leader>do", vim.diagnostic.open_float, "打开诊断")

                -- Format command
                vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(opts)
                    vim.lsp.buf.format({ async = true })
                end, { desc = "Format current buffer" })
                vim.keymap.set({ 'n', 'v' }, '<leader>F', "<Cmd>Format<CR>", { buffer = bufnr, noremap = true, silent = true, desc = "LSP: Format" })
            end,
        })

        require("lsp-overloads").setup()
        require('fidget').setup()
    end
}
