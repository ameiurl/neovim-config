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
                height = 0.85, -- 窗口高度
                width = 0.80,  -- 窗口宽度
                row = 0.5,     -- 垂直居中
                col = 0.5,     -- 水平居中
                border = "rounded", -- 边框样式: rounded, double, single, thicc
                preview = {
                    layout = "flex", -- 自动适应预览位置
                },
            },
            -- 2. 核心设置：把搜索框放到最底部
            fzf_opts = {
                -- "default" = 输入框在底部，列表从下往上排列
                -- "reverse" = 输入框在顶部，列表从上往下排列 (fzf-lua 默认通常是这个)
                ["--layout"] = "default", 
                ["--info"] = "inline",
            },
        })

        -- === 按键映射 (保持之前的配置) ===
        vim.keymap.set("n", "<leader>sb", fzf.buffers, { desc = "[S]earch [B]uffers" })
        vim.keymap.set("n", "<leader>f", fzf.files, { desc = "[S]earch [F]iles" })
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
    end,
}
