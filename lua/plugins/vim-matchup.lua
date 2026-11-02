return {
    "andymass/vim-matchup",
    config = function()
        -- 关掉“光标移动时自动高亮配对符”：它每次 CursorMoved 都要重新解析，
        -- 大文件上光标会发飘。% 跳转本身不受影响。
        -- 只改 g: 变量不够——插件启动时已经把 autocmd 注册上了（实测 13 条），
        -- 要用它自己的 disable() 才会一起清掉。
        pcall(vim.cmd, "silent! call matchup#matchparen#disable()")
    end,
}
