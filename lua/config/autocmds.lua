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

local function preview_stack_trace()
    local line = vim.api.nvim_get_current_line()
    local filepath = nil
    local line_nr = nil
    local column_nr = nil

    -- === 1. 尝试匹配: 路径:行:列 ===
    filepath, line_nr, column_nr = string.match(line, "([^: (]+):(%d+):(%d+)")

    -- === 2. 尝试匹配: 路径:行 ===
    if not filepath then
        filepath, line_nr = string.match(line, "([^: (]+):(%d+)")
        if filepath then
            column_nr = 1
        end
    end

    -- === 3. 尝试匹配纯路径 (无行号) ===
    if not filepath then
        for word in string.gmatch(line, "([^: (]+)") do
            if string.find(word, "^package:") or string.find(word, "%.dart") or string.find(word, "/") then
                filepath = word
                -- 【重点修改】这里必须保持 nil，表示日志里没指定行号
                line_nr = nil 
                column_nr = nil
                break
            end
        end
    end

    -- === 执行打开逻辑 ===
    if filepath then
        -- 1. 路径清洗
        if string.match(filepath, "^package:") then
            filepath = string.gsub(filepath, "package:[^/]+/", "lib/")
        end
        filepath = string.gsub(filepath, "[%.%,]$", "")

        -- 2. 窗口切换
        local log_win_id = vim.api.nvim_get_current_win()
        vim.cmd("wincmd p")
        if vim.api.nvim_get_current_win() == log_win_id then
            vim.cmd("vsplit")
        end

        -- 3. 打开文件
        local ok, _ = pcall(vim.cmd, "e " .. filepath)
        if ok then
            if line_nr then
                -- A. 情况：日志里明确写了行号 -> 强制跳转到那一行
                pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(line_nr), tonumber(column_nr or 1) - 1 })
                vim.cmd("normal! zz") -- 居中显示
            else
                -- B. 情况：日志里没写行号 -> 使用你提供的逻辑跳转到最后编辑位置
                -- 检查标记 '"' (上次退出位置) 是否大于1且小于文件总行数
                if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
                    vim.cmd("normal! g'\"") -- 跳转
                    vim.cmd("normal! zz")   -- 顺便居中一下，方便查看
                end
            end
        else
            print("无法打开文件: " .. filepath)
        end
    else
        -- 没找到路径，回车当作向下移动
        local key = vim.api.nvim_replace_termcodes("<Down>", true, false, true)
        vim.api.nvim_feedkeys(key, "n", false)
    end
end

-- 保持原有的自动命令配置
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local buftype = vim.bo.buftype
        if string.find(buf_name, "/tmp/") or buftype == "terminal" or buftype == "nofile" then
            vim.keymap.set("n", "<CR>", preview_stack_trace, { silent = true, noremap = true, buffer = true })
        end
    end
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "",
    command = "set fo-=c fo-=r fo-=o",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    local opts = { buffer = true, remap = false, silent = true }
    
    -- 按 <CR> (回车)：在该位置打开文件（默认行为通常就是这个，但显式指定更安全）
    -- 注意：<CR> 默认其实就是跳到该文件，如果你想回车后自动关闭 qf 窗口，可以用下面的 map
    vim.keymap.set("n", "<CR>", "<CR>", opts)
    -- 如果你想回车跳转后自动关闭 Quickfix，用这行代替上面那行：
    -- vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", opts)

    -- 按 o：在预览窗口打开，光标留在 Quickfix 列表 (Preview)
    vim.keymap.set("n", "o", "<CR><C-w>p", opts)

    -- 按 t：在新标签页打开 (Tab)
    vim.keymap.set("n", "t", "<C-w><Enter><C-w>T", opts)

    -- 按 v：垂直分屏打开 (Vertical split)
    vim.keymap.set("n", "v", "<C-w><Enter><C-w>L", opts)
    
    -- 按 q：关闭 Quickfix 窗口
    vim.keymap.set("n", "q", ":close<CR>", opts)
  end,
})

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

-- show cursor line only in active window
local cursorGrp = vim.api.nvim_create_augroup("CursorLine", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    pattern = "*",
    command = "set cursorline",
    group = cursorGrp,
})
vim.api.nvim_create_autocmd(
    { "InsertEnter", "WinLeave" },
    { pattern = "*", command = "set nocursorline", group = cursorGrp }
)
