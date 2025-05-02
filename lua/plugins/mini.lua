return { -- Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
		config = function()
            -- Simple and easy statusline.
            --  You could remove this setup call if you don't like it,
            --  and try some other statusline plugin
            -- require("mini.statusline").setup({ set_vim_settings = false })
            require("mini.comment").setup({
                options = {
                    custom_commentstring = function()
                        return require("ts_context_commentstring.internal").calculate_commentstring()
                            or vim.bo.commentstring
                    end,
                },
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    -- Toggle comment (like `gcip` - comment inner paragraph) for both
                    -- Normal and Visual modes
                    comment = 'gc',

                    -- Toggle comment on current line
                    comment_line = '<Leader>cc',

                    -- Toggle comment on visual selection
                    comment_visual = 'gc',

                    -- Define 'comment' textobject (like `dgc` - delete whole comment block)
                    -- Works also in Visual mode if mapping differs from `comment_visual`
                    textobject = 'gc',
                },
            })
            require("mini.pairs").setup()
            -- require("mini.bracketed").setup()
            require("mini.align").setup({
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    start = '<Leader>a',
                    start_with_preview = 'gA',
                },
            })
            -- vim.keymap.set("n", "<leader>d", function()
            --     require("mini.bufremove").delete(0, false)
            -- end, { desc = "Close buffer" })
            -- vim.keymap.set("n", "<leader>D", function()
            --     require("mini.bufremove").delete(0, true)
            -- end, { desc = "Force close buffer" })
            -- -- ... and there is more!
            --  Check out: https://github.com/echasnovski/mini.nvim

			-- ... and there is more!
			--  Check out: https://github.com/echasnovski/mini.nvim
		end,
	}
