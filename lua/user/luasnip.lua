local status_ok, luasnip = pcall(require, 'luasnip')
if not status_ok then
	print("Couldn't load 'luasnip'")
	return
end

require('luasnip.loaders.from_vscode').lazy_load()

local extensions = {
	ruby = {
		"jekyll",
		"rails",
	},
	javascript = {
		"jsdoc",
	},
	cpp = {
		"unreal",
	},
}

for lang, tbl in pairs(extensions) do
	luasnip.filetype_extend(lang, tbl)
end

-- VIM/NeoVIM：解决LuaSnip下Tab按键跳转冲突问题
vim.api.nvim_create_autocmd('ModeChanged', {
  pattern = '*',
  callback = function()
    if ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
        and require('luasnip').session.current_nodes[vim.api.nvim_get_current_buf()]
        and not require('luasnip').session.jump_active
    then
      require('luasnip').unlink_current()
    end
  end
})

return luasnip
