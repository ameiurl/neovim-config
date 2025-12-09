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
                -- border = "rounded",
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
                window = { max_height = 40 },
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
    -- 使用 config 函数来应用高亮配置
    config = function(_, opts)
        -- =========================================================
        --  这里添加 Documentation (文档) 窗口的背景颜色设置
        -- =========================================================

        -- 文档内容：背景 #F1F1F1，文字设为深色以保证可读性
        vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "#565656", fg = "#E9E9E9" })

        -- 文档边框：背景也设为 #F1F1F1 看起来更像一个卡片，或者你可以设为 NONE
        vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { bg = "#565656", fg = "#E9E9E9" })

        -- 文档中的分割线（如果有）
        vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { bg = "#565656", fg = "#E9E9E9" })

        -- 签名帮助提示窗口（通常也可以保持一致）
        vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { bg = "#565656", fg = "#E9E9E9" })
        vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { bg = "#565656", fg = "#E9E9E9" })


        -- 匹配字符的高亮
        vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
        -- 过期/废弃代码的高亮
        vim.api.nvim_set_hl(0, "BlinkCmpLabelDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
        -- 菜单详情文字 (对应 CmpItemMenu)
        vim.api.nvim_set_hl(0, "BlinkCmpLabelDetail", { fg = "#808080", bg = "NONE", italic = true })

        -- 1. 定义你的自定义颜色 (从 nvim-cmp 移植过来的配色)
        -- local fgdark = "#2E3440"
        --
        -- -- 类型图标 (Kind) 的配色
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindField", { fg = fgdark, bg = "#B5585F" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindProperty", { fg = fgdark, bg = "#B5585F" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindEvent", { fg = fgdark, bg = "#B5585F" })
        --
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindText", { fg = fgdark, bg = "#9FBD73" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindEnum", { fg = fgdark, bg = "#9FBD73" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindKeyword", { fg = fgdark, bg = "#9FBD73" })
        --
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindConstant", { fg = fgdark, bg = "#D4BB6C" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindConstructor", { fg = fgdark, bg = "#D4BB6C" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindReference", { fg = fgdark, bg = "#D4BB6C" })
        --
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindFunction", { fg = fgdark, bg = "#A377BF" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindStruct", { fg = fgdark, bg = "#A377BF" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindClass", { fg = fgdark, bg = "#A377BF" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindModule", { fg = fgdark, bg = "#A377BF" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindOperator", { fg = fgdark, bg = "#A377BF" })
        --
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindVariable", { fg = fgdark, bg = "#cccccc" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindFile", { fg = fgdark, bg = "#7E8294" })
        --
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindUnit", { fg = fgdark, bg = "#D4A959" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindSnippet", { fg = fgdark, bg = "#D4A959" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindFolder", { fg = fgdark, bg = "#D4A959" })
        --
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindMethod", { fg = fgdark, bg = "#6C8ED4" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindValue", { fg = fgdark, bg = "#6C8ED4" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindEnumMember", { fg = fgdark, bg = "#6C8ED4" })
        --
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindInterface", { fg = fgdark, bg = "#58B5A8" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindColor", { fg = fgdark, bg = "#58B5A8" })
        -- vim.api.nvim_set_hl(0, "BlinkCmpKindTypeParameter", { fg = fgdark, bg = "#58B5A8" })

        require("blink.cmp").setup(opts)
    end,
}
