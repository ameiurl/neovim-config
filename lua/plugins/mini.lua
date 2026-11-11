return { -- Collection of various small independent plugins/modules
		"nvim-mini/mini.nvim",
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

            -- Smooth scrolling (replacement for snacks.scroll)
            local animate = require("mini.animate")
            animate.setup({
                cursor = { enable = false },
                scroll = {
                    enable = true,
                    timing = animate.gen_timing.linear({ duration = 200, unit = "total" }),
                },
                resize = { enable = false },
                open = { enable = false },
                close = { enable = false },
            })

            -- Git diff: signs + hunk actions (replaces gitsigns.nvim)
            require("mini.diff").setup({
                view = {
                    style = "sign",
                    signs = { add = "+", change = "~", delete = "_" },
                },
                mappings = {
                    -- `gh` is already used for "search current word" in normal mode
                    apply = "",
                    reset = "",
                    textobject = "gh",
                    -- Only expose the guarded ]c / [c mappings below
                    goto_first = "",
                    goto_prev = "",
                    goto_next = "",
                    goto_last = "",
                },
            })

            local function mini_diff_data()
                local ok, diff = pcall(require, "mini.diff")
                if not ok then return nil end
                return diff.get_buf_data(0)
            end

            local function hunk_range_under_cursor()
                local data = mini_diff_data()
                if not data then return nil end
                local lnum = vim.fn.line(".")
                local hunks = data.hunks or {}

                -- Exact buffer range (also handles "add" and "change" hunks)
                for _, hunk in ipairs(hunks) do
                    local from, to
                    if hunk.buf_count > 0 then
                        from, to = hunk.buf_start, hunk.buf_start + hunk.buf_count - 1
                    else
                        from = math.max(hunk.buf_start, 1)
                        to = from
                    end
                    if lnum >= from and lnum <= to then return from, to end
                end

                -- A "delete" hunk has no buffer lines; accept the line below it too.
                for _, hunk in ipairs(hunks) do
                    if hunk.buf_count == 0 then
                        local from = math.max(hunk.buf_start, 1)
                        if lnum == from + 1 then return from, from end
                    end
                end
            end

            local function do_hunk(action)
                local from, to = hunk_range_under_cursor()
                if not from then
                    vim.notify("No hunk under cursor", vim.log.levels.INFO)
                    return
                end
                require("mini.diff").do_hunks(0, action, { line_start = from, line_end = to })
            end

            local function do_visual_hunks(action)
                local from, to = vim.fn.line("v"), vim.fn.line(".")
                if from > to then from, to = to, from end
                vim.cmd("normal! \27")
                if not mini_diff_data() then
                    vim.notify("Buffer is not under git", vim.log.levels.INFO)
                    return
                end
                require("mini.diff").do_hunks(0, action, { line_start = from, line_end = to })
            end

            vim.keymap.set("n", "<leader>gs", function() do_hunk("apply") end, { desc = "Stage hunk" })
            vim.keymap.set("x", "<leader>gs", function() do_visual_hunks("apply") end, { desc = "Stage hunks" })
            vim.keymap.set("n", "<leader>gr", function() do_hunk("reset") end, { desc = "Reset hunk" })
            vim.keymap.set("x", "<leader>gr", function() do_visual_hunks("reset") end, { desc = "Reset hunks" })

            vim.keymap.set("n", "<leader>gS", function()
                if not mini_diff_data() then
                    vim.notify("Buffer is not under git", vim.log.levels.INFO)
                    return
                end
                require("mini.diff").do_hunks(0, "apply")
            end, { desc = "Stage buffer" })

            vim.keymap.set("n", "<leader>gc", function()
                if not mini_diff_data() then return end
                vim.fn.setqflist(require("mini.diff").export("qf", { scope = "current" }))
            end, { desc = "Hunks to quickfix" })

            vim.keymap.set("n", "<leader>gp", function()
                if not mini_diff_data() then return end
                require("mini.diff").toggle_overlay(0)
            end, { desc = "Toggle diff overlay" })

            local function goto_hunk(direction)
                if vim.wo.diff then
                    vim.cmd("normal! " .. (direction == "next" and "]c" or "[c"))
                    return
                end
                if not mini_diff_data() then return end
                pcall(require("mini.diff").goto_hunk, direction)
            end

            vim.keymap.set("n", "]c", function() goto_hunk("next") end, { desc = "Next hunk" })
            vim.keymap.set("n", "[c", function() goto_hunk("prev") end, { desc = "Previous hunk" })

            -- Keep gitsigns' max_file_length: don't diff huge files
            vim.api.nvim_create_autocmd("BufReadPost", {
                group = vim.api.nvim_create_augroup("mini_diff_large_files", { clear = true }),
                callback = function(args)
                    if vim.api.nvim_buf_line_count(args.buf) <= 5000 then return end
                    vim.b[args.buf].minidiff_disable = true
                    pcall(function() require("mini.diff").disable(args.buf) end)
                end,
            })

            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            --
            -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
            -- - sd'   - [S]urround [D]elete [']quotes
            -- - sr)'  - [S]urround [R]eplace [)] [']
            -- require("mini.surround").setup()

            -- Delete buffer without changing window layout
            require("mini.bufremove").setup()
            vim.keymap.set("n", "<leader>d", function()
                require("mini.bufremove").delete(0, false)
            end, { desc = "Close buffer" })
            vim.keymap.set("n", "<leader>D", function()
                require("mini.bufremove").delete(0, true)
            end, { desc = "Force close buffer" })
            -- -- ... and there is more!
            --  Check out: https://github.com/echasnovski/mini.nvim

			-- ... and there is more!
			--  Check out: https://github.com/echasnovski/mini.nvim
		end,
	}
