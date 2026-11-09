-- nvim 窗口 / tmux pane 用 <C-h/j/k/l> 无缝切换
-- tmux 侧对应配置见 ~/.config/tmux/tmux.conf 末尾「vim-tmux-navigator」段落
return {
  "christoomey/vim-tmux-navigator",
  -- 纯 vimscript 小插件，直接启动加载，按键零延迟
  lazy = false,
  init = function()
    -- 关掉插件自带的 nnoremap，下面自己定义（带 desc，方便 which-key 提示）
    vim.g.tmux_navigator_no_mappings = 1
    -- 不自动保存（0）；想切 pane 时顺手写盘可改成 1（:update）或 2（:wall 全部）
    vim.g.tmux_navigator_save_on_switch = 0
    -- tmux pane 处于 zoom 状态时只在本 nvim 内导航，不外跳
    vim.g.tmux_navigator_disable_when_zoomed = 1
  end,
  config = function()
    local map = function(lhs, cmd, desc)
      vim.keymap.set("n", lhs, "<Cmd>" .. cmd .. "<CR>", { silent = true, desc = desc })
    end

    map("<C-h>", "TmuxNavigateLeft", "切换到左侧窗口/pane")
    map("<C-j>", "TmuxNavigateDown", "切换到下方窗口/pane")
    map("<C-k>", "TmuxNavigateUp", "切换到上方窗口/pane")
    map("<C-l>", "TmuxNavigateRight", "切换到右侧窗口/pane")
  end,
}
