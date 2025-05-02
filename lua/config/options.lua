-- :help options
local options = {
	background     = "dark",                          -- changes how colors are drawn
	backup         = false,                           -- creates a backup file
	clipboard      = "unnamedplus",                   -- uses the system clipboard
	cmdheight      = 1,                               -- space in cmdline for messages
	-- colorcolumn    = "+1",                            -- marks desired rightmost document edge
	completeopt    = { "menuone", "noselect" },       -- cmp stuff
	backspace      = { "indent","eol","start" },      -- 
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
	fixendofline   = false,
}
vim.opt.iskeyword:append "$"   -- add '$' to iskeyword chars

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.g.mapleader = ','
vim.g.maplocalleader = ';'
