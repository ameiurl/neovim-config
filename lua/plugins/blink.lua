return {
    "saghen/blink.cmp",
    version = "v1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            build = "make install_jsregexp",
            dependencies = {
                "ameiurl/friendly-snippets",
            },
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end,
        },
        "giuxtaposition/blink-cmp-copilot",
    },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = "none",
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            ["<C-u>"] = { "scroll_documentation_up", "fallback" },
            ["<C-Space>"] = { "show", "fallback" },
            ["<C-e>"] = { "cancel", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
            ["<Tab>"] = {
                function(cmp)
                    if cmp.is_visible() then
                        return cmp.accept()
                    end
                end,
                "snippet_forward",
                "fallback",
            },
            ["<S-Tab>"] = {
                function(cmp)
                    if cmp.is_visible() then
                        return cmp.select_prev()
                    end
                end,
                "snippet_backward",
                "fallback",
            },
        },

        snippets = { preset = "luasnip" },

        sources = {
            -- 顺序：snippets, copilot, lsp, path, buffer
            default = { "snippets", "copilot", "lsp", "path", "buffer" },
            providers = {
                snippets = {
                    name = "snippets",
                    score_offset = 100,  -- 最高优先级
                },
                copilot = {
                    name = "copilot",
                    module = "blink-cmp-copilot",
                    score_offset = 90,   -- 第二优先级
                    async = true,
                },
                lsp = {
                    name = "lsp",
                    score_offset = 80,   -- 第三优先级
                },
                path = {
                    name = "path",
                    score_offset = 70,   -- 第四优先级
                },
                buffer = {
                    name = "buffer",
                    score_offset = 60,   -- 最低优先级
                },
            },
        },

        cmdline = {
            enabled = true,
            sources = function()
                local type = vim.fn.getcmdtype()
                if type == "/" or type == "?" then
                    return { "buffer" }
                end
                if type == ":" then
                    return { "cmdline", "path" }
                end
                return {}
            end,
        },

        completion = {
            menu = {
                border = "rounded",
                draw = {
                    columns = {
                        { "kind_icon" },
                        { "label", "label_description", gap = 1 },
                        { "source_name" },
                    },
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
                window = { border = "rounded" },
            },
            ghost_text = { enabled = true },
        },

        signature = {
            enabled = true,
            window = { border = "rounded" },
        },

        appearance = {
            nerd_font_variant = "mono",
            kind_icons = {
                Class         = ' ',
                Color         = ' ',
                Constant      = ' ',
                Constructor   = ' ',
                Enum          = ' ',
                EnumMember    = ' ',
                -- Event         =  '',
                Event         = " ",
                Field         = ' ',
                File          = ' ',
                Folder        = ' ',
                Function      = ' ',
                Interface     = ' ',
                Keyword       = ' ',
                Method        = ' ',
                Module        = ' ',
                -- Operator      =  '',
                Operator      = "󰆕 ",
                Property      = ' ',
                Reference     = ' ',
                -- Snippet       =  '﬍',
                Snippet       = " ",
                -- Struct        =  '',
                Struct        = " ",
                Text          = ' ',
                TypeParameter = '𝙏 ',
                Unit          = ' ',
                Value         = ' ',
                Variable      = ' ',
                Copilot       = '',
            }
        },
    },
}
