return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- 0.12 重写版；master 已冻结，只兼容 0.11
    lazy = false, -- main 分支不支持懒加载
    build = ":TSUpdate",
    dependencies = {
        { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
        "nvim-treesitter/nvim-treesitter-context",
        "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
        local ok, ts = pcall(require, "nvim-treesitter")
        -- master 也有 setup()，但没有 install()，用 install 判断分支
        if not ok or type(ts.setup) ~= "function" or type(ts.install) ~= "function" then
            vim.notify(
                "nvim-treesitter 还是旧的 master 分支，请先执行 :Lazy sync 再重启",
                vim.log.levels.WARN
            )
            return
        end

        -- 原来 ensure_installed 里的语言，加上实际在用的 tsx/typescript/scss
        local parsers = {
            "javascript", "typescript", "tsx",
            "css", "scss", "html",
            "markdown", "markdown_inline",
            "php", "vue",
        }

        ts.setup({})
        ts.install(parsers) -- 异步安装，已安装则跳过

        -- 原来的 indent.enable = true（html 除外）
        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "javascript", "javascriptreact", "typescript", "typescriptreact",
                "css", "scss", "php", "vue", "markdown",
            },
            callback = function()
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })

        -- 原来 highlight.enable = false；需要 treesitter 语法高亮就取消注释
        -- vim.api.nvim_create_autocmd("FileType", {
        --     pattern = {
        --         "javascript", "javascriptreact", "typescript", "typescriptreact",
        --         "css", "scss", "html", "php", "vue", "markdown",
        --     },
        --     callback = function() pcall(vim.treesitter.start) end,
        -- })

        -- textobjects：main 分支 setup 只保留行为配置，键位自己 map
        require("nvim-treesitter-textobjects").setup({
            select = { lookahead = true },
            move = { set_jumps = true },
        })

        local select = require("nvim-treesitter-textobjects.select")
        local move = require("nvim-treesitter-textobjects.move")
        local swap = require("nvim-treesitter-textobjects.swap")

        local function sel(obj)
            return function()
                select.select_textobject(obj, "textobjects")
            end
        end

        vim.keymap.set({ "x", "o" }, "if", sel("@function.inner"), { desc = "TS inner function" })
        vim.keymap.set({ "x", "o" }, "af", sel("@function.outer"), { desc = "TS outer function" })
        vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"), { desc = "TS inner class" })
        vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"), { desc = "TS outer class" })

        vim.keymap.set("n", "<Leader>>", function()
            swap.swap_next("@parameter.inner")
        end)
        vim.keymap.set("n", "<Leader><", function()
            swap.swap_previous("@parameter.inner")
        end)

        vim.keymap.set({ "n", "x", "o" }, "gf", function()
            move.goto_next_start("@function.outer", "textobjects")
        end)
        vim.keymap.set({ "n", "x", "o" }, "ga", function()
            move.goto_next_start("@parameter.inner", "textobjects")
        end)
        vim.keymap.set({ "n", "x", "o" }, "gt", function()
            move.goto_previous_start("@function.outer", "textobjects")
        end)
        vim.keymap.set({ "n", "x", "o" }, "gb", function()
            move.goto_previous_start("@parameter.inner", "textobjects")
        end)

        require("ts_context_commentstring").setup({
            enable_autocmd = false,
            languages = {
                typescript = "// %s",
            },
        })

        require("treesitter-context").setup({
            mode = "cursor",
            patterns = {
                lua = {
                    "variable_declaration",
                    "table_constructor",
                },
                gdscript = {
                    "variable_statement",
                    "enum_definition",
                },
            },
            exclude_patterns = {
                cs = {
                    "attribute_list",
                    "attribute",
                },
            },
        })
    end,
}
