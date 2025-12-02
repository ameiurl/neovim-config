return {
    {
        "zbirenbaum/copilot.lua",
        enabled = true,
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            suggestion = { enabled = false }, -- Disable standalone Copilot (let cmp handle it)
            panel = { enabled = false },
        },
    },
    {
        "zbirenbaum/copilot-cmp",
        dependencies = {
            "zbirenbaum/copilot.lua",
            cmd = "Copilot",
            build = ":Copilot auth",
            event = "InsertEnter",
            opts = {
                suggestion = { enabled = false }, -- Disable standalone Copilot (let cmp handle it)
                panel = { enabled = false },
            },
        },
        config = function()
            require("copilot_cmp").setup()
        end,
    }
}
-- return {
--     "github/copilot.vim",
--     config = function()
--         vim.g.copilot_enabled = true
--         vim.g.copilot_no_tab_map = true
--         vim.api.nvim_set_keymap('n', '<leader>go', ':Copilot<CR>', { silent = true })
--         vim.api.nvim_set_keymap('n', '<leader>ge', ':Copilot enable<CR>', { silent = true })
--         vim.api.nvim_set_keymap('n', '<leader>gd', ':Copilot disable<CR>', { silent = true })
--         vim.api.nvim_set_keymap('i', '<c-p>', '<Plug>(copilot-suggest)', { noremap = true })
--         vim.api.nvim_set_keymap('i', '<c-n>', '<Plug>(copilot-next)', { noremap = true, silent = true })
--         vim.api.nvim_set_keymap('i', '<c-l>', '<Plug>(copilot-previous)', { noremap = true, silent = true })
--         vim.cmd('imap <silent><script><expr> <C-C> copilot#Accept("")')
--         vim.cmd([[
--             let g:copilot_filetypes = {
--             \ 'TelescopePrompt': v:false,
--             \ }
--             ]])
--     end
-- }
