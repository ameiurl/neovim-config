return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ':Copilot auth',
    event = 'BufReadPost',
    opts = {
    suggestion = {
      auto_trigger = true,
      keymap = {
        accept = '<Tab>',
        accept_word = '<A-Right>',
        accept_line = '<A-C-Right>',
        next = '<A-]>',
        prev = '<A-[>',
        dismiss = '<C-]>',
      },
    },
    panel = { enabled = false },
    },
    config = function(_, opts)
    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpMenuOpen',
      callback = function()
        vim.b.copilot_suggestion_hidden = true
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpMenuClose',
      callback = function()
        vim.b.copilot_suggestion_hidden = false
      end,
    })

    require('copilot').setup(opts)
  end,
}
