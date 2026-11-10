return {
    "kdheepak/lazygit.nvim",
    cmd = {
        "LazyGit",
        "LazyGitLog",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
        { "<leader>gg",  "<cmd>LazyGit<cr>",                   desc = "Lazygit" },
        { "<leader>gla", "<cmd>LazyGitLog<cr>",               desc = "Lazygit Log (project)" },
        { "<leader>glc", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "Lazygit Current File History" },
    },
    init = function()
        vim.g.lazygit_floating_window_winblend = 0
        vim.g.lazygit_floating_window_scaling_factor = 0.9
        vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
        vim.g.lazygit_use_neovim_remote = 1
    end,
    config = function()
        -- lazygit 是终端 buffer，会继承全局 number=true；
        -- 且全局 InsertEnter/InsertLeave 会自动改 number，所以这里持续兜底。
        vim.api.nvim_create_autocmd({ "FileType", "TermOpen", "InsertEnter", "InsertLeave", "WinEnter" }, {
            pattern = "*",
            group = vim.api.nvim_create_augroup("lazygit_no_line_numbers", { clear = true }),
            callback = function()
                if vim.bo.filetype ~= "lazygit" then return end
                vim.wo.number = false
                vim.wo.relativenumber = false
            end,
        })
    end,
}
