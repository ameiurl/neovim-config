local M = {}

local function make_theme_augroup()
  vim.cmd [[
    augroup ColorSchemeOverride
      au!
      au ColorScheme *
      \   highlight! TabLineFill cterm=NONE gui=NONE ctermbg=Darkgray guibg=#333333
      \|  highlight! Todo cterm=bold gui=bold ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black
      \|  highlight! Comment cterm=italic gui=italic
      \|  highlight! link TSComment Comment
      \|  highlight! Whitespace cterm=NONE ctermfg=8 guifg=#3a3a3a
      \|  highlight! link WinSeparator LineNr
      \|  highlight! GitSignsCurrentLineBlame cterm=italic,bold ctermfg=Lightgray gui=italic,bold guifg=#4A4A4A
      \|  highlight! DiagnosticVirtualTextError cterm=bold,italic gui=bold,italic ctermfg=darkred guifg=darkred guibg=NONE
      \|  highlight! DiagnosticVirtualTextWarn cterm=bold,italic gui=bold,italic ctermfg=yellow guifg=#777700 guibg=NONE
      \|  highlight! DiagnosticVirtualTextInfo cterm=bold,italic gui=bold,italic ctermfg=lightyellow guifg=#666644 guibg=NONE
      \|  highlight! IndentBlanklineChar guifg=#2b2f38 gui=nocombine
      \|  highlight! link IndentBlanklineSpaceChar Whitespace
      \|  highlight! link IndentBlanklineIndent1 CursorColumn
      \|  highlight! IndentBlanklineIndent2 guibg=NONE gui=nocombine
      \|  highlight! link IlluminatedWordText LspReferenceText
      \|  highlight! link IlluminatedWordRead LspReferenceRead
      \|  highlight! link IlluminatedWordWrite LspReferenceWrite
    augroup end
  ]]
end

local function colorscheme_seoul256()
  vim.cmd [[
    let g:seoul256_background = 236
    colorscheme seoul256 
    hi phpVarSelector       guifg=#FFBFBD              gui=none
    "hi phpIdentifier        guifg=#C8C8C8              gui=none
    "hi phpVarSelector       guifg=#C8C8C8              gui=none
    hi phpStringSingle      guifg=#BCDDBD              gui=none
    hi phpStringDouble      guifg=#BCDDBD              gui=none
    hi phpFunctions         guifg=#e2c792              gui=none
    hi phpMethods           guifg=#e2c792              gui=none
    hi phpSpecialFunction   guifg=#e2c792              gui=none
    hi phpBaselib           guifg=#e2c792              gui=none
    hi phpNumber            guifg=#e55561              gui=none
    hi phpFloat             guifg=#e55561              gui=none
    hi htmlTag              guifg=#98BC99              gui=none
    hi htmlEndTag           guifg=#98BC99              gui=none
    hi javaScript           guifg=#C8C8C8              gui=none
  ]]
end

local function colorscheme_tmp()
  vim.cmd [[
    "let g:gruvbox_material_background = 'soft'
    "colorscheme gruvbox-material
  ]]
end

---@class colorschemeOptions
---@field public scheme string?

---@param opts colorschemeOptions
M.setup = function(opts)
  opts = opts or {}
  opts.scheme = opts.scheme or 'default'
  make_theme_augroup()
  -- vim.api.nvim_command('colorscheme ' .. opts.scheme)
  colorscheme_seoul256()
  colorscheme_tmp()
end

vim.api.nvim_create_user_command("Gruvbox", function ()
  vim.cmd [[
    let g:gruvbox_material_background = 'soft'
    colorscheme gruvbox-material 
  ]]
end, {})

return M
