local M = {}
local core = require("quickfix_actually.quickfix_actually")

vim.cmd('echo "plug ran"')
function M.setup()
  -- TODO: Customizable keybinds
  
  -- TODO: Remove debug
  core.test()
  -- END debug

  -- Add grep output format to change/ quickfix list
  -- Why would parsing edited qfix list not be default, I would really like to hear the reasoning here
	vim.go.errorformat = vim.go.errorformat .. ",%f|%l col %c|%m"

  core.register_global_key_bindings()

	core.setup_autocommands()
end

-- Start with defaults
-- M.setup()
return M
