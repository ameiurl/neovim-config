local status_ok, ts = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
	print("Couldn't load 'nvim-treesitter.configs'")
	return
end

ts.setup {
	ensure_installed = {
		'javascript',
		'css',
		'html',
		'markdown',
		'php'
	},
	sync_installed = false, -- install languages synchronously (applies to above)
	ignore_installed = { "" }, -- list of parsers to ignore installing
	playground = {
		enable = true,
		disable = {},
		updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
		persist_queries = false -- Whether the query persists across vim sessions
	},
	highlight = {
		enable = false, -- false will disable the whole extension
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
		enable = true,
	},
	indent = {
		enable = true,
		disable = { "html" },
	},

	-- third-party plugins
	rainbow = {
		enable = true,
		extended_mode = true,
		max_file_lines = nil,
	},
	matchup = {
		enable = true,
	},
	refactor = {
		highlight_definitions = { enable = true },
		highlight_current_scope = { enable = false },
		smart_rename = {
			enable = true,
			keymaps = {
				smart_rename = "grr",
			},
		},
		navigation = {
			enable = true,
			keymaps = {
				goto_definition = "gnn",
				list_definitions = "gnl",
				list_definitions_toc = "gO",
				goto_next_usage = '<space>n',
				goto_previous_usage = '<space>N',
			},
		},
	},
	textobjects = {
		enable = true,
		lookahead = true,
		select = {
			enable = true,
			keymaps = {
				['if'] = '@function.inner',
				['af'] = '@function.outer',
				['ac'] = '@class.outer',
				['ic'] = '@class.inner',
			},
		},
		swap = {
			enable = true,
			swap_next = { ['<Leader>>'] = '@parameter.inner' },
			swap_previous = { ['<Leader><'] = '@parameter.inner' },
		},
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				["gf"] = "@function.outer",
				["ga"] = "@parameter.inner"
			},
			goto_previous_start = {
				["gt"] = "@function.outer",
				["gb"] = "@parameter.inner"
			}
		}
	},
	-- context_commentstring = {
	-- 	enable = true,
	-- 	enable_autocmd = false,
	-- },
}

local context_ok, tscontext = pcall(require, 'treesitter-context')
if not context_ok then
	print("Couldn't load 'treesitter-context'")
	return
end

tscontext.setup {
	mode = 'cursor',
	-- separator = '─',
	patterns = {
		lua = {
			'variable_declaration',
			'table_constructor',
		},
		gdscript = {
			'variable_statement',
			'enum_definition',
		},
	},
	exclude_patterns = {  -- This shit isn't fucking working!!!!
		cs = {
			'attribute_list',
			'attribute',
		},
	},
}

require'treesitter-context'.setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}
