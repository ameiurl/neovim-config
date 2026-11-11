return {
	"karb94/neoscroll.nvim",
	opts = {
		-- 只接管整屏/半屏滚动；<C-e>/<C-y> 的 5 行快速滚动在 keymaps.lua 里
		-- 用 neoscroll.scroll(±5) 自定义映射，避免被这里的默认映射覆盖成 1 行。
		mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>" },
		hide_cursor = true,             -- 滚动时隐藏光标，视觉更顺
		stop_eof = true,                -- 向下滚到 <EOF> 就停
		respect_scrolloff = false,      -- 不因 scrolloff=7 提前停住
		cursor_scrolls_alone = true,    -- 窗口滚到头后光标仍可继续移动
		easing = "linear",              -- linear 最跟手；想要缓动用 "quadratic"/"sine"
		duration_multiplier = 0.5,      -- 全局时长倍率，0.5 比默认快一倍
		performance_mode = false,       -- 关掉“滚动时取消语法高亮”，避免闪烁
	},
}
