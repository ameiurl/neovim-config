return {
    "hedyhli/outline.nvim",
    config = function()
        vim.keymap.set("n", "<leader>e", "<cmd>Outline<CR>",
        { desc = "Toggle Outline" })
        local status_ok, symbols = pcall(require, 'outline')
        if not status_ok then
            print("Couldn't load 'outline'")
            return
        end
        symbols.setup {
            outline_window = {
                position = 'left',
                auto_close = true,
            },
            keymaps = {
                goto_location = '<cr>',
            },
        }
    end,
}
