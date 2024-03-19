-- Utility functions
local function map(mode, lhs, rhs, opts)
	opts = opts or {}
	opts = vim.tbl_extend('keep', opts, { remap = false, silent = true })
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- Remap leader key
-- map('', '\\', [[<Nop>]])
vim.g.mapleader = ','
vim.g.maplocalleader = ';'


-- Normal -----------------------------------------------------------------------------
-- Better window navigation
map('n', '<C-h>', [[<C-w>h]])
map('n', '<C-j>', [[<C-w>j]])
map('n', '<C-k>', [[<C-w>k]])
map('n', '<C-l>', [[<C-w>l]])

-- Fast scrolling
map('n', '<C-e>', [[5<C-e>]])
map('n', '<C-y>', [[5<C-y>]])
map('n', 'K', [[<Esc>5<up>]])
map('n', 'J', [[<Esc>5<down>]])

map('n', 'k', [[gk]])
map('n', 'gk', [[k]])
map('n', 'j', [[gj]])
map('n', 'gj', [[j]])

map('n', 'n', [[nzz]])
map('n', 'N', [[Nzz]])
map('n', '*', [[*zz]])
map('n', '#', [[#zz]])
map('n', 'g*', [[g*zz]])

-- Move lines
-- map('n', '<S-j>', [[<Cmd>move .+1<CR>==]])
-- map('n', '<S-k>', [[<Cmd>move .-2<CR>==]])

-- Bbye commands
map('n', '<Leader>q', [[<Cmd>:q<CR>]])
map('n', '<Leader>d', [[<Cmd>Bdelete<CR>]])
map('n', '<C-o>', [[<Cmd>b#<CR>]])
map('n', 'U', [[<C-r>]])
map('n', 'gj', [[J]])
map('n', 'gh', [[/<c-r>=expand("<cword>")<CR><CR>N]])
map('n', '<leader>/', [[:nohls<CR>]])
map('n', '<leader>w', [[:w<CR>]])
map('n', '<leader>sa', [[ggVG]])

-- Window resizing with CTRL-Arrowkey
map('n', '<C-S-Up>'   , [[2<C-w>-]])
map('n', '<C-S-Down>' , [[2<C-w>+]])
map('n', '<C-S-Left>' , [[2<C-w><]])
map('n', '<C-S-Right>', [[2<C-w>>]])

-- Navigate buffers
map('n', '<C-n>', [[<Cmd>bnext<CR>]])
map('n', '<C-p>', [[<Cmd>bprev<CR>]])


-- Visual -----------------------------------------------------------------------------

-- Stay in indent mode
map('v', '<', [[<gv]])
map('v', '>', [[>gv]])

-- Move text up and down
map('v', '<C-j>', [[:move '>+1<CR>gv=gv]])
map('v', '<C-k>', [[:move '<-2<CR>gv=gv]])

-- insert -----------------------------------------------------------------------------
map('i', '<C-h>', [[<Left>]])
map('i', '<C-j>', [[<Down>]])
map('i', '<C-k>', [[<Up>]])
map('i', '<C-l>', [[<Right>]])

-- Overwrite paste
-- map('v', 'p', [["vdp]])
-- map('v', 'P', [["vdP]])
map('x', 'p', [["_dP]])

-- Select Last Copy
map('n', 'gV', [[`[v`] ]])

-- Collimate
-- local function collimate()
-- 	vim.fn.inputsave()
-- 	local delimiter = vim.fn.input("Collimate on: ", '=')
-- 	vim.fn.inputrestore()
-- 	if #delimiter < 1 then
-- 		return
-- 	end
-- 	local cr = vim.api.nvim_replace_termcodes('<cr>', true, false, true)
-- 	delimiter:gsub('[^%d%s]%d*', function(d)
-- 		local l = #d > 1 and (' -l' .. d:sub(2)) or ''
-- 		local ch = d:sub(1,1):gsub('[\'\\"<>&|();#]', function(s) return '\\' .. s end)
-- 		local cmd = 'gv:!column -t ' .. l .. ' -s' .. ch .. ' -o' .. ch .. cr
-- 		vim.api.nvim_feedkeys(cmd, 'n', false)
-- 	end)
-- end
-- vim.api.nvim_create_user_command("Collimate", collimate, { range = '%' })
-- map('x', '<leader>c', [[:Collimate<CR>]])

-- Replace text command
local function replace_all()
	local query = vim.fn.strcharpart(
		vim.fn.getline(vim.fn.line('.')),
		vim.fn.min({
			vim.fn.charcol('.'),
			vim.fn.charcol('v'),
		}) - 1,
		vim.fn.abs(vim.fn.charcol('.') - vim.fn.charcol('v')) + 1
	)

	vim.fn.inputsave()
	local answer = vim.fn.input("Replace text: ", query)
	vim.api.nvim_command(
		'%s/\\V' .. query:gsub('/','\\/') .. '/' .. answer:gsub('/','\\/') .. '/ge'
	)
	vim.fn.inputrestore()
	vim.api.nvim_feedkeys('v', 'n', false)
end
map('x', '<C-r>', replace_all, { desc = "Replace all selected text in buffer" })

-- Terminal ---------------------------------------------------------------------------
-- map('n', '<leader>`', [[<Cmd>botright split+terminal<CR>]])

-- Window switch from terminal
-- map('t', '<C-Esc>', [[<Cmd>stopinsert<CR>]])

-- Plugin keybinds --------------------------------------------------------------------

-- vim-expand-region
map('v', 'v', [[<Plug>(expand_region_expand)]])
map('v', 'v', [[<Plug>(expand_region_expand)]])

-- vim-easy-align
map('n', '<Leader>a', [[<Plug>(EasyAlign)]])
map('v', '<Leader>a', [[<Plug>(EasyAlign)]])

-- vim-eft
map('n', ';', [[<Plug>(eft-repeat)]])
map('x', ';', [[<Plug>(eft-repeat)]])
map('n', 'f', [[<Plug>(eft-f)]])
map('x', 'f', [[<Plug>(eft-f)]])
map('o', 'f', [[<Plug>(eft-f)]])
map('n', 'F', [[<Plug>(eft-F)]])
map('x', 'F', [[<Plug>(eft-F)]])
map('o', 'F', [[<Plug>(eft-F)]])
map('n', 't', [[<Plug>(eft-t)]])
map('x', 't', [[<Plug>(eft-t)]])
map('o', 't', [[<Plug>(eft-t)]])
map('n', 'T', [[<Plug>(eft-T)]])
map('x', 'T', [[<Plug>(eft-T)]])
map('o', 'T', [[<Plug>(eft-T)]])

-- nvim-tree
map('n', '<Tab>', [[<Cmd>NvimTreeToggle<CR>]])
-- map('n', '<leader>e', function()
-- 	if not pcall(function() require('nvim-tree.api').tree.toggle() end) then
-- 		vim.api.nvim_command [[Lex 30]]
-- 	end
-- end, { desc = "Open nvim-tree or :Lexplore if it isn't found" })

vim.g.nvim_tree_width = 45
local g = vim.g

function _G.inc_width_ind()
    g.nvim_tree_width = g.nvim_tree_width + 5
    return g.nvim_tree_width
end

function _G.dec_width_ind()
    g.nvim_tree_width = g.nvim_tree_width - 5
    return g.nvim_tree_width
end

map('n', '<C-Left>', [[<Cmd>exec ':NvimTreeResize ' . v:lua.dec_width_ind()<CR>]])
map('n', '<C-Right>', [[<Cmd>exec ':NvimTreeResize ' . v:lua.inc_width_ind()<CR>]])

-- symbol
map('n', '<leader>e', [[<Cmd>SymbolsOutline<CR>]])

-- telescope
local lazyscope = require('lazy-require').require_on_exported_call('telescope.builtin')
map('n', '<leader>ta', lazyscope.live_grep,                 { desc = "Telescope live-grep all files" })
map('n', '<leader>tw', lazyscope.grep_string,               { desc = "Telescope grep symbol under cursor" })
map('n', '<leader>f',  lazyscope.find_files,                { desc = "Telescope fuzzy-search for files" })
map('n', '<leader>ts', lazyscope.treesitter,                { desc = "Telescope list treesitter symbols in buffer" })
-- map('n', '<leader>qh', lazyscope.quickfixhistory,           { desc = "Telescope list quickfix history" })
map('n', '<leader>th', lazyscope.oldfiles,           		{ desc = "Telescope list history" })
-- map('n', '<leader>rg', lazyscope.current_buffer_fuzzy_find, { desc = "Telescope grep inside current buffer" })
map('n', '<leader>tt', lazyscope.resume,                    { desc = "Telescope resume last session" })
map('n', '<leader>tm', lazyscope.marks,                    	{ desc = "Telescope list marks" })
map('n', '<leader>tg', "<CMD>lua require('telescope.builtin').grep_string { search = 'n '.. vim.fn.expand('<cword>')}<CR>", { desc = "Telescope grep n+ under cursor word" })
map('n', '<leader>tf', "<CMD>lua require('telescope.builtin').grep_string({ search = vim.fn.input('Grep For > ')})<CR>",   { desc = "Telescope list buffer" })
map('n', '<Leader>tb', function()
	if not pcall(function() lazyscope.buffers() end) then
		-- This is the kind of stupid shit I have to go through just to emulate keypresses
		local cmdstr = vim.api.nvim_replace_termcodes(':ls<CR>:b', true, false, true)
		vim.api.nvim_feedkeys(cmdstr, 'n', false)
	end
end, { desc = "List open buffers in telescope, or with :ls if telescope can't be loaded" })
function _G.__telescope_buffers()
    require('telescope.builtin').buffers(
        require('telescope.themes').get_dropdown {
            previewer = false,
            only_cwd = vim.fn.haslocaldir() == 1,
            show_all_buffers = false,
            sort_mru = true,
            ignore_current_buffer = true,
            sorter = require('telescope.sorters').get_substr_matcher(),
            selection_strategy = 'closest',
            path_display = { 'shorten' },
            layout_strategy = 'center',
            winblend = 0,
            layout_config = { width = 70,height = 25 },
            color_devicons = true,
        }
    )
end
map('n', '<leader>b', '<CMD>lua __telescope_buffers()<CR>',                    	{ desc = "Telescope list buffer" })

-- lazyGit
map('n', '<leader>gg', [[<Cmd>LazyGit<CR>]])

-- DAP
-- local lazydap = require('lazy-require').require_on_exported_call 'dap'
-- map('n', '<F5>', lazydap.continue,                { desc = "DAP continue" })
-- map('n', '<F10>', lazydap.step_over,              { desc = "DAP step over" })
-- map('n', '<F11>', lazydap.step_into,              { desc = "DAP step into" })
-- map('n', '<F12>', lazydap.step_out,               { desc = "DAP step out" })
-- map('n', '<localleader>db', lazydap.toggle_breakpoint, { desc = "DAP toggle breakpoint" })
-- map('n', '<localleader>dB', function() lazydap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
-- 	{ desc = "DAP set a breakpoint condition" })
-- map('n', '<localleader>dL', function() lazydap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
-- 	{ desc = "DAP set log point message" })
-- map('n', '<localleader>dR', function() require('dap').repl.open() end, { desc = "DAP open repl" })

local M = {}

M.symbols_outline = {
	close          = { '<Esc>', 'q' },
	goto_location  = '<CR>',
	focus_location = '<Tab>',
	hover_symbol   = '<Space>',
	toggle_preview = 'K',
	rename_symbol  = 'r',
	code_actions   = 'a',
	fold           = 'h',
	unfold         = 'l',
	fold_all       = 'W',
	unfold_all     = 'E',
	fold_reset     = 'R',
}

local bl = require('lazy-require').require_on_exported_call('bufferline')
M.bufferline = {
	['<localleader>bq'] = bl.close_with_pick,
	['<localleader>bb'] = bl.pick_buffer,
	['<[b>']         = function() bl.cycle(-1) end,
	['<]b>']         = function() bl.cycle( 1) end,
	['<Leader>1']      = function() bl.go_to(1, true) end,
	['<Leader>2']      = function() bl.go_to(2, true) end,
	['<Leader>3']      = function() bl.go_to(3, true) end,
	['<Leader>4']      = function() bl.go_to(4, true) end,
	['<Leader>5']      = function() bl.go_to(5, true) end,
	['<Leader>6']      = function() bl.go_to(6, true) end,
	['<Leader>7']      = function() bl.go_to(7, true) end,
	['<Leader>8']      = function() bl.go_to(8, true) end,
	['<Leader>9']      = function() bl.go_to(9, true) end,
	['<Leader>0']      = function() bl.go_to(-1, true) end,
}

M.nvim_tree  = require('user.settings.keymaps.nvim_tree')
M.gitsigns   = require('user.settings.keymaps.gitsigns')
M.lsp_setup  = require('user.settings.keymaps.lsp')
M.telescope  = require('user.settings.keymaps.telescope')

M.indent_blankline = function()
	local zmaps = {
		'zA', 'zC', 'zD', 'zE', 'zM', 'zN', 'zO', 'zR',
		'za', 'zc', 'zd', 'zi', 'zm', 'zn', 'zo', 'zr', 'zv', 'zx',
	}
	for _, lhs in ipairs(zmaps) do
		vim.keymap.set('n', lhs, function()
			vim.api.nvim_feedkeys(lhs, 'n', false)
			vim.schedule(vim.F.nil_wrap(function() require('indent_blankline').refresh() end))
		end, { desc = "Refresh IndentBlankline after fold operation", remap = false, silent = true })
	end
end

return M
