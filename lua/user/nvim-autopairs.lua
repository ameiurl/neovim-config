local npairs_ok, npairs = pcall(require, 'nvim-autopairs')
if not npairs_ok then
	print("Couldn't load 'nvim-autopairs'")
	return
end

npairs.setup({
    check_ts = true,
})

local Rule = require 'nvim-autopairs.rule'
npairs.add_rule(Rule('(', ')'))
npairs.add_rule(Rule('{', '}'))
