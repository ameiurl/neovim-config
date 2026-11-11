-- Utility functions
local function map(mode, lhs, rhs, opts)
	opts = opts or {}
	opts = vim.tbl_extend('keep', opts, { remap = false, silent = true })
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- Normal -----------------------------------------------------------------------------
-- Better window navigation
-- <C-h/j/k/l> 改由 vim-tmux-navigator 统一处理（nvim 窗口 <-> tmux pane）
-- 映射定义见 lua/plugins/tmux-navigator.lua

-- Resize splits
map("n", "<A-Up>", ":resize -2<CR>")
map("n", "<A-Down>", ":resize +2<CR>")
map("n", "<A-Left>", ":vertical resize -2<CR>")
map("n", "<A-Right>", ":vertical resize +2<CR>")

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

-- Fast scrolling（5 行/次，带 neoscroll 动画；原来直接 5<C-e> 是瞬移）
map('n', '<C-e>', function()
	require("neoscroll").scroll(5, { move_cursor = false, duration = 120 })
end, { desc = 'Smooth scroll 5 lines down' })
map('n', '<C-y>', function()
	require("neoscroll").scroll(-5, { move_cursor = false, duration = 120 })
end, { desc = 'Smooth scroll 5 lines up' })
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

-- 选区逐级扩大（原 vim-expand-region，现改用内置 treesitter 增量选择 an / in）
vim.keymap.set('v', 'v', 'an', { remap = true, silent = true, desc = 'Expand selection' })

-- Overwrite paste
map('x', 'p', [["_dP]])

-- Select Last Copy
map('n', 'gV', [[`[v`] ]])

vim.keymap.set('n', '<leader>y', function()
    -- '%:.' 意思是：获取当前文件名(%)，并将其转换为相对于当前目录的路径( :. )
    local path = vim.fn.expand('%:.')
    vim.fn.setreg('+', path)
    vim.notify('已复制相对路径: ' .. path, vim.log.levels.INFO)
end, { desc = '复制当前文件相对路径' })
vim.keymap.set('n', '<leader>Y', function()
    -- '%:p' 表示文件的绝对路径
    local path = vim.fn.expand('%:p')
    vim.fn.setreg('+', path)  -- 复制到系统剪贴板
    vim.notify('已复制完整路径: ' .. path, vim.log.levels.INFO)
end, { desc = '复制当前文件完整路径' })
