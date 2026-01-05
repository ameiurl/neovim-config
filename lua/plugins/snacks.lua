return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile       = { enabled = true },
      dashboard     = { enabled = false },
      indent        = { enabled = false },
      input         = { enabled = false },
      notifier      = { enabled = true },
      explorer      = { enabled = false },
      picker        = {
        enabled = true,
        explorer = {
          opts = {
            win = {
              list = {
                keys = {
                  ["<c-]>"] = "explorer_cd",
                }
              }
            }
          }
        },
        previewers = {
          git = {
            native = true,
          },
        },
        win = {
          input = {
            keys = {
              ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
              ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
              ["<c-b>"] = { "list_scroll_up", mode = { "i", "n" } },
              ["<c-f>"] = { "list_scroll_down", mode = { "i", "n" } },
            },
          },
        },
      },
      quickfile     = { enabled = false },
      scroll        = { enabled = true },
      statuscolumn  = { enabled = false },
      words         = { enabled = false },
    },
    keys = {
      -- Lazygit
      { "<leader>gg",  function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gla", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
      { "<leader>glc", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },

      -- Zen
      { "<leader>z",   function() Snacks.zen({ win = { width = 200 } }) end, desc = "Zen Mode" },
      { "<leader>Z",   function() Snacks.zen.zoom() end, desc = "Zoom Mode" },

      -- Diagnostic Picker
      { "<leader>cd",  function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },

      -- Buffer management
      { "<leader>d", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>bq", function() Snacks.bufdelete.pick() end, desc = "Delete Buffer (Pick)" },
      { "<leader>bb", function() Snacks.picker.buffers() end, desc = "Pick Buffer" },

      -- Projects
      { "<leader>pl", function() Snacks.picker.projects() end, desc = "Projects List" },

      -- LSP Symbols
      -- { "<leader>sf", function()
      --     Snacks.picker.lsp_symbols({
      --       filter = {
      --         lua = { "Class", "Function", "Module" },
      --         python = { "Class", "Function", "Constant" },
      --         php = { "Class", "Function", "Method" },
      --       },
      --     })
      --   end,
      --   desc = "Find Symbols"
      -- },

      -- Terminal
      { "<c-/>", function() Snacks.terminal() end, desc = "Terminal" },
      { "<c-_>", function() Snacks.terminal() end, desc = "which_key_ignore" },
    },
  }
}
