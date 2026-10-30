return {
	-- fork 自带 nvim 0.12 修复（user command 的 complete funcref 等）
	"wookayin/wilder.nvim",
	-- pin 到具体 commit，避免个人 fork 的 master 漂移
	commit = "b255fe65ee12bd6bba228b6b60c9803a60f2f347",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local wilder = require('wilder')
		wilder.setup {
			modes = { ':' },
			next_key = '<C-n>',
			previous_key = '<C-p>',
		}
		-- C-k/C-j 浏览命令历史：wild 内先 reject/accept，再走原生 Up/Down
		vim.cmd([[
			cmap <expr> <C-j> wilder#in_context() ? "\<Up>" : "\<C-k>"
			cmap <expr> <C-k> wilder#in_context() ? "\<Down>" : "\<C-j>"
			cmap <expr> <C-p> wilder#in_context() ? "\<Up>" : "\<C-k>"
			cmap <expr> <C-n> wilder#in_context() ? "\<Down>" : "\<C-j>"
			cmap <expr> <C-h> wilder#in_context() ? "\<Left>" : "\<C-h>"
			cmap <expr> <C-l> wilder#in_context() ? "\<Right>" : "\<C-l>"
		]])
		wilder.set_option('renderer', wilder.popupmenu_renderer(
			wilder.popupmenu_palette_theme({
				highlights = {
					border = 'Normal', -- highlight to use for the border
				},
				left = { ' ', wilder.popupmenu_devicons() },
				right = { ' ', wilder.popupmenu_scrollbar() },
				border = 'rounded',
				max_height = '75%',  -- max height of the palette
				min_height = 0,      -- set to the same as 'max_height' for a fixed height window
				prompt_position = 'top', -- 'top' or 'bottom' to set the location of the prompt
				reverse = 0,         -- set to 1 to reverse the order of the list, use in combination with 'prompt_position'
			})
		))
		wilder.set_option('pipeline', {
			wilder.branch(
				wilder.cmdline_pipeline({
					language = 'vim',
					fuzzy = 1,
				}), wilder.search_pipeline()
			),
		})
	end
}
