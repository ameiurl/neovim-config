require 'user.settings.vim-options'
require 'user.settings.keymaps'

require('user.settings.buffer-augroups').setup()

--require('user.settings.colorscheme').setup { scheme = 'zephyr' }
-- require('user.settings.colorscheme').setup { scheme = 'one-nvim' }
require('user.settings.colorscheme').setup { scheme = 'onedark' }
