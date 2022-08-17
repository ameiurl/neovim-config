local M = {}

M.setup = function()
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, {
			texthl = sign.name,
			text = sign.text,
			numhl = "",
		})
	end

	local config = {
		virtual_text = {
			severity = vim.diagnostic.severity.ERROR,
			spacing = 2,
			prefix = "",
		},
		signs = {
			active = signs,
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "if_many",
			header = "",
			prefix = "· ",
		},
	}

	vim.diagnostic.config(config)

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
	})
end

local function lsp_highlight_document(client)
	-- Set autocommands conditional on server_capabilities
	if client.resolved_capabilities.document_highlight then
		vim.api.nvim_exec([[
			augroup lsp_document_highlight
				au! * <buffer>
				au CursorHold <buffer> lua vim.lsp.buf.document_highlight()
				au CursorMoved <buffer> lua vim.lsp.buf.clear_references()
			augroup end
		]],
		false)
	end
end

local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true }
	local map = function(mode, shortcut, action)
		vim.api.nvim_buf_set_keymap(bufnr, mode, shortcut, action, opts)
	end
	map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
	map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
	map('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
	map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
	map('n', '<A-K>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
	map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
	map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>')
	map('n', ']d', '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>')
	map('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float({ border = "rounded" })<CR>')
	map('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>')
	map('n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>')

	vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

M.on_attach = function(client, bufnr)
	if client.name == "tsserver" then
		client.resolved_capabilities.document_formatting = false
	end
	lsp_keymaps(bufnr)
	lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local cmp_status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not cmp_status_ok then
	print("Unable to load cmp_nvim_lsp")
	return
end

M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

return M
