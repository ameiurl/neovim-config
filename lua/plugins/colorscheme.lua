return {
    {
        "ameiurl/seoul256.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            -- These globals are read while the colorscheme is loaded,
            -- so set them before the plugin is sourced.
            vim.g.seoul256_italic_comments = true
            vim.g.seoul256_contrast = true
            vim.g.seoul256_hl_current_line = true
        end,
        config = function()
            -- Legacy syntax groups (used when treesitter highlighting is off).
            -- Keep them in one table instead of a long list of `:hi` commands.
            local highlights = {
                phpVarSelector = "#FFBFBD",
                phpStringSingle = "#BCDDBD",
                phpStringDouble = "#BCDDBD",
                phpFunctions = "#e2c792",
                phpMethods = "#e2c792",
                phpSpecialFunction = "#e2c792",
                phpBaselib = "#e2c792",
                phpNumber = "#e55561",
                phpFloat = "#e55561",
                htmlTag = "#98BC99",
                htmlEndTag = "#98BC99",
                javaScript = "#C8C8C8",
            }

            local function apply_highlights()
                for group, fg in pairs(highlights) do
                    vim.api.nvim_set_hl(0, group, { fg = fg })
                end

                -- The plugin still uses legacy `TSComment` for this option;
                -- mirror it to the modern treesitter group.
                if vim.g.seoul256_italic_comments then
                    local comment = vim.api.nvim_get_hl(0, { name = "@comment" })
                    if next(comment) ~= nil then
                        comment.italic = true
                        vim.api.nvim_set_hl(0, "@comment", comment)
                    end
                end
            end

            -- Re-apply after any `:colorscheme seoul256` (including reloads).
            local augroup = vim.api.nvim_create_augroup("seoul256_custom_hl", { clear = true })
            vim.api.nvim_create_autocmd("ColorScheme", {
                pattern = "seoul256",
                group = augroup,
                callback = apply_highlights,
            })

            vim.cmd.colorscheme("seoul256")
            apply_highlights()
        end,
    },
}
