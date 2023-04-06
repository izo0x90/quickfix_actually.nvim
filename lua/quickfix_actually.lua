local M = {}
local core = require("quickfix_actually.quickfix_actually")

vim.cmd('echo "plug ran"')
function M.setup()
  -- TODO: Customizable keybinds
  core.test()
  core.register_global_key_bindings()
	core.init()
end

-- Start with defaults
-- M.setup()
return M
