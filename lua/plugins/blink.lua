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
        -- 1. 定义你的自定义颜色 (从 nvim-cmp 移植过来的配色)
        local fgdark = "#2E3440"

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

        vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#82AAFF", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })

        vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#808080", bg = "NONE", italic = true })
        vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = fgdark, bg = "#B5585F" })
        vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = fgdark, bg = "#B5585F" })
        vim.api.nvim_set_hl(0, "CmpItemKindEvent", { fg = fgdark, bg = "#B5585F" })

        vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = fgdark, bg = "#9FBD73" })
        vim.api.nvim_set_hl(0, "CmpItemKindEnum", { fg = fgdark, bg = "#9FBD73" })
        vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = fgdark, bg = "#9FBD73" })

        vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = fgdark, bg = "#D4BB6C" })
        vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { fg = fgdark, bg = "#D4BB6C" })
        vim.api.nvim_set_hl(0, "CmpItemKindReference", { fg = fgdark, bg = "#D4BB6C" })

        vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = fgdark, bg = "#A377BF" })
        vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = fgdark, bg = "#A377BF" })
        vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = fgdark, bg = "#A377BF" })
        vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = fgdark, bg = "#A377BF" })
        vim.api.nvim_set_hl(0, "CmpItemKindOperator", { fg = fgdark, bg = "#A377BF" })

        vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = fgdark, bg = "#cccccc" })
        vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = fgdark, bg = "#7E8294" })

        vim.api.nvim_set_hl(0, "CmpItemKindUnit", { fg = fgdark, bg = "#D4A959" })
        vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = fgdark, bg = "#D4A959" })
        vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = fgdark, bg = "#D4A959" })

        vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = fgdark, bg = "#6C8ED4" })
        vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = fgdark, bg = "#6C8ED4" })
        vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { fg = fgdark, bg = "#6C8ED4" })

        vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = fgdark, bg = "#58B5A8" })
        vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = fgdark, bg = "#58B5A8" })
        vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { fg = fgdark, bg = "#58B5A8" })

        -- 2. 启动 blink.cmp
        require("blink.cmp").setup(opts)

        -- 3. [关键步骤] 将 Blink 的高亮组链接到上面定义的 CmpItem 颜色
        -- 这样 Blink 才能识别并应用这些颜色
        vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { link = "CmpItemAbbrMatch" })
        vim.api.nvim_set_hl(0, "BlinkCmpLabelDeprecated", { link = "CmpItemAbbrDeprecated" })

        -- 循环链接所有的 Kind 图标颜色
        local kinds = {
            "Field", "Property", "Event", "Text", "Enum", "Keyword", "Constant", "Constructor",
            "Reference", "Function", "Struct", "Class", "Module", "Operator", "Variable",
            "File", "Unit", "Snippet", "Folder", "Method", "Value", "EnumMember", "Interface",
            "Color", "TypeParameter"
        }
        for _, kind in ipairs(kinds) do
            -- 将 BlinkCmpKindFunction 链接到 CmpItemKindFunction 等等
            vim.api.nvim_set_hl(0, "BlinkCmpKind" .. kind, { link = "CmpItemKind" .. kind })
        end
    end,
}
