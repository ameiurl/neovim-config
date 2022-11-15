local status_ok, comment = pcall(require, 'Comment')
if not status_ok then
	print("Couldn't load 'Comment'")
	return
end

comment.setup {
	padding = true,
	sticky = true,
	ignore = '^$',

	toggler = {
        ---line-comment keymap
		-- line = '<C-_>',
		line = '<Leader>cc',
        ---block-comment keymap
        block = 'gbc',
	},

	opleader = {
        ---line-comment keymap
		-- line = 'g<C-_>',
        line = 'gc',
        ---block-comment keymap
        block = 'gb',
	},

	extra = {
		above = 'g/O',
		below = 'g/o',
		eol   = 'g/A',
	},

	mappings = {
		basic = true,
		extra = true,
		extended = false,
	},

	-- post_hook = nil,
    pre_hook = function(ctx)
        return require('ts_context_commentstring.internal').calculate_commentstring()
    end
}
