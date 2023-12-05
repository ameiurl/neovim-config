-- :help options
local options = {
	background     = "dark",                          -- changes how colors are drawn
	backup         = false,                           -- creates a backup file
	clipboard      = "unnamedplus",                   -- uses the system clipboard
	cmdheight      = 1,                               -- space in cmdline for messages
	-- colorcolumn    = "+1",                            -- marks desired rightmost document edge
	completeopt    = { "menuone", "noselect" },       -- cmp stuff
	conceallevel   = 0,                               -- makes `` visible in markdown
	cursorline     = true,                            -- underline the whole line at cursor
	expandtab      = true,                            -- auto turn tabs to spaces
	fileencoding   = "utf-8",                         -- file encoding
	formatoptions  = "n2ljp",                         -- magic!
	guifont        = "BlexMono Nerd Font",            -- font to use in graphical nvim frontends
	hlsearch       = true,                            -- hilight last search query
	ignorecase     = true,                            -- case sensitivity in search
	joinspaces     = true,                            -- Use two spaces when joining sentences
	laststatus     = 2,                               -- global statusline at the bottom of nvim
	list           = false,                           -- 显示space,tabs,newlines,trailing space,wrapped lines等不可见字符
	-- listchars      = "tab:ﬀ ,lead:·,trail:¶",         -- postemptive space example:       
	mouse          = "a",                             -- allows sacrilege
	number         = true,                            -- show the line number in the gutter
	numberwidth    = 4,                               -- width of numberline gutter (default 4)
	pumheight      = 15,                              -- pop up menu height
	-- relativenumber = true,                            -- show line numbers as offset from cursor
	scrolloff      = 7,                               -- top/bottom line margin from cursor
	shiftwidth     = 4,                               -- charcount of "one indentation"
	shortmess      = "a",                             -- how to display messages in the msg line
	showmode       = true,                            -- shows current editing mode
	showtabline    = 1,                               -- 0:never, 1:when many, 2:always
	sidescrolloff  = 8,                               -- horizontal margin from cursor (no wrap)
	signcolumn     = "yes",                           -- always show the sign column
	smartcase      = true,                            -- case-sensitive when search has caps
	smartindent    = true,                            -- hope it doesn't fuck me over
	splitbelow     = true,                            -- hsplit goes down, not up
	splitright     = false,                           -- vsplit goes right, not left
	swapfile       = false,                           -- create a swapfile while editing
	tabstop        = 4,                               -- spaces to insert for a tab with et
	termguicolors  = true,                            -- set term gui colors (well supported)
	--textwidth      = 120,                             -- sets desired document width
	timeoutlen     = 400,                             -- leader timeout in msec
	undofile       = false,                           -- persistent undo file
	-- updatetime     = 200,                             -- faster completion (400ms default)
	wrap           = true,                            -- word-wrap long lines
	writebackup    = false,                           -- when a file is open by other program
	linebreak 	   = true, 							  -- 显示整个单词
	lazyredraw 	   = true, 							  -- should make scrolling faster
	ttyfast 	   = true, 							  -- same as above
	fileencodings  = "ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1",
	helplang       = "cn",
}
-- vim.opt.iskeyword:append "-"   -- add '-' to iskeyword chars
vim.opt.iskeyword:append "$"   -- add '$' to iskeyword chars

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- netrw settings
vim.g.netrw_liststyle = 3     -- tree style listing
vim.g.netrw_browse_split = 4  -- open file in previous window
vim.g.netrw_banner = 0        -- no banner
vim.g.netrw_usetab = 1        -- use netrw-<C-Tab> mapping
vim.g.netrw_wiw = 32          -- window width (cols)
vim.g.shada = "'0f0"          -- what to save in the ShaDa file


vim.cmd [[
	set nofixendofline  "Disable automatic line wrapping at the end of the file

    " highlight yanked text
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup=(vim.fn['hlexists']('HighlightedyankRegion') > 0 and 'HighlightedyankRegion' or 'IncSearch'), timeout=500}

	" 插入模式下用绝对行号, 普通模式下用相对
	autocmd InsertEnter * :set norelativenumber number
	autocmd InsertLeave * :set relativenumber

	" 打开自动定位到最后编辑的位置, 需要确认 .viminfo 当前用户可写
	if has("autocmd")
	  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	endif

	" 回车即选中当前项
	autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>
	autocmd FileType qf nnoremap <buffer> <ESC> :cclose<CR>

	" quickfix高度
	au FileType qf call AdjustWindowHeight(5, 20)
	function! AdjustWindowHeight(minheight, maxheight)
		let l = 1
		let n_lines = 0
		let w_width = winwidth(0)
		while l <= line('$')
			" number to float for division
			let l_len = strlen(getline(l)) + 0.0
			let line_width = l_len/w_width
			let n_lines += float2nr(ceil(line_width))
			let l += 1
		endw
		exe max([min([n_lines, a:maxheight]), a:minheight]) .  "wincmd _"
	endfunction
]]
