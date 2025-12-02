return {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- 按键懒加载
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
        { "<leader>do", "<cmd>DiffviewOpen<cr>", desc = "Diff Open" },
        { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Diff Close" },
        { "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
        { "<leader>da", "<cmd>DiffviewFileHistory<cr>", desc = "Project History" },
    },

    config = function()
        -- 移除原本这里的 local actions = ... 因为我们暂时不需要自定义内部按键

        require("diffview").setup({
            -- 1. 增强差异高亮
            enhanced_diff_hl = true,
            -- 2. 界面布局配置
            view = {
                merge_tool = {
                    layout = "diff3_mixed",
                    disable_diagnostics = true,
                },
            },
            file_history = {
                layout = "diff2_horizontal",
            },

            -- 3. 关键修改：暂时注释掉或删除 keymaps 部分
            -- Diffview 默认已经自带了 <Tab> 切换文件和 q 退出，
            -- 删除这里可以避免 "got table" 的报错。
            -- keymaps = { ... } 
        })
    end,
}
