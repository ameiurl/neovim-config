-- return {
--     {
--         "zbirenbaum/copilot.lua",
--         enabled = true,
--         cmd = "Copilot",
--         event = "InsertEnter",
--         config = function()
--             require("copilot").setup({
--                 panel = {
--                     enabled = true,
--                     auto_refresh = true,
--                     keymap = {
--                         -- jump_next = "<c-j>",
--                         -- jump_prev = "<c-k>",
--                         -- accept = "<c-a>",
--                         refresh = "r",
--                         open = "<M-CR>",
--                     },
--                     layout = {
--                         position = "bottom", -- | top | left | right
--                         ratio = 0.4,
--                     },
--                 },
--                 suggestion = {
--                     enabled = true,
--                     auto_trigger = true,
--                     debounce = 75,
--                     keymap = {
--                         -- accept = "<c-l>",
--                         accept_word = false,
--                         accept_line = false,
--                         next = "<c-]>",
--                         prev = "<c-[>",
--                         dismiss = "<C-e>",
--                     },
--                 },
--             })
--         end
--     },
--     {
--         "zbirenbaum/copilot-cmp",
--         after = { "copilot.lua" },
--         config = function()
--             require("copilot_cmp").setup()
--         end,
--     }
-- }
return {
    "github/copilot.vim",
    config = function()
        vim.g.copilot_enabled = true
        vim.g.copilot_no_tab_map = true
        vim.api.nvim_set_keymap('n', '<leader>go', ':Copilot<CR>', { silent = true })
        vim.api.nvim_set_keymap('n', '<leader>ge', ':Copilot enable<CR>', { silent = true })
        vim.api.nvim_set_keymap('n', '<leader>gd', ':Copilot disable<CR>', { silent = true })
        vim.api.nvim_set_keymap('i', '<c-p>', '<Plug>(copilot-suggest)', { noremap = true })
        vim.api.nvim_set_keymap('i', '<c-n>', '<Plug>(copilot-next)', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('i', '<c-l>', '<Plug>(copilot-previous)', { noremap = true, silent = true })
        vim.cmd('imap <silent><script><expr> <C-C> copilot#Accept("")')
        vim.cmd([[
            let g:copilot_filetypes = {
            \ 'TelescopePrompt': v:false,
            \ }
            ]])
    end
}
