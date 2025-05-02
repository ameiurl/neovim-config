return {
  {
    'ameiurl/seoul256.nvim',
    config = function()
        vim.g.seoul256_italic_comments = true
        vim.g.seoul256_contrast = true
        vim.g.seoul256_hl_current_line = true
        vim.cmd.colorscheme("seoul256")
        vim.cmd.hi("phpVarSelector guifg=#FFBFBD")
        vim.cmd.hi("phpStringSingle guifg=#BCDDBD")
        vim.cmd.hi("phpStringDouble guifg=#BCDDBD")
        vim.cmd.hi("phpFunctions guifg=#e2c792")
        vim.cmd.hi("phpMethods guifg=#e2c792")
        vim.cmd.hi("phpSpecialFunction guifg=#e2c792")
        vim.cmd.hi("phpBaselib guifg=#e2c792")
        vim.cmd.hi("phpNumber guifg=#e55561")
        vim.cmd.hi("phpFloat guifg=#e55561")
        vim.cmd.hi("htmlTag guifg=#98BC99")
        vim.cmd.hi("htmlEndTag guifg=#98BC99")
        vim.cmd.hi("javaScript guifg=#C8C8C8")
    end,
  },
}
