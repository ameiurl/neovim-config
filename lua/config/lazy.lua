local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
    checker = {
        -- 自动检查插件更新默认每小时对 30+ 个仓库跑一遍 git，
        -- 2 核机器上会明显抢资源；需要时手动 :Lazy check
        enabled = false,
        -- get a notification when new updates are found
        notify = false,
    },
    change_detection = {
        -- automatically check for config file changes and reload the ui
        enabled = true,
        -- get a notification when changes are found
        notify = false,
    },
})
