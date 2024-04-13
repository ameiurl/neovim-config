local cmp_status_ok, cmp = pcall(require, 'cmp')
if not cmp_status_ok then
	print("Couldn't load 'cmp'")
	return
end

local luasnip = require('lazy-require').require_on_exported_call('user.luasnip')

local kind_icons = require('user.settings.icons')

local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup {
	-- snippet = {
	-- 	expand = function(args)
	-- 		luasnip.lsp_expand(args.body)
	-- 	end,
	-- },

	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
		end,
	},

	mapping = cmp.mapping.preset.insert({
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),

		-- Accept currently selected item.
		-- Set `select` to `false` to only confirm explicitly selected items.
		['<CR>'] = cmp.mapping.confirm({ select = true }),

		-- Supertab
		['<Tab>'] = cmp.mapping(function(fallback)
			local check_backspace = function()
				local col = vim.fn.col '.' - 1
				return col == 0 or vim.fn.getline('.'):sub(col, col):match "%s"
			end

			if cmp.visible() then
				-- cmp.select_next_item()
				cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = true,
				})()
			-- elseif luasnip.expandable() then
			-- 	luasnip.expand()
			-- elseif luasnip.expand_or_jumpable() then
			-- 	luasnip.expand_or_jump()
			elseif vim.fn["vsnip#available"](1) == 1 then
				feedkey("<Plug>(vsnip-expand-or-jump)", "")
			elseif has_words_before() then
				cmp.complete()
			elseif check_backspace() then
				fallback()
			else
				fallback()
			end
		end, {'i', 's'}),

		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			-- elseif luasnip.jumpable(-1) then
			-- 	luasnip.jump(-1)
			elseif vim.fn["vsnip#jumpable"](-1) == 1 then
        		feedkey("<Plug>(vsnip-jump-prev)", "")
			else
				fallback()
			end
		end, {'i', 's'}),
	}),

	formatting = {
		fields = { 'kind', 'abbr', 'menu' },
		format = function(entry, vim_item)
			-- Kind icons
			vim_item.kind = string.format("%s", kind_icons[vim_item.kind])

			vim_item.menu = ({
				nvim_lsp = '[LSP]',
				nvim_lua = '[NvimLua]',
				luasnip  = '[LuaSnip]',
				buffer   = '[Buffer]',
				path     = '[Path]',
			})[entry.source.name]

			return vim_item
		end,
	},

	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'nvim_lsp_signature_help' },
		{ name = 'nvim_lua' },
		-- { name = 'luasnip' },
		{ name = "vsnip" }, -- For vsnip users.
		{ name = 'buffer' },
		{ name = 'path' },
	},

	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	},

	experimental = {
		ghost_text = true,
		native_menu = false,
	},
}

cmp.setup.cmdline('/', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' },
	},
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'cmdline' }
	}, {
		{ name = 'path' }
	}),
})

-- vsnip
vim.g.vsnip_snippet_dir = os.getenv('HOME') .. "/.config/nvim/snippets"
