return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local fzf = require("fzf-lua")
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
                },
				fullscreen = true,
				vertical   = 'down:45%', -- up|down:size
				horizontal = 'right:60%', -- right|left:size
				hidden     = 'nohidden',
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
        vim.keymap.set("n", "<leader>sb", fzf.buffers, { desc = "[S]earch [B]uffers" })
        vim.keymap.set("n", "<leader>f",  fzf.files, { desc = "[S]earch [F]iles" })
        vim.keymap.set("n", "<leader>so", fzf.oldfiles, { desc = "[S]earch [O]ldfiles" })
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
