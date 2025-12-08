return {
    "saghen/blink.cmp",
    version = "v1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "ameiurl/friendly-snippets",
        -- "giuxtaposition/blink-cmp-copilot",
    },
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

        -- snippets = { preset = "luasnip" },

        sources = {
            -- 顺序：snippets, copilot, lsp, path, buffer
            default = { "snippets", "lsp", "path", "buffer" },
            providers = {
                snippets = {
                    name = "snippets",
                    score_offset = 100,  -- 最高优先级
                },
                -- copilot = {
                --     name = "copilot",
                --     module = "blink-cmp-copilot",
                --     score_offset = 90,   -- 第二优先级
                --     async = true,
                -- },
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
        },

        completion = {
            menu = {
                border = "rounded",
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
                window = { max_height = 40, border = "rounded" },
            },
            ghost_text = { enabled = true },
        },

        signature = {
            enabled = true,
            window = { border = "rounded" },
        },

        appearance = {
            nerd_font_variant = "mono",
        },
    },
}
