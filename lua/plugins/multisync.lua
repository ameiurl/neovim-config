-- 本地插件：右下角 fidget 风格浮窗，实时 tail /home/amei/multi_sync.log
-- 可在下方 setup({ ... }) 中调整 interval_ms / max_lines / max_width 等，见文件头注释
-- return {
--     {
--         dir = vim.fn.stdpath('config') .. '/multisync-status',
--         name = 'multisync-status',
--         event = 'VeryLazy',
--         config = function()
--             require('multisync-status').setup({})
--         end,
--     },
-- }

-- 取消上面的注释即可重新启用；此模块必须返回 table（不能是 nil），否则 lazy.nvim 报错
return {}
