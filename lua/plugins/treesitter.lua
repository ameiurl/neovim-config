return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = { 
        "nvim-treesitter/playground",
        "nvim-treesitter/nvim-treesitter-context",
        "nvim-treesitter/nvim-treesitter-refactor",
        "nvim-treesitter/nvim-treesitter-textobjects",
        "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
        -- import nvim-treesitter plugin
        local treesitter = require("nvim-treesitter.configs")
        -- configure treesitter
        treesitter.setup({ -- enable syntax highlighting
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
                enable = false,
                keymaps = {
                    init_selection = "<Cr>",
                    node_incremental = "<Cr>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
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
                    swap_next = {
                        ['<Leader>>'] = '@parameter.inner' 
                    },
                    swap_previous = {
                        ['<Leader><'] = '@parameter.inner' 
                    },
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
        })

        require('ts_context_commentstring').setup {
            enable_autocmd = false,
            languages = {
                typescript = '// %s',
            },
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
    end,
}
