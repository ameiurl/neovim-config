return {
	--    {
	--    "zbirenbaum/copilot.lua",
	--    cmd = "Copilot",
	--    build = ':Copilot auth',
	--    event = 'BufReadPost',
	--    opts = {
	--    suggestion = {
	--      auto_trigger = true,
	--      keymap = {
	--        accept = '<C-c>',
	--        accept_word = '<A-Right>',
	--        accept_line = '<A-C-Right>',
	--        next = '<A-]>',
	--        prev = '<A-[>',
	--        dismiss = '<C-]>',
	--      },
	--    },
	--    panel = { enabled = false },
	--    },
	--    config = function(_, opts)
	--    require('copilot').setup(opts)
	--  end,
	-- },
    {
		"github/copilot.vim",
		config = function()
			vim.g.copilot_enabled = true
			vim.g.copilot_no_tab_map = true
			vim.api.nvim_set_keymap('n', '<leader>go', ':Copilot<CR>', { silent = true })
			vim.api.nvim_set_keymap('n', '<leader>ge', ':Copilot enable<CR>', { silent = true })
			vim.api.nvim_set_keymap('n', '<leader>gd', ':Copilot disable<CR>', { silent = true })
			vim.api.nvim_set_keymap('i', '<c-p>', '<Plug>(copilot-suggest)', { noremap = true })
			vim.api.nvim_set_keymap('i', '<c-n>', '<Plug>(copilot-next)', { noremap = true, silent = true })
			-- vim.api.nvim_set_keymap('i', '<c-l>', '<Plug>(copilot-previous)', { noremap = true, silent = true })
			vim.cmd('imap <silent><script><expr> <C-C> copilot#Accept("")')
			vim.cmd([[
			let g:copilot_filetypes = {
	       \ 'TelescopePrompt': v:false,
	     \ }
			]])
		end
	}
}
