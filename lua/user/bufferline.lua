local status_ok, bl = pcall(require, 'bufferline')
if not status_ok then
	print("Couldn't load 'bufferline'")
	return
end

vim.keymap.set('n', '[b', function() bl.cycle(-1) end, { silent = true, remap = false })
vim.keymap.set('n', ']b', function() bl.cycle(1) end, { silent = true, remap = false })

bl.setup {
	options = {
		always_show_bufferline = true,
		tab_size = 18,
		max_name_length = 18,
		separator_style = 'thin',
		sort_by = 'insert_after_current',

		color_icons = true,
		show_buffer_icons = true,
		show_buffer_close_icons = false,
		show_buffer_default_icon = true,
		buffer_close_icon = '',
		close_icon = '',
		modified_icon = 'ﰣ',
		left_trunc_marker = 'ﬞﲑ',
		right_trunc_marker = 'ﲒ',
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
		diagnostic_indicator = function(count, level)
			return level:match("error") and "x" or "!"
		end,

		offsets = {
			{ filetype = 'NvimTree',
				text = 'Nvim Tree',
				highlight = 'Visual',
				separator = false },
			{ filetype = 'Outline',
				text = 'Outline',
				highlight = 'Visual',
				separator = true },
			{ filetype = 'Trouble',
				text = 'Trouble',
				highlight = 'Visual',
				separator = true },
		},

		custom_filter = function(bufnr, bufnrs)
			local filter_type = {
				'help',
				'nofile',
				'qf',
				'quickfix',
			}
			if filter_type[vim.bo[bufnr].filetype] or filter_type[vim.bo[bufnr].buftype] then
				return false
			elseif vim.fn.match(vim.fn.system({ 'file', '-i', vim.fn.bufname(bufnr) }), 'inode/directory') > 0 then
				return false
			else
				return vim.fn.bufname(bufnr) ~= ''
			end
		end,
	},
}