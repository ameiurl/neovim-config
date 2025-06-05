vim.keymap.set({ "n", "v", "x" },  "<leader>om", ":SymbolsOutline<CR>")
return {
    "ameiurl/symbols-outline.nvim",
    config = function()
        require("symbols-outline").setup({
            -- 设置符号黑名单，过滤掉不需要显示的类型
            symbol_blacklist = {
                "Variable", "Constant", "Property", "Field", "EnumMember",
                "String", "Number", "Boolean", "Array", "Object", "Key",
                "Null", "Operator", "TypeParameter", "Event"
            },

            -- 可选：设置只显示特定类型的符号（白名单方式）
            -- symbol_whitelist = {"Class", "Function", "Method", "Interface", "Struct", "Enum"},

            -- 基础配置
            position = 'right',
            width = 30,
            auto_preview = false,
            show_numbers = false,
            show_relative_numbers = false,

            -- 关键设置：跳转后自动关闭窗口
            auto_close = true,  -- 添加这一行

            -- 自定义符号图标（可选）
            symbols = {
                Class = { icon = "𝓒", hl = "Type" },
                Function = { icon = "ƒ", hl = "Function" },
                Method = { icon = "", hl = "Method" },
                Interface = { icon = "", hl = "Type" },
                Struct = { icon = "𝓢", hl = "Type" },
                Enum = { icon = "ℰ", hl = "Type" }
            }
        })
    end
}
