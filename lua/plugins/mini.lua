return { -- Collection of various small independent plugins/modules
		"nvim-mini/mini.nvim",
		config = function()
            -- Simple and easy statusline.
            --  You could remove this setup call if you don't like it,
            --  and try some other statusline plugin
            -- require("mini.statusline").setup({ set_vim_settings = false })
            require("mini.comment").setup({
                options = {
                    custom_commentstring = function()
                        return require("ts_context_commentstring.internal").calculate_commentstring()
                            or vim.bo.commentstring
                    end,
                },
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    -- Toggle comment (like `gcip` - comment inner paragraph) for both
                    -- Normal and Visual modes
                    comment = 'gc',

                    -- Toggle comment on current line
                    comment_line = '<Leader>cc',

                    -- Toggle comment on visual selection
                    comment_visual = 'gc',

                    -- Define 'comment' textobject (like `dgc` - delete whole comment block)
                    -- Works also in Visual mode if mapping differs from `comment_visual`
                    textobject = 'gc',
                },
            })
            require("mini.pairs").setup()
            -- require("mini.bracketed").setup()
            require("mini.align").setup({
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    start = '<Leader>a',
                    start_with_preview = 'gA',
                },
            })

            -- Smooth scrolling (replacement for snacks.scroll)
            local animate = require("mini.animate")
            animate.setup({
                cursor = { enable = false },
                scroll = {
                    enable = true,
                    timing = animate.gen_timing.linear({ duration = 200, unit = "total" }),
                },
                resize = { enable = false },
                open = { enable = false },
                close = { enable = false },
            })

            -- Git diff: signs + hunk actions (replaces gitsigns.nvim)
            require("mini.diff").setup({
                view = {
                    style = "sign",
                    signs = { add = "+", change = "~", delete = "_" },
                },
                mappings = {
                    -- `gh` is already used for "search current word" in normal mode
                    apply = "",
                    reset = "",
                    textobject = "gh",
                    -- Only expose the guarded ]c / [c mappings below
                    goto_first = "",
                    goto_prev = "",
                    goto_next = "",
                    goto_last = "",
                },
            })

            local function mini_diff_data()
                local ok, diff = pcall(require, "mini.diff")
                if not ok then return nil end
                return diff.get_buf_data(0)
            end

            local function hunk_range_under_cursor()
                local data = mini_diff_data()
                if not data then return nil end
                local lnum = vim.fn.line(".")
                local hunks = data.hunks or {}

                -- Exact buffer range (also handles "add" and "change" hunks)
                for _, hunk in ipairs(hunks) do
                    local from, to
                    if hunk.buf_count > 0 then
                        from, to = hunk.buf_start, hunk.buf_start + hunk.buf_count - 1
                    else
                        from = math.max(hunk.buf_start, 1)
                        to = from
                    end
                    if lnum >= from and lnum <= to then return from, to end
                end

                -- A "delete" hunk has no buffer lines; accept the line below it too.
                for _, hunk in ipairs(hunks) do
                    if hunk.buf_count == 0 then
                        local from = math.max(hunk.buf_start, 1)
                        if lnum == from + 1 then return from, from end
                    end
                end
            end

            local function do_hunk(action)
                local from, to = hunk_range_under_cursor()
                if not from then
                    vim.notify("No hunk under cursor", vim.log.levels.INFO)
                    return
                end
                require("mini.diff").do_hunks(0, action, { line_start = from, line_end = to })
            end

            local function do_visual_hunks(action)
                local from, to = vim.fn.line("v"), vim.fn.line(".")
                if from > to then from, to = to, from end
                vim.cmd("normal! \27")
                if not mini_diff_data() then
                    vim.notify("Buffer is not under git", vim.log.levels.INFO)
                    return
                end
                require("mini.diff").do_hunks(0, action, { line_start = from, line_end = to })
            end

            vim.keymap.set("n", "<leader>gs", function() do_hunk("apply") end, { desc = "Stage hunk" })
            vim.keymap.set("x", "<leader>gs", function() do_visual_hunks("apply") end, { desc = "Stage hunks" })
            vim.keymap.set("n", "<leader>gr", function() do_hunk("reset") end, { desc = "Reset hunk" })
            vim.keymap.set("x", "<leader>gr", function() do_visual_hunks("reset") end, { desc = "Reset hunks" })

            vim.keymap.set("n", "<leader>gS", function()
                if not mini_diff_data() then
                    vim.notify("Buffer is not under git", vim.log.levels.INFO)
                    return
                end
                require("mini.diff").do_hunks(0, "apply")
            end, { desc = "Stage buffer" })

            vim.keymap.set("n", "<leader>gc", function()
                if not mini_diff_data() then return end
                vim.fn.setqflist(require("mini.diff").export("qf", { scope = "current" }))
            end, { desc = "Hunks to quickfix" })

            vim.keymap.set("n", "<leader>gp", function()
                if not mini_diff_data() then return end
                require("mini.diff").toggle_overlay(0)
            end, { desc = "Toggle diff overlay" })

            local function goto_hunk(direction)
                if vim.wo.diff then
                    vim.cmd("normal! " .. (direction == "next" and "]c" or "[c"))
                    return
                end
                if not mini_diff_data() then return end
                pcall(require("mini.diff").goto_hunk, direction)
            end

            vim.keymap.set("n", "]c", function() goto_hunk("next") end, { desc = "Next hunk" })
            vim.keymap.set("n", "[c", function() goto_hunk("prev") end, { desc = "Previous hunk" })

            -- Keep gitsigns' max_file_length: don't diff huge files
            vim.api.nvim_create_autocmd("BufReadPost", {
                group = vim.api.nvim_create_augroup("mini_diff_large_files", { clear = true }),
                callback = function(args)
                    if vim.api.nvim_buf_line_count(args.buf) <= 5000 then return end
                    vim.b[args.buf].minidiff_disable = true
                    pcall(function() require("mini.diff").disable(args.buf) end)
                end,
            })

            -- Sessions (replaces auto-session): one global session per cwd
            vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"

            local sessions = require("mini.sessions")
            sessions.setup({
                autoread = false,  -- handled below, per cwd
                autowrite = false, -- handled below, per cwd
                directory = vim.fn.stdpath("data") .. "/sessions",
                file = "", -- don't create Session.vim in project roots
                verbose = { read = false, write = false, delete = true },
                hooks = {
                    post = {
                        read = function()
                            -- Refresh LSP / treesitter after restoring a session
                            vim.defer_fn(function()
                                if vim.bo.buftype == "" then pcall(vim.cmd, "edit") end
                            end, 100)
                        end,
                    },
                },
            })

            if vim.g.mini_sessions_autosave == nil then vim.g.mini_sessions_autosave = true end
            if vim.g.mini_sessions_autorestore == nil then vim.g.mini_sessions_autorestore = true end

            -- Same escaping as auto-session, so existing session files still work
            local function percent_encode(str)
                return (str:gsub("([/\\:*?\"'<>+ |%.%%])", function(c)
                    return string.format("%%%02X", string.byte(c))
                end))
            end

            local function percent_decode(str)
                return (str:gsub("%%(%x%x)", function(hex)
                    return string.char(tonumber(hex, 16))
                end))
            end

            local function cwd_session_name()
                local cwd = vim.fn.getcwd(-1, -1)
                if cwd ~= "/" then cwd = cwd:gsub("(.)/$", "%1") end
                return percent_encode(cwd) .. ".vim"
            end

            local function current_session_name()
                if vim.v.this_session ~= "" then
                    return vim.fn.fnamemodify(vim.v.this_session, ":t")
                end
                return cwd_session_name()
            end

            local function save_session()
                sessions.write(current_session_name(), { force = true, verbose = true })
            end

            local function toggle_autosave()
                vim.g.mini_sessions_autosave = not vim.g.mini_sessions_autosave
                vim.notify("Session autosave " .. (vim.g.mini_sessions_autosave and "on" or "off"))
            end

            local function select_session()
                local items = {}
                for name, data in pairs(sessions.detected) do
                    items[#items + 1] = {
                        name = name,
                        label = vim.fn.fnamemodify(percent_decode((name:gsub("%.vim$", ""))), ":~"),
                        time = data.modify_time,
                    }
                end
                if #items == 0 then
                    vim.notify("No sessions found", vim.log.levels.INFO)
                    return
                end
                table.sort(items, function(a, b) return a.time > b.time end)
                vim.ui.select(items, {
                    prompt = "Session",
                    format_item = function(item) return item.label end,
                }, function(item)
                    if item ~= nil then sessions.read(item.name, { force = false }) end
                end)
            end

            vim.keymap.set("n", "<leader>wr", select_session, { desc = "Session search" })
            vim.keymap.set("n", "<leader>ws", save_session, { desc = "Save session" })
            vim.keymap.set("n", "<leader>wa", toggle_autosave, { desc = "Toggle session autosave" })

            local session_group = vim.api.nvim_create_augroup("mini_sessions_cwd", { clear = true })

            vim.api.nvim_create_autocmd("VimLeavePre", {
                group = session_group,
                callback = function()
                    if not vim.g.mini_sessions_autosave then return end
                    pcall(sessions.write, current_session_name(), { force = true, verbose = false })
                end,
            })

            local function nothing_shown()
                if vim.fn.argc() > 0 then return false end
                local listed = vim.tbl_filter(function(buf)
                    return vim.fn.buflisted(buf) == 1
                end, vim.api.nvim_list_bufs())
                if #listed > 1 then return false end
                if vim.bo.filetype ~= "" then return false end
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                if #lines > 1 then return false end
                return #lines == 0 or lines[1] == ""
            end

            vim.api.nvim_create_autocmd("VimEnter", {
                group = session_group,
                callback = function()
                    if not vim.g.mini_sessions_autorestore then return end
                    vim.schedule(function()
                        if not nothing_shown() then return end
                        local name = cwd_session_name()
                        if sessions.detected[name] then
                            pcall(sessions.read, name, { force = true })
                        end
                    end)
                end,
            })

            -- Delete buffer without changing window layout
            require("mini.bufremove").setup()
            vim.keymap.set("n", "<leader>d", function()
                require("mini.bufremove").delete(0, false)
            end, { desc = "Close buffer" })
            vim.keymap.set("n", "<leader>D", function()
                require("mini.bufremove").delete(0, true)
            end, { desc = "Force close buffer" })
		end,
	}
