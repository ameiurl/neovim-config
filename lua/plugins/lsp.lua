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

        -- LSP全局处理程序
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities() or {}
        )

        -- [关键修复 1] 获取 TSDK 路径 (完全不依赖 API，强制使用 Mason 的 TS 5.x)
        local function get_typescript_server_path()
            local data_path = vim.fn.stdpath("data")

            -- 路径 A: Mason 安装的 typescript-language-server 自带的 typescript (通常是最新版)
            local mason_ts = data_path .. "/mason/packages/typescript-language-server/node_modules/typescript/lib"

            if vim.fn.isdirectory(mason_ts) == 1 then
                return mason_ts
            end

            -- 路径 B: 某些情况下 Mason 会单独安装 typescript 包
            local mason_ts_standalone = data_path .. "/mason/packages/typescript/node_modules/typescript/lib"
            if vim.fn.isdirectory(mason_ts_standalone) == 1 then
                return mason_ts_standalone
            end

            -- 调试：如果没有找到 Mason 的 TS，打印警告
            -- 只有当 Mason 的 TS 不存在时，才回退到本地 node_modules (这会导致 Vue2 项目跳转失败)
            local local_ts = vim.fs.find('node_modules/typescript/lib', { path = vim.fn.getcwd(), upward = true, type = 'directory' })[1]
            if local_ts then return local_ts end

            return nil
        end

        -- 1. Mason Setup
        require("mason").setup()

        -- 2. Mason-LSPConfig Setup
        require("mason-lspconfig").setup({
            ensure_installed = { "intelephense", "pyright", "rust_analyzer", "gopls", "ts_ls", "vue_ls" },
            automatic_installation = true,
        })

        -- [关键修复 2] 获取 Vue 插件路径 (完全不依赖 API)
        local data_path = vim.fn.stdpath("data")
        local vue_plugin_path = data_path .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

        -- 兼容旧版路径
        if vim.fn.isdirectory(vue_plugin_path) ~= 1 then
            vue_plugin_path = data_path .. "/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin"
        end

        -- 3. LSP Config Setup
        local simple_servers = { "intelephense", "pyright", "rust_analyzer", "gopls", "vtsls", "vue_ls" }
        for _, server in ipairs(simple_servers) do
            vim.lsp.config(server, { capabilities = capabilities })
        end

        -- ts_ls 配置
        -- vim.lsp.config("ts_ls", {
        --     capabilities = capabilities,
        --     filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        --     init_options = {
        --         plugins = {
        --             {
        --                 name = "@vue/typescript-plugin",
        --                 location = vue_plugin_path,
        --                 languages = { "vue" },
        --             },
        --         },
        --     },
        -- })

        vim.lsp.config("vtsls", {
            capabilities = capabilities,
            settings = {
                vtsls = {
                    tsserver = {
                        globalPlugins = {
                            {
                                name = "@vue/typescript-plugin",
                                location = vue_plugin_path,
                                languages = { "vue" },
                                configNamespace = "typescript",
                            },
                        },
                    },
                },
            },
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        })
        -- vim.lsp.config("vue_ls", {})

        -- vue_ls 配置
        vim.lsp.config("vue_ls", {
            capabilities = capabilities,
            filetypes = { "vue" },
            init_options = {
                vue = {
                    hybridMode = true,
                },
                typescript = {
                    -- 这里会强制让 Vue 使用 Mason 的新版 TS
                    tsdk = get_typescript_server_path(),
                },
            },
        })

        -- 4. Enable Servers
        vim.lsp.enable({ "intelephense", "pyright", "rust_analyzer", "gopls", "vtsls", "vue_ls" })

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
