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

local function preview_stack_trace()
    local line = vim.api.nvim_get_current_line()
    local filepath = nil
    local line_nr = nil
    local column_nr = nil

    -- === 1. 尝试匹配: 路径:行:列 ===
    filepath, line_nr, column_nr = string.match(line, "([^: (]+):(%d+):(%d+)")

    -- === 2. 如果没匹配到，尝试匹配: 路径:行 ===
    if not filepath then
        filepath, line_nr = string.match(line, "([^: (]+):(%d+)")
        column_nr = 1 -- 默认第1列
    end

    -- === 3. 如果还没匹配到，尝试提取看起来像路径的字符串 ===
    if not filepath then
        -- 这里的正则意思：匹配连续的字符，直到遇到空格、冒号或括号
        -- 你可以根据实际情况调整，这里假设路径里不含空格
        for word in string.gmatch(line, "([^: (]+)") do
            -- 简单的过滤逻辑：只有包含 "package:" 或 ".dart" 或 "/" 的词才被视为路径
            -- 防止把日志里的 "I/flutter" 或 "Error" 这种词当成文件打开
            if string.find(word, "^package:") or string.find(word, "%.dart") or string.find(word, "/") then
                filepath = word
                line_nr = 1
                column_nr = 1
                break -- 找到第一个像路径的就停止
            end
        end
    end

    -- === 执行打开逻辑 ===
    if filepath then
        -- 1. 处理 Flutter package 路径
        if string.match(filepath, "^package:") then
            filepath = string.gsub(filepath, "package:[^/]+/", "lib/")
        end
        
        -- 移除路径末尾可能残留的标点（如有些日志路径后面紧跟句号）
        filepath = string.gsub(filepath, "[%.%,]$", "")

        -- 2. 窗口切换
        local log_win_id = vim.api.nvim_get_current_win()
        vim.cmd("wincmd p") -- 尝试跳回上一个窗口
        if vim.api.nvim_get_current_win() == log_win_id then
            vim.cmd("vsplit") -- 如果没跳走，就垂直分屏
        end

        -- 3. 打开文件
        local ok, _ = pcall(vim.cmd, "e " .. filepath)
        if ok then
            -- 只有当确切抓取到行号时（或者默认设为1时）才跳转
            if line_nr then
                pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(line_nr), tonumber(column_nr) - 1 })
                vim.cmd("normal! zz")
            end
            
            -- 可选：跳回去 Log 窗口（注释掉下面这行则留在代码窗口）
            -- vim.api.nvim_set_current_win(log_win_id)
        else
            print("无法打开文件: " .. filepath)
        end
    else
        -- 如果没找到路径，就把回车当成普通的“向下移动”，方便看日志
        local key = vim.api.nvim_replace_termcodes("<Down>", true, false, true)
        vim.api.nvim_feedkeys(key, "n", false)
    end
end

-- 配置自动命令 (针对 /tmp 临时文件或 Log 窗口)
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local buftype = vim.bo.buftype
        -- 只要路径包含 /tmp/ 或者 也是 terminal/nofile 类型，就绑定回车
        if string.find(buf_name, "/tmp/") or buftype == "terminal" or buftype == "nofile" then
            vim.keymap.set("n", "<CR>", preview_stack_trace, { silent = true, noremap = true, buffer = true })
        end
    end
})
