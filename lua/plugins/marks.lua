return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  -- opts = {},
    config = function()
        require("marks").setup({
            -- 这里配置快捷键
            mappings = {
                next = "M", -- 跳转下一个标记
                -- prev = "<leader>n", -- 跳转上一个标记
            }
        })
    end,
}
