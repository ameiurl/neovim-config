return {
    "akinsho/bufferline.nvim",
    config = function ()
        local status_ok, bufferline = pcall(require, 'bufferline')
        if not status_ok then
            print("Couldn't load 'bufferline'")
            return
        end

        local bl = require('bufferline')
        keymaps = {
            ['<localleader>bq'] = bl.close_with_pick,
            ['<localleader>bb'] = bl.pick_buffer,
            ['<[b>']         = function() bl.cycle(-1) end,
            ['<]b>']         = function() bl.cycle( 1) end,
            ['<Leader>1']      = function() bl.go_to(1, true) end,
            ['<Leader>2']      = function() bl.go_to(2, true) end,
            ['<Leader>3']      = function() bl.go_to(3, true) end,
            ['<Leader>4']      = function() bl.go_to(4, true) end,
            ['<Leader>5']      = function() bl.go_to(5, true) end,
            ['<Leader>6']      = function() bl.go_to(6, true) end,
            ['<Leader>7']      = function() bl.go_to(7, true) end,
            ['<Leader>8']      = function() bl.go_to(8, true) end,
            ['<Leader>9']      = function() bl.go_to(9, true) end,
            ['<Leader>0']      = function() bl.go_to(-1, true) end,
        }

        -- local keymaps = require('maps').bufferline
        for lhs, rhs in pairs(keymaps) do
            vim.keymap.set('n', lhs, rhs, { silent = true, remap = false })
        end

        bufferline.setup {
            options = {
                always_show_bufferline = false,
                tab_size        = 18,
                max_name_length = 18,
                separator_style = 'thin',
                sort_by = 'insert_at_end',

                color_icons              = true,
                show_buffer_icons        = true,
                show_buffer_close_icons  = true,
                -- show_buffer_default_icon = true,
                buffer_close_icon        = '',
                close_icon               = '',
                modified_icon            = '●',
                left_trunc_marker        = '',
                right_trunc_marker       = '',
                indicator = {
                    style = 'icon',
                    icon = '▌',
                },

                numbers = function(opts)
                    return opts.raise(opts.ordinal)
                end,
                name_formatter = function(buf)
                    return buf.name
                end,
                diagnostics_indicator = nil,
                diagnostics = "nvim_lsp",

                offsets = {
                    { 
                        filetype = 'neo-tree',
                        highlight = 'Visual',
                        separator = false,
                        padding = 1,
                        text = function()
                            return vim.fn.getcwd():gsub(vim.fn.getenv("HOME"), '~')
                        end,
                    },
                },

                custom_filter = function(bufnr, bufnrs)
                    local filter_type = {  -- Set each item to true so indexing works
                        help     = true,
                        nofile   = true,
                        qf       = true,
                        acwrite  = true,
                        terminal = true,
                    }
                    if filter_type[vim.bo[bufnr].filetype] or filter_type[vim.bo[bufnr].buftype] then
                        return false
                    elseif vim.fn.isdirectory(vim.fn.bufname(bufnr)) == 1 then
                        return false
                    else
                        return #vim.fn.bufname(bufnr) > 0
                    end
                end,
            },
        }

        function close_current_buffer()
            local current_buffer_id = vim.fn.bufnr("%")
            vim.schedule(function()
                vim.cmd("bd " .. current_buffer_id)
            end)
        end

        -- vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>")
        vim.keymap.set("n", "<leader>d", close_current_buffer)
    end
}

