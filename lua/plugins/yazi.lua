return {
	"mikavilpas/yazi.nvim",
	event = "VeryLazy",
	keys = {
		{
			"R",
			"<cmd>Yazi<cr>",
			desc = "Open yazi at the current file",
		},
        {
            -- Open in the current working directory
            "<leader>cw",
            "<cmd>Yazi cwd<cr>",
            desc = "Open the file manager in nvim's working directory",
        },
        {
            -- NOTE: this requires a version of yazi that includes
            -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
            "<c-up>",
            "<cmd>Yazi toggle<cr>",
            desc = "Resume the last yazi session",
        },
	},
	opts = {
		floating_window_scaling_factor = 1,
		yazi_floating_window_border = "none",
		open_for_directories = true,
		open_multiple_tabs = true,
		keymaps = {
			show_help = '<f1>',
			open_file_in_vertical_split = '<c-v>',
			open_file_in_horizontal_split = '<c-x>',
			open_file_in_tab = '<c-t>',
			grep_in_directory = '<c-f>',
			replace_in_directory = '<c-r>',
			cycle_open_buffers = '<tab>',
			copy_relative_path_to_selected_files = '<c-y>',
			send_to_quickfix_list = '<c-q>',
		},
	},
}
