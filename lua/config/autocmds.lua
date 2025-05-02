-- autocmds
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight on yank",
	callback = function()
		vim.highlight.on_yank({ higrou = "IncSearch", timeout = 500 })
	end,
    group = vim.api.nvim_create_augroup("highlight_yank", {}),
})
vim.api.nvim_create_autocmd({"BufReadPost"}, {
    desc = "go to last loc when opening a buffer",
    pattern = {"*"},
    callback = function()
        if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
            vim.api.nvim_exec("normal! g'\"",false)
        end
    end
})
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })
    vim.api.nvim_set_hl(0, "LspInfoBorder", { link = "Normal" })
    vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })

    vim.cmd('highlight DiagnosticError guifg=red')
    vim.cmd('highlight DiagnosticVirtualTextError guifg=red')
    vim.cmd('highlight IncSearch cterm=reverse gui=reverse')
  end,
})
vim.api.nvim_create_autocmd("FileType", {
    desc = "Close some buffers with specific filetypes using `q`",
    group = vim.api.nvim_create_augroup("ronisbr_close_with_q", { clear = true }),
    pattern = {
        "help",
        "lspinfo",
        "notify",
        "qf",
        "startuptime",
        "checkhealth",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

vim.api.nvim_create_autocmd("BufHidden", {
  desc = "Delete [No Name] buffers",
  callback = function(data)
    if data.file == "" and vim.bo[data.buf].buftype == "" and not vim.bo[data.buf].modified then
      vim.schedule(function()
        pcall(vim.api.nvim_buf_delete, data.buf, {})
      end)
    end
  end,
})

vim.filetype.add({
	desc = "Set filetype to bigfile for files larger than 1MB",
	pattern = {
		[".*"] = {
			function(path, buf)
				return vim.bo[buf].filetype ~= "bigfile"
						and path
						and vim.fn.getfsize(path) > 1024 * 1024 -- 1MB
						and "bigfile"
					or nil
			end,
		},
	},
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
	desc = "Disable some features for big files",
    group = vim.api.nvim_create_augroup("bigfile", {}),
	pattern = 'bigfile',
	callback = function(ev)
		vim.opt.cursorline = false
		vim.opt.cursorcolumn = false
		vim.opt.list = false
		vim.opt.wrap = false
		vim.b.minianimate_disable = true
		vim.schedule(function()
			vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ''
		end)
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	desc = "Set relativenumber",
	pattern = "*",
	command = "set relativenumber",
    group = vim.api.nvim_create_augroup("set_relativenumber_number", {}),
})

vim.api.nvim_create_autocmd({ "InsertEnter"}, {
	desc = "Set norelativenumber number",
	pattern = "*",
	command = "set norelativenumber number",
    group = vim.api.nvim_create_augroup("set_norelativenumber_number", {}),
})


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
