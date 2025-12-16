return {
  "rmagatti/auto-session",
  lazy = false,
  keys = {
    { "<leader>wr", "<cmd>AutoSession search<CR>", desc = "Session search" },
    { "<leader>ws", "<cmd>AutoSession save<CR>", desc = "Save session" },
    { "<leader>wa", "<cmd>AutoSession toggle<CR>", desc = "Toggle autosave" },
  },

  -- 【修复步骤 1】在插件启动前，确保 sessionoptions 不包含 'options'
  -- 否则旧的 session 可能会记住 "syntax off" 的状态
  init = function()
    vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
  end,

  opts = {
    -- 【修复步骤 2】这是关键：恢复会话后，强制刷新当前文件
    post_restore_cmds = {
      function()
        -- 延迟 100ms 以避开加载冲突，然后重新加载当前 buffer
        vim.defer_fn(function()
          -- 重新加载当前文件（相当于手动输入 :e）
          -- 这会强制触发 Treesitter 高亮和 LSP 重新挂载
          vim.cmd("edit")

          -- 如果重新加载后光标位置不对，可以加一句 'normal! zz' 居中
        end, 100)
      end
    },

    -- 下面是你原本的配置，保持不变
    session_lens = {
      picker = nil, 
      mappings = {
        delete_session = { "i", "<C-d>" },
        alternate_session = { "i", "<C-s>" },
        copy_session = { "i", "<C-y>" },
      },
      picker_opts = {},
      load_on_setup = true,
    },
  },
}
