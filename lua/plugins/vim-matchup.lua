return {
    "andymass/vim-matchup",
    config = function()
        -- 1) 关掉 matchup 自带的 matchparen：它每次 CursorMoved 都走 treesitter 解析，
        --    大文件上光标会发飘。只改 g: 变量不够——插件启动时已经把 autocmd 注册上了，
        --    要用它自己的 disable() 才会一起清掉。% 跳转本身不受影响。
        pcall(vim.cmd, "silent! call matchup#matchparen#disable()")

        -- 2) 改用 nvim 自带的 matchparen。
        --    vim-matchup 在 plugin/matchup.vim:40 里 `let g:loaded_matchparen = 1`，
        --    把内置版挡掉了；这里把变量清掉再手动 source 一次。
        --    内置版是 C 的 searchpairpos()，只认 matchpairs 里的单字符括号，
        --    实测大文件约 1.4ms/次，普通文件更低。
        vim.g.loaded_matchparen = nil
        -- 搜索超时上限：默认 300ms，遇到极端不平衡的文件会在移动光标时卡一下，压到 100ms
        vim.g.matchparen_timeout = 100
        vim.g.matchparen_insert_timeout = 50
        vim.cmd("runtime plugin/matchparen.vim")
    end,
}
