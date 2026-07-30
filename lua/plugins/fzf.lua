return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local fzf = require("fzf-lua")

        -- 追踪本 session 打开过的文件（oldfiles 只在退出时写入，本方案补漏）
        local session_opened = {}
        vim.api.nvim_create_autocmd('BufReadPost', {
            callback = function()
                local f = vim.fn.expand('<afile>:p')
                if f ~= '' then
                    for i, v in ipairs(session_opened) do
                        if v == f then
                            table.remove(session_opened, i)
                            break
                        end
                    end
                    table.insert(session_opened, 1, f)
                end
            end,
        })

        fzf.setup({
            -- === 1. 查找文件时的忽略配置 (Files) ===
            files = {
                -- 这里使用 fd 命令的参数
                -- --exclude h5: 忽略 h5 目录
                -- --exclude "*.{...}": 忽略各种图片后缀
                fd_opts = [[--color=never --type f --hidden --follow --exclude .git --exclude node_modules --exclude h5 --exclude "*.{png,jpg,jpeg,gif,svg,webp,ico}"]],
				find_opts    = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
				rg_opts      = "--color=never --files --hidden --follow -g '!.git'",
				-- fd_opts      = "--color=never --type f --hidden --follow --exclude .git",
            },

            -- === 2. 搜索内容时的忽略配置 (Grep / Live Grep) ===
            grep = {
                -- 这里使用 rg (ripgrep) 命令的参数
                -- --glob "!h5/**": 排除 h5 目录
                -- --glob "!*.{...}": 排除图片文件
                rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --glob '!h5/**' --glob '!*.{png,jpg,jpeg,gif,svg,webp,ico}'",
            },
            -- 1. 窗口样式设置 (保持悬浮窗)
            winopts = {
                height = 1, -- 窗口高度
                width = 1,  -- 窗口宽度
                row = 0.5,     -- 垂直居中
                col = 0.5,     -- 水平居中
                border = "rounded", -- 边框样式: rounded, double, single, thicc
                preview = {
                    layout = "flex", -- 自动适应预览位置
                    wrap   = true,   -- 预览窗口超长行自动换行
                },
				fullscreen = true,
				vertical   = 'down:45%', -- up|down:size
				horizontal = 'right:60%', -- right|left:size
				hidden     = 'nohidden',
            },
            -- === 3. 预览窗口滚动按键 ===
            -- fzf 原生预览 (fullscreen 模式) 默认用 Shift+Up/Down 滚动，
            -- 但很多终端不传 Shift+方向键，所以用 Ctrl+U/D 来滚动预览窗口。
            keymap = {
                fzf = {
                    true,       -- 继承所有默认按键
                    ["ctrl-u"]  = "preview-half-page-up",
                    ["ctrl-d"]  = "preview-half-page-down",
                },
            },

            -- 2. 核心设置：把搜索框放到最底部
            fzf_opts = {
                -- "default" = 输入框在底部，列表从下往上排列
                -- "reverse" = 输入框在顶部，列表从上往下排列 (fzf-lua 默认通常是这个)
                ["--layout"] = "default",
                ["--info"] = "inline",
                ['--cycle'] = true
            },
        })

        -- === 按键映射 (保持之前的配置) ===
        vim.keymap.set("n", "<leader>b",  fzf.buffers, { desc = "[S]earch [B]uffers" })
        vim.keymap.set("n", "<leader>f",  fzf.files, { desc = "[S]earch [F]iles" })
        vim.keymap.set("n", "<leader>th", fzf.oldfiles, { desc = "[S]earch [O]ldfiles" })
        vim.keymap.set("n", "<leader>so", function()
            local git_root = vim.fs.root(0, '.git')
            if git_root then
                local seen = {}
                local items = {}
                local prefix_len = #git_root + 2 -- "/" after git_root
                local function add_file(path)
                    if vim.startswith(path, git_root) and vim.fn.filereadable(path) == 1 then
                        local rel = path:sub(prefix_len)
                        if not seen[rel] then
                            seen[rel] = true
                            table.insert(items, rel)
                        end
                    end
                end
                -- 本 session 打开过的文件（最近的排最前）
                for _, f in ipairs(session_opened) do
                    add_file(f)
                end
                -- oldfiles 已是时间倒序，先加入
                for _, f in ipairs(vim.v.oldfiles) do
                    add_file(f)
                end
                -- 当前 session 所有 buffer（含 unlisted），按 lastused 倒序插到最前面
                local session_files = {}
                for _, info in ipairs(vim.fn.getbufinfo()) do
                    if info.buftype == '' and info.name ~= '' then
                        local rel = info.name:sub(prefix_len)
                        if vim.startswith(info.name, git_root) and vim.fn.filereadable(info.name) == 1 then
                            -- 从旧位置移除
                            for i, item in ipairs(items) do
                                if item == rel then
                                    table.remove(items, i)
                                    break
                                end
                            end
                            session_files[#session_files + 1] = { rel = rel, lastused = info.lastused }
                        end
                    end
                end
                -- lastused 倒序，最近操作的排最前
                table.sort(session_files, function(a, b) return a.lastused > b.lastused end)
                for i = #session_files, 1, -1 do
                    local rel = session_files[i].rel
                    seen[rel] = true
                    table.insert(items, 1, rel)
                end
                fzf.fzf_exec(items, {
                    cwd = git_root,
                    prompt = ' Oldfiles> ',
                    previewer = 'builtin',
                    actions = {
                        ['default'] = function(selected)
                            if selected and #selected > 0 then
                                vim.cmd('e ' .. vim.fn.fnameescape(git_root .. '/' .. selected[1]))
                            end
                        end,
                    },
                })
            else
                fzf.oldfiles()
            end
        end, { desc = "[S]earch [O]ldfiles (git root)" })
        vim.keymap.set("n", "<leader>sg", fzf.live_grep, { desc = "[S]earch [G]rep" })
        vim.keymap.set("n", "<leader>sc", fzf.lgrep_curbuf, { desc = "[S]earch [C]urrent buffer" })
        -- 光标单词搜索
        vim.keymap.set("n", "<leader>sw", fzf.grep_cword, { desc = "[S]earch current [W]ord" })
        vim.keymap.set("v", "<leader>sw", fzf.grep_visual, { desc = "[S]earch [W]ord selection" })

        vim.keymap.set("n", "<leader>st", fzf.git_status, { desc = "[S]earch Gi[t] Status" })
        vim.keymap.set("n", "<leader>sd", fzf.diagnostics_document, { desc = "[S]earch [D]iagnostics" })
        vim.keymap.set("n", "<leader>sq", fzf.quickfix, { desc = "[S]earch [Q]uickfix" })
        vim.keymap.set("n", "<leader>sm", fzf.marks, { desc = "[S]earch [M]arks" })
        vim.keymap.set("n", "<leader>s?", fzf.builtin, { desc = "[S]earch [?] Builtin" })
        vim.keymap.set("n", "<leader>tt", fzf.resume, { desc = "Fzf-lua resume" })
        vim.keymap.set('n', '<leader>sh', function()
            fzf.grep({
                search = vim.fn.expand('<cword>'),
                rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --follow --no-ignore --glob '!.git/*'",
                no_header = true,
                no_header_i = true,
            })
        end, { desc = "Grep current word (include gitignored files)" })
        vim.keymap.set('n', '<leader>gh', function()
            local bufnr = vim.api.nvim_get_current_buf()
            local file = vim.fn.expand('%:p')
            local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
            if git_root == '' then
                vim.notify('Not in a git repository', vim.log.levels.ERROR)
                return
            end
            local rel_path = file:sub(#git_root + 2)

            fzf.git_bcommits({
                cwd = git_root,
                actions = {
                    ['default'] = function(selected)
                        if not selected or #selected == 0 then return end
                        local commit = vim.split(selected[1], ' ')[1]

                        local diff = vim.fn.systemlist(
                            'git -C ' .. vim.fn.shellescape(git_root)
                                .. ' show --color=never ' .. commit
                                .. ' -- ' .. vim.fn.shellescape(rel_path)
                        )

                        local target_line = nil
                        for _, line_text in ipairs(diff) do
                            local new_start = line_text:match('^@@ %-[-]?%d+,?%d* %+(%d+)')
                            if new_start then
                                target_line = tonumber(new_start)
                                break
                            end
                        end

                        if target_line then
                            vim.api.nvim_set_current_buf(bufnr)
                            pcall(vim.api.nvim_win_set_cursor, 0, { target_line, 0 })
                            vim.cmd('normal! zz')
                        else
                            vim.notify('No changes for current file in this commit', vim.log.levels.WARN)
                        end
                    end,
                },
            })
        end, { desc = "Git history (current file)" })
        vim.keymap.set('n', '<leader>gl', function()
            local git_root = vim.fs.root(0, '.git')
            if not git_root then
                vim.notify('Not in a git repository', vim.log.levels.ERROR)
                return
            end
            fzf.git_commits({
                cwd = git_root,
                actions = {
                    ['default'] = function(selected)
                        if not selected or #selected == 0 then return end
                        local commit = vim.split(selected[1], ' ')[1]
                        local files = vim.fn.systemlist(
                            'git -C ' .. vim.fn.shellescape(git_root)
                            .. ' diff-tree --no-commit-id --name-only -r ' .. commit
                        )
                        if #files == 0 then
                            vim.notify('No files changed in this commit', vim.log.levels.WARN)
                            return
                        end
                        local show_cmd = 'git -C ' .. vim.fn.shellescape(git_root)
                            .. ' show --color=always ' .. commit .. ' -- {}'
                        fzf.fzf_exec(files, {
                            cwd = git_root,
                            prompt = ' Files in ' .. commit:sub(1, 7) .. '> ',
                            preview = show_cmd,
                            actions = {
                                ['default'] = function(fs)
                                    if not fs or #fs == 0 then return end
                                    local rel = fs[1]
                                    vim.cmd('e ' .. vim.fn.fnameescape(git_root .. '/' .. rel))
                                    -- 解析 diff 定位到第一个修改行
                                    local diff = vim.fn.systemlist(
                                        'git -C ' .. vim.fn.shellescape(git_root)
                                        .. ' show --color=never ' .. commit
                                        .. ' -- ' .. vim.fn.shellescape(rel)
                                    )
                                    for _, line_text in ipairs(diff) do
                                        local new_start = line_text:match('^@@ %-[-]?%d+,?%d* %+(%d+)')
                                        if new_start then
                                            local target_line = tonumber(new_start)
                                            pcall(vim.api.nvim_win_set_cursor, 0, { target_line, 0 })
                                            vim.cmd('normal! zz')
                                            break
                                        end
                                    end
                                end,
                            },
                        })
                    end,
                },
            })
        end, { desc = "Git history (all)" })
        vim.keymap.set("n", "<leader>sl", function()
            local fzf = require("fzf-lua")
            local lsp = vim.lsp
            local bufnr = vim.api.nvim_get_current_buf()
            local uri = vim.uri_from_bufnr(bufnr)
            local params = { textDocument = vim.lsp.util.make_text_document_params() }

            lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(_, result)
                if not result or vim.tbl_isempty(result) then
                    vim.notify("No symbols found", vim.log.levels.WARN)
                    return
                end

                local items = {}
                local icons = { [5] = " ", [6] = "󰊕 ", [12] = "󰊕 " }

                local function add_symbols(symbols, parent)
                    for _, s in ipairs(symbols) do
                        if s.kind == 5 or s.kind == 6 or s.kind == 12 then
                            local target_range = s.selectionRange or s.range
                            local icon = icons[s.kind] or ""
                            local name = parent and (parent .. "." .. s.name) or s.name

                            table.insert(items, string.format(
                                "%s:%d:%d: %s%s",
                                vim.uri_to_fname(uri),
                                target_range.start.line + 1,
                                target_range.start.character + 1,
                                icon,
                                name
                            ))
                        end
                        if s.children then
                            add_symbols(s.children, s.kind == 5 and s.name or parent)
                        end
                    end
                end

                add_symbols(result)
                if #items == 0 then return end

                fzf.fzf_exec(items, {
                    prompt = " Symbols> ",
                    previewer = "builtin",
                    actions = {
                        ["default"] = function(selected)
                            if not selected or #selected == 0 then return end

                            local parts = vim.split(selected[1], ":")
                            local line = tonumber(parts[2])
                            local col = tonumber(parts[3])

                            vim.api.nvim_win_set_cursor(0, { line, col - 1 })
                            vim.cmd("normal! zz")
                        end,
                    },
                    winopts = {
                        height = 0.85,
                        width = 0.85,
                        preview = {
                            layout = "flex",
                            horizontal = "right:60%",
                        },
                    },
                    fzf_opts = {
                        ["--delimiter"] = ":",
                        ["--with-nth"] = "4..",
                    },
                })
            end)
        end, { desc = "Find Classes & Functions" })
    end,
}
