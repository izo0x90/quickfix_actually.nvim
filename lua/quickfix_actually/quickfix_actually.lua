--------------------------------------------------------------------------------
-- Better QuickFix plugin proto
-- TODO:
-- Move to a plugin & refactor - DONE
-- CDO templates generic
-- CDO templates replace
-- Take in custom key mappings on setup
-- Reenable default setup on load
-- kaymap/ usage help ?maybe?
-- fix sign jitter ?maybe?
--------------------------------------------------------------------------------
local M = {}

local function nav_c(cmd)
  local succsess, result = pcall(vim.cmd, cmd)
  
  if not succsess then
    return
  end

  vim.cmd('norm zz')
  vim.cmd('wincmd w')
end

local function nav_cnext()
  nav_c('cnext')
end

local function nav_cprev()
  nav_c('cprev')
end

local function csave()
  vim.cmd("cgetbuffer")
  vim.cmd("cclose")
  vim.cmd("copen")
end

local function better_qf_keys()
  vim.opt.winbar = 'TEST'
  local cur_buf = vim.api.nvim_get_current_buf()
  vim.keymap.set(
    "n",
    "J",
    -- ":cnext<CR>zz:QFUnMarkAll<CR>:QFMarkCurrentLine<CR><C-w>w",
    nav_cnext,
    { remap = false, buffer = cur_buf }
  )
  vim.keymap.set(
    "n",
    "K",
    -- ":cprev<CR>zz:QFUnMarkAll<CR>:QFMarkCurrentLine<CR><C-w>w",
    nav_cprev,
    { remap = false, buffer = cur_buf }
  )
  vim.keymap.set("n", "H", ":colder<CR>", { remap = false, buffer = cur_buf })
  vim.keymap.set("n", "L", ":cnewer<CR>", { remap = false, buffer = cur_buf })
  vim.keymap.set("n", "i", ":set modifiable<CR>", { remap = false, buffer = cur_buf })
  vim.keymap.set("n", "<C-s>", csave, { remap = false, buffer = cur_buf })
end

-- TODO: Signs are too jittery when sign col toggles/ maybe change over to line highlight. Disabled for now
local function register_signs()
  vim.cmd("sign define QFmatch text=")

	vim.api.nvim_create_user_command(
		"QFMarkCurrentLine",
		'exe "sign place 1 name=QFmatch group=QFMatches line="..line(".")',
		{}
	)

	vim.api.nvim_create_user_command("QFUnMarkAll", "sign unplace * group=QFMatches", {})
end

function M.register_global_key_bindings()
	vim.keymap.set("n", "<LEADER>qo", ":copen<CR>", { desc = "Open BetterQuickfix List", silent = true })
end

function M.init()
  -- Add grep output format to change/ quickfix list
  -- Why would parsing edited qfix list not be default, I would really like to hear the reasoning here
	vim.go.errorformat = vim.go.errorformat .. ",%f|%l col %c|%m"

	vim.api.nvim_create_autocmd(
		{
			"FileType",
		},
		{
			pattern = { "qf" },
			callback = better_qf_keys,
		}
	)
end

if vim.g.quickfix_actually_debug then
  function M.test()
    vim.cmd('echo "TEST"')
  end
end

return M
