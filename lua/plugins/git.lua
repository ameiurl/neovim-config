vim.keymap.set('n', '<leader>gg', [[<Cmd>LazyGit<CR>]])
return {
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            local status_ok, gitsigns = pcall(require, 'gitsigns')
            if not status_ok then
                print("Couldn't load 'gitsigns'")
                return
            end

            local on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, lhs, rhs, opts)
                    opts = opts or {}
                    opts = vim.tbl_extend('force', opts, { buffer = bufnr })
                    vim.keymap.set(mode, lhs, rhs, opts)
                end

                -- Navigation
                map('n', ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, { expr = true, desc = "Gitsigns go to next hunk" })

                map('n', '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, { expr = true, desc = "Gitsigns go to previous hunk" })

                --- Get a callback to bind to a keymap that runs the given function or command
                --- and then schedules a safe call to `nvim-tree.api.tree.reload`
                ---@param cmd string | fun() Function or command to run
                ---@return fun()
                local function reload_nvim_tree_after(cmd)
                    return function()
                        if type(cmd) == "function" then
                            cmd()
                        elseif type(cmd) == "string" then
                            local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
                            vim.api.nvim_feedkeys(keys, 'n', false)
                        end
                        vim.schedule(vim.F.nil_wrap(function() require('nvim-tree.api').tree.reload() end))
                    end
                end

                -- Actions affecting git status of file that may be shown in tree

                map({ 'n', 'v' }, '<leader>gs', reload_nvim_tree_after [[:Gitsigns stage_hunk<CR>]],
                    { desc = "Gitsigns stage hunk" })
                map({ 'n', 'v' }, '<leader>gr', reload_nvim_tree_after [[:Gitsigns reset_hunk<CR>]],
                    { desc = "Gitsigns reset hunk" })
                map('n', '<leader>gS', reload_nvim_tree_after(gs.stage_buffer),    { desc = "Gitsigns stage buffer" })
                map('n', '<leader>gu', reload_nvim_tree_after(gs.undo_stage_hunk), { desc = "Gitsigns undo stage hunk" })
                map('n', '<leader>gR', reload_nvim_tree_after(gs.reset_buffer),    { desc = "Gitsigns reset buffer" })

                -- passive actions that don't affect git status of file

                map('n', '<leader>gb', function() gs.blame_line { full = true, ignore_whitespace = true } end,
                    { desc = "Gitsigns show full blame for cursor line" })
                map('n', '<leader>gB', gs.toggle_current_line_blame,    { desc = "Gitsigns toggle current line blame on hover" })
                map('n', '<leader>gp', gs.preview_hunk,                 { desc = "Gitsigns preview hunk" })
                map('n', '<leader>gd', gs.diffthis,                     { desc = "Gitsigns diff of current buffer" })
                map('n', '<leader>gD', function() gs.diffthis('~') end, { desc = "Gitsigns diff of current buffer against HEAD~" })
                map('n', '<leader>gX', gs.toggle_deleted,               { desc = "Gitsigns toggle show deleted lines" })
                map('n', '<leader>gc', gs.setqflist,                    { desc = "Gitsigns list all hunks in buffer" })
                -- text object
                map({ 'o', 'x' }, 'ic', [[<Cmd>Gitsigns select_hunk<CR>]])
            end

            gitsigns.setup {
                numhl = true,
                current_line_blame = false,
                current_line_blame_opts = {
                    delay = 200,
                    ignore_whitespace = true,
                },
                current_line_blame_formatter = "⋮  <author>, <author_time> - (<abbrev_sha>) <summary>",
                preview_config = { style = 'minimal', border = 'rounded' },

                -- signs = {
                -- 	add          = { hl = 'GitSignsAdd'   , text = '+', numhl = 'GitSignsAddNr'   , linehl = 'GitSignsAddLn'    },
                -- 	change       = { hl = 'GitSignsChange', text = '┃', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
                -- 	delete       = { hl = 'GitSignsDelete', text = '▁', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
                -- 	topdelete    = { hl = 'GitSignsDelete', text = '▔', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
                -- 	changedelete = { hl = 'GitSignsChange', text = '┋', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
                -- 	untracked    = { hl = 'GitSignsAdd'   , text = '', numhl = 'GitSignsAddNr'   , linehl = 'GitSignsAddLn'    },
                -- },

                signs = {
                    add          = {text = '+',},
                    change       = {text = '┃',},
                    delete       = {text = '▁',},
                    topdelete    = {text = '▔',},
                    changedelete = {text = '┋',},
                    untracked    = {text = '',},
                },
                on_attach = on_attach 
            }

            if package.preload.scrollbar then
                require('scrollbar.handlers.gitsigns').setup()
            end

            local aug_gitsigns = vim.api.nvim_create_augroup('AttachGitsigns', { clear = true })
            vim.api.nvim_create_autocmd('BufEnter', {
                group = aug_gitsigns,
                desc = "Attach gitsigns upon opening a buffer",
                pattern = '*',
                callback = function(opts)
                    gitsigns.attach(opts.bufnr)
                end,
            })
        end,
    },
    {
        "tpope/vim-fugitive"
    },
    {
        "kdheepak/lazygit.nvim"
    }
}
