-- Utility functions
local function map(mode, lhs, rhs, opts)
	opts = opts or {}
	opts = vim.tbl_extend('keep', opts, { remap = false, silent = true })
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- Normal -----------------------------------------------------------------------------
-- Better window navigation
map('n', '<C-h>', [[<C-w>h]])
map('n', '<C-j>', [[<C-w>j]])
map('n', '<C-k>', [[<C-w>k]])
map('n', '<C-l>', [[<C-w>l]])

-- Window resizing with CTRL-Arrowkey
map('n', '<C-S-Up>'   , [[2<C-w>-]])
map('n', '<C-S-Down>' , [[2<C-w>+]])
map('n', '<C-S-Left>' , [[2<C-w><]])
map('n', '<C-S-Right>', [[2<C-w>>]])

-- insert -----------------------------------------------------------------------------
map('i', '<C-h>', [[<Left>]])
map('i', '<C-j>', [[<Down>]])
map('i', '<C-k>', [[<Up>]])
map('i', '<C-l>', [[<Right>]])

-- better up/down
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

map('n', 'n', [[nzz]])
map('n', 'N', [[Nzz]])
map('n', '*', [[*zz]])
map('n', '#', [[#zz]])
map('n', 'g*', [[g*zz]])

-- Fast scrolling
map('n', '<C-e>', [[5<C-e>]])
map('n', '<C-y>', [[5<C-y>]])
map('n', 'K', [[<Esc>5<up>]])
map('n', 'J', [[<Esc>5<down>]])

-- Bbye commands
map('n', '<Leader>q', [[<Cmd>:q<CR>]])
map('n', '<leader>w', [[:w<CR>]])
map('n', 'U', [[<C-r>]])
map('n', 'gj', [[J]])
map('n', 'gh', [[/<c-r>=expand("<cword>")<CR><CR>N]])
map('n', '<Leader>/', [[:nohls<CR>]])
map('n', '<Leader>sa', [[ggVG<CR>]])

-- Navigate buffers
map('n', '<C-n>', [[<Cmd>bnext<CR>]])
map('n', '<C-p>', [[<Cmd>bprev<CR>]])
map('n', '<C-o>', [[<Cmd>b#<CR>]])

-- Stay in indent mode
map('v', '<', [[<gv]])
map('v', '>', [[>gv]])

-- Overwrite paste
map('x', 'p', [["_dP]])

-- Select Last Copy
map('n', 'gV', [[`[v`] ]])
