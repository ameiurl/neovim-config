return {
    -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "ameiurl/friendly-snippets",
    },
    config = function()

        local cmp_status_ok, cmp = pcall(require, 'cmp')
        if not cmp_status_ok then
            print("Couldn't load 'cmp'")
            return
        end

        local status_ok, luasnip = pcall(require, 'luasnip')
        if not status_ok then
            print("Couldn't load 'luasnip'")
            return
        end

        require('luasnip.loaders.from_vscode').lazy_load()

        local extensions = {
            ruby = {
                "jekyll",
                "rails",
            },
            javascript = {
                "jsdoc",
            },
            cpp = {
                "unreal",
            },
        }

        for lang, tbl in pairs(extensions) do
            luasnip.filetype_extend(lang, tbl)
        end

        local kind_icons = {
            Class         = ' ',
            Color         = ' ',
            Constant      = ' ',
            Constructor   = ' ',
            Enum          = ' ',
            EnumMember    = ' ',
            -- Event         =  '',
            Event         = " ",
            Field         = ' ',
            File          = ' ',
            Folder        = ' ',
            Function      = ' ',
            Interface     = ' ',
            Keyword       = ' ',
            Method        = ' ',
            Module        = ' ',
            -- Operator      =  '',
            Operator      = "󰆕 ",
            Property      = ' ',
            Reference     = ' ',
            -- Snippet       =  '﬍',
            Snippet       = " ",
            -- Struct        =  '',
            Struct        = " ",
            Text          = ' ',
            TypeParameter = '𝙏 ',
            Unit          = ' ',
            Value         = ' ',
            Variable      = ' ',
        }

        cmp.setup {
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            window = {
                -- completion = {
                --   border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                --   scrollbar = "║",
                --   winhighlight = 'Normal:CmpMenu,FloatBorder:CmpMenuBorder,CursorLine:CmpSelection,Search:None',
                --   autocomplete = {
                --     require("cmp.types").cmp.TriggerEvent.InsertEnter,
                --     require("cmp.types").cmp.TriggerEvent.TextChanged,
                --   },
                -- },
                documentation = {
                    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                    -- winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
                    scrollbar = "║",
                },
            },

            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                -- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping({
                    i = cmp.mapping.abort(),
                    c = cmp.mapping.close(),
                }),

                -- Accept currently selected item.
                -- Set `select` to `false` to only confirm explicitly selected items.
                ['<CR>'] = cmp.mapping.confirm({ select = true }),

                -- Supertab
                ['<Tab>'] = cmp.mapping(function(fallback)

                    local has_words_before = function()
                        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
                    end

                    local check_backspace = function()
                        local col = vim.fn.col '.' - 1
                        return col == 0 or vim.fn.getline('.'):sub(col, col):match "%s"
                    end

                    if cmp.visible() then
                        -- cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        cmp.mapping.confirm({
                            behavior = cmp.ConfirmBehavior.Replace,
                            select = true,
                        })()
                    elseif luasnip.expandable() then
                        luasnip.expand()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    elseif check_backspace() then
                        fallback()
                    else
                        fallback()
                    end
                end, {'i', 's'}),

                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, {'i', 's'}),
            }),

            formatting = {
                fields = { 'kind', 'abbr', 'menu' },
                format = function(entry, vim_item)
                    -- Kind icons
                    vim_item.kind = string.format("%s", kind_icons[vim_item.kind])

                    vim_item.menu = ({
                        nvim_lsp = '[LSP]',
                        nvim_lua = '[NvimLua]',
                        luasnip  = '[LuaSnip]',
                        buffer   = '[Buffer]',
                        path     = '[Path]',
                    })[entry.source.name]

                    return vim_item
                end,
            },

            sources = {
                { name = 'luasnip', options = { show_autosnippets = true } },
                { name = 'nvim_lsp' },
                { name = 'nvim_lsp_signature_help' },
                { name = 'nvim_lua' },
                { name = 'buffer' },
                { name = 'path' },
            },

            confirm_opts = {
                behavior = cmp.ConfirmBehavior.Replace,
                select = false,
            },

            experimental = {
                ghost_text = true,
                native_menu = false,
            },
        }

        cmp.setup.cmdline('/', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' },
            },
        })

        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'cmdline' }
            }, {
                    { name = 'path' }
                }),
        })
    end,
}
