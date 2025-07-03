--------------------------------------------------------------------------------
-- Better QuickFix plugin proto
-- TODO:
-- Move to a plugin & refactor - DONE
-- CDO templates replace - DONE
-- Add vim grep bind and capture search val
---- M.last_search or histget input or "/ ??
-- CDO templates generic
-- -- Refactor whatever mess we have there now lol
-- -- Add template tokens for state (Ex. last grep)
-- Organize/ restructure module
-- vim.opt.winbar = 'TEST' How do we change the winbar only for clist window
-- Take in custom key mappings on setup
-- Reenable default setup on load
-- kaymap/ usage help ?maybe?
-- Signs are too jittery when sign col toggles/ maybe change over to line highlight?? Disabled for now.
-- -- fix sign jitter ?maybe?
--
-- SNIPPETS:
-- local function register_signs()
--   vim.cmd("sign define QFmatch text=")
--
-- 	vim.api.nvim_create_user_command(
-- 		"QFMarkCurrentLine",
-- 		'exe "sign place 1 name=QFmatch group=QFMatches line="..line(".")',
-- 		{}
-- 	)
--
-- 	vim.api.nvim_create_user_command("QFUnMarkAll", "sign unplace * group=QFMatches", {})
-- end
-- ":cnext<CR>zz:QFUnMarkAll<CR>:QFMarkCurrentLine<CR><C-w>w",
-- ":cprev<CR>zz:QFUnMarkAll<CR>:QFMarkCurrentLine<CR><C-w>w",
--------------------------------------------------------------------------------
local M = {}
local UI = require("quickfix_actually.ui")
local cdo_templates = require("quickfix_actually.default_templates")

local function nav_c(cmd)
	local succsess, result = pcall(vim.cmd, cmd)

	if not succsess then
		return
	end

	vim.cmd("norm zz")
	vim.cmd("wincmd w")
end

local function nav_cnext()
	nav_c("cnext")
end

local function nav_cprev()
	nav_c("cprev")
end

local function csave()
	vim.cmd("cgetbuffer")
	vim.cmd("cclose")
	vim.cmd("copen")
end

local ccommands = {
	-- Probably should remove this table and just inline those, this being interpreted and all -\_(._.)_/-
	fdo = ":cfdo ",
	cdo = ":cdo ",
	save = " | update",
	find_replace = "s///",
}

local function build_command(template)
	local command = ""

	local function append_command(token)
		command = command .. token
	end

	for _, token in ipairs(template) do
		if token.type == "input" then
			vim.ui.input({
				prompt = token.prompt,
			}, append_command)
		else
			append_command(token)
		end
	end

	return command
end

local function send_to_cmd_hist(command_string)
	vim.fn.histadd("cmd", command_string)
	vim.fn.feedkeys("q:")
end

local function replace_mode()
	send_to_cmd_hist(build_command(cdo_templates.replace_confirm))
end

function M.register_global_key_bindings()
	vim.keymap.set("n", "<LEADER>qo", ":copen<CR>", { desc = "Open BetterQuickfix List", silent = true })
end

local default_mappings = {
	["J"] = { nav_cnext, "Preview next item in list" },
	["K"] = { nav_cprev, "Preview previous item in list" },
	["H"] = { ":colder<CR>", "Goto previous quickfix list" },
	["L"] = { ":cnewer<CR>", "Goto next quickfix list" },
	["i"] = { ":set modifiable<CR>", "Enter edit mode to update list" },
	["r"] = { replace_mode, "Replace accross list items" },
	["e"] = { UI.execute_template_ui, "" },
	-- { "R", cdo_templates.replace },
	["<C-s>"] = { csave, "Save list modifications" },
}

HELP_MAPPING = "<C-h>"
default_mappings[HELP_MAPPING] = {
	function()
		UI.help_ui(default_mappings)
	end,
	"This help",
}
local HELP_TEXT = "Press " .. HELP_MAPPING .. " for help ..."

local function better_qf_keys()
	local cur_buf = vim.api.nvim_get_current_buf()
	local opt = { remap = true, buffer = cur_buf }
	for mapping, meta in pairs(default_mappings) do
		print(mapping, meta[1])
		vim.keymap.set("n", mapping, meta[1], opt)
	end
end

local function qf_open_setup()
	better_qf_keys()
	local cur_title = vim.w["quickfix_title"] or ""
	vim.cmd('let w:quickfix_title="' .. cur_title .. " " .. HELP_TEXT .. '"')
end

function M.setup_autocommands()
	vim.api.nvim_create_autocmd({
		"FileType",
	}, {
		pattern = { "qf" },
		callback = qf_open_setup,
	})
end

if vim.g.quickfix_actually_debug then
	function M.test()
		vim.cmd('echo "QF Actually TEST call!"')
	end
end

return M
