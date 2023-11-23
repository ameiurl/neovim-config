-- Automatically install packer.nvim
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = vim.fn.system {
		'git',
		'clone',
		'--depth',
		'1',
		'https://github.com/wbthomason/packer.nvim',
		install_path,
	}
	print 'Installing packer.nvim; close and reopen Neovim...'
	vim.api.nvim_command [[packadd packer.nvim]]
end

-- Autocommand that resyncs packer whenever you save the plugins.lua file
vim.api.nvim_create_autocmd('BufWritePost', {
	group = vim.api.nvim_create_augroup('packer_user_config', { clear = true }),
	desc = 'Update the plugin list every time you save plugins.lua',
	pattern = vim.fn.stdpath('config') .. '/lua/user/plugins.lua',
	callback = function(opts)
		vim.api.nvim_command('source ' .. opts.file)
		require('packer').sync()
	end,
})

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
	print("Couldn't load 'packer'")
	return
end

-- Let packer use a rounded-border popup window
packer.init {
	display = {
		open_fn = function()
			return require('packer.util').float { border = 'rounded' }
		end
	}
}

local plugins = {
	completion = {
		{ 'hrsh7th/nvim-cmp',                                 -- The completion engine plugin
			commit = nil },
		{ 'hrsh7th/cmp-buffer',                               -- Buffer completion
			commit = nil },
		{ 'hrsh7th/cmp-path',                                 -- Path completion
			commit = nil },
		{ 'hrsh7th/cmp-cmdline',                              -- Command line completion
			commit = nil },
		-- { 'L3MON4D3/LuaSnip',                                 -- Snippet engine
		-- 	commit = nil },
		-- { 'saadparwaiz1/cmp_luasnip',                         -- Snippet completion
		-- 	commit = nil },
		-- { 'rafamadriz/friendly-snippets',                     -- A bunch of snippets
			-- commit = nil },
		-- { 'hrsh7th/cmp-nvim-lua',                             -- Lua support for nvim-cmp
		-- 	commit = nil },
		{ 'hrsh7th/cmp-vsnip',
			commit = nil },
		{ 'hrsh7th/vim-vsnip',
			commit = nil },
	},

	lsp = {
		{ 'neovim/nvim-lspconfig',                            -- Official community LSP configs
			commit = nil },
		{ 'hrsh7th/cmp-nvim-lsp',                             -- LSP support for nvim-cmp
			commit = nil },
		{ 'hrsh7th/cmp-nvim-lsp-signature-help',              -- LSP Signature help
			commit = nil },
		{ 'Issafalcon/lsp-overloads.nvim',                    -- signature overload cycler
			commit = nil },
		{ 'williamboman/mason.nvim',                          -- LSP/DAP/Format/Lint manager
			commit = nil },
		{ 'williamboman/mason-lspconfig.nvim',                -- Setup lspconfig for mason-installed LSPs
			commit = nil },
		-- { 'Hoffs/omnisharp-extended-lsp.nvim',                -- Omnisharp specific bullshit
		-- 	commit = nil },
		-- { 'jose-elias-alvarez/null-ls.nvim',                  -- Null LS
		-- 	commit = nil },
		-- { 'ThePrimeagen/refactoring.nvim',                   -- Refactoring
		-- 	commit = nil },
		-- { 'j-hui/fidget.nvim',                                -- LSP Progress fidget spinner
			-- commit = nil },
	},

	dap = {
		-- { 'mfussenegger/nvim-dap',                            -- DAP
		-- 	commit = nil },
		-- { 'rcarriga/nvim-dap-ui',                             -- DAP UI
		-- 	commit = nil },
		-- { 'theHamsta/nvim-dap-virtual-text',                  -- DAP Virtual Text
		-- 	commit = nil },
		-- { 'nvim-telescope/telescope-dap.nvim',
		-- 	commit = nil },
	},

	quality_of_life = {
		themeing = {
			{ 'shaunsingh/seoul256.nvim',                          -- colorschemes 
                config = function()
  					vim.cmd [[
    					colorscheme seoul256 
	  					hi phpVarSelector    guifg=#FFBFBD              gui=none
                        hi phpStringSingle    guifg=#BCDDBD              gui=none
                        hi phpStringDouble    guifg=#BCDDBD              gui=none
	  					hi phpFunctions    guifg=#e2c792              gui=none
	  					hi phpMethods    guifg=#e2c792              gui=none
	  					hi phpSpecialFunction    guifg=#e2c792              gui=none
	  					hi phpBaselib    guifg=#e2c792              gui=none
	  					hi phpNumber    guifg=#e55561              gui=none
	  					hi phpFloat    guifg=#e55561              gui=none
                        hi htmlTag    guifg=#98BC99              gui=none
                        hi htmlEndTag    guifg=#98BC99              gui=none
                        hi javaScript    guifg=#C8C8C8              gui=none
  					]]
				end,
            },
			{ 'kyazdani42/nvim-web-devicons',                 -- more icons and shit
				commit = nil },
			{ 'norcalli/nvim-colorizer.lua',                  -- Colorize hex color codes
			 	commit = nil },
			{ 'psliwka/vim-smoothie',                		  -- scrolling page effect
				commit = nil },
			{ 'machakann/vim-highlightedyank',                -- copy effect 
				commit = nil,
				config = function()
					vim.g.highlightedyank_highlight_duration = 500
				end,
			},
		},
		editing = {
			-- { 'jlcrochet/vim-razor',                          -- Attempt to edit razor with neovim
			-- 	commit = nil },
			{ 'numToStr/Comment.nvim',                        -- Auto-commenting
				commit = nil },
			{ 'RRethy/vim-illuminate',                        -- Cursor-word highlighter + text objects
				commit = nil },
			{ 'andymass/vim-matchup',                         -- Better % operator (keywords and shit)
				commit = nil,
				event = 'VimEnter',
				config = function()
					vim.g.matchup_matchparen_deferred = 1
					vim.g.matchup_matchparen_offscreen = {}
				end,
			},
			{ 'windwp/nvim-autopairs',                        -- Automagically match punctuation pairs
				commit = nil },
			{ 'iamcco/markdown-preview.nvim',                 -- Markdown previewer in web browser
				commit = nil,
				run = function() vim.fn['mkdp#util#install']() end,
				cmd = 'MarkdownPreview',
				setup = function() vim.g.mkdp_filetypes = {'markdown'} end,
				ft = 'markdown',
				opt = true,
			},
			{ 'terryma/vim-expand-region',  				  -- Select increasingly larger regions of text using the same key combination
				commit = nil },
			{ 'junegunn/vim-easy-align', 					  -- A simple, easy-to-use Vim alignment plugin	
				commit = nil },
			{ 'mg979/vim-visual-multi', 					  -- It's called vim-visual-multi in analogy with visual-block
				commit = nil,
				config = function()
					vim.g.VM_maps = {
						["Find Under"]         = '<C-m>',
						["Find Subword Under"] = '<C-m>',
						["Find Next"]          = '',
						['Find Prev']          = '',
						['Remove Region']      = 'q',
						['Skip Region']        = '<C-n>',
						["Undo"]               = 'l',
						["Redo"]               = '<C-r>',
						["Add Cursor Down"]    = '<A-Down>',
						["Add Cursor Up"]      = '<A-Up>',
					}
				end,
			},
			{ 'hrsh7th/vim-eft',
				commit = nil },
			{ 'brooth/far.vim',
				commit = nil },
		},
		layout = {
    --         { 'lukas-reineke/indent-blankline.nvim',          -- Indentation fanciness
				-- tag = 'v2.20.8',
    --             commit = nil },
			{ 'lewis6991/gitsigns.nvim',                      -- Git Signs
				commit = nil },
			-- { 'petertriho/nvim-scrollbar',                    -- Buffer scroll bar
			-- 	commit = nil, },
			{ 'simrat39/symbols-outline.nvim',                -- Symbols outliner
				commit = nil },
			{ 'akinsho/bufferline.nvim',                      -- Bufferline - Tabs, but buffers!
				commit = nil },
			{ 'moll/vim-bbye',                                -- Buffer deletion done right
				commit = nil },
			{ 'glepnir/galaxyline.nvim',                      -- Sickass statusline
				commit = nil,
				branch = 'main',
				requires = { 'kyazdani42/nvim-web-devicons', opt = true },
			},
			{ 'tpope/vim-fugitive', 						  -- it's the premier Git plugin for Vim
				commit = nil },
			{ 'kshenoy/vim-signature',   					  -- a plugin to place, toggle and display marks
				commit = nil },
			{ 'lambdalisue/suda.vim',
				commit = nil,
				config = function()
					vim.g.suda_smart_edit=1
				end,
			},
		},
	},

	treesitter = {
		{ 'nvim-treesitter/nvim-treesitter',
			commit = nil,
			run = function()
				require('nvim-treesitter.install').update({ with_sync = true })
			end,
		},
		{ 'nvim-treesitter/playground',                       -- TSPlayground to see the AST of a file
			commit = nil },
		{ 'nvim-treesitter/nvim-treesitter-context',          -- Sticky code context
			commit = nil },
		{ 'nvim-treesitter/nvim-treesitter-refactor',
			commit = nil },
		{ 'nvim-treesitter/nvim-treesitter-textobjects',
			commit = nil },
		{ 'JoosepAlviste/nvim-ts-context-commentstring',
			commit = nil },
		-- { 'p00f/nvim-ts-rainbow',                             -- Color-code brackets and parens and shit
		-- 	commit = nil },
	},

	workspace_tools = {
		{ 'kdheepak/lazygit.nvim',                            -- LazyGit
			commit = nil },
		{ 'nvim-telescope/telescope.nvim',                    -- Telescope
			commit = nil },
		{ 'nvim-telescope/telescope-ui-select.nvim',          -- Use telescope for more UI things
			commit = nil },
		{ 'folke/trouble.nvim',                               -- Pretty qickfix list
			commit = nil },
		{ 'kyazdani42/nvim-tree.lua',                         -- NvimTree
			commit = nil,
			requires = { 'kyazdani42/nvim-web-devicons' },
		},
	},
}

-- Install plugins here
return packer.startup(function(use)
	-- Bare necessities
	use 'wbthomason/packer.nvim'    -- Let packer manage itself
	use 'nvim-lua/popup.nvim'       -- Nvim implementation of Vim Popup API
	use 'nvim-lua/plenary.nvim'     -- Useful lua functions used by lots of plugins

	use 'lewis6991/impatient.nvim'  -- cache bytecode plugins for fast startup
	use 'tjdevries/lazy-require.nvim'       -- Plugin lazy load/require

	use(plugins.completion)
	use(plugins.lsp)
	use(plugins.dap)
	use(plugins.quality_of_life.themeing)
	use(plugins.quality_of_life.editing)
	use(plugins.quality_of_life.layout)
	use(plugins.treesitter)
	use(plugins.workspace_tools)

	-- Automatically set configuration after cloning packer.nvim
	-- Keep this at the end
	if PACKER_BOOTSTRAP then
		require('packer').sync()
	end
end)
