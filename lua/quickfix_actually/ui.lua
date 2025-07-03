UI = {}

local Template = require("quickfix_actually.template")

local ui_state = {}

local function close_floating_window(win_meta)
	vim.api.nvim_win_close(win_meta.win, true)
	win_meta.opened = false
end

local function create_floating_window(config, enter)
	if enter == nil then
		enter = false
	end

	local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
	local win = vim.api.nvim_open_win(buf, enter or false, config)

	local win_meta = { buf = buf, win = win, opened = true }
	win_meta["close"] = function()
		close_floating_window(win_meta)
	end
	return win_meta
end

local function calc_dim(x_scale, y_scale, w, h)
	if x_scale == nil then
		x_scale = 1.0
	end

	if y_scale == nil then
		y_scale = 1.0
	end

	local vim_width = vim.o.columns
	local vim_height = vim.o.lines
	local width = w or math.floor(vim_width * x_scale)
	local height = h or math.floor(vim_height * y_scale)
	local centered_x = math.floor((vim_width - width) / 2)
	local centered_y = math.floor((vim_height - height) / 2)
	return { width = width, height = height, centered_x = centered_x, centered_y = centered_y }
end

function UI.help_ui(mappings)
	if not ui_state.help_float or not ui_state.help_float.opened then
		local help_lines = {}
		local longest = 0

		for mapping, meta in pairs(mappings) do
			local help_line_text = " " .. mapping .. " - " .. meta[2] .. " "
			table.insert(help_lines, help_line_text)
			if #help_line_text > longest then
				longest = #help_line_text
			end
		end

		local windim = calc_dim(1, 1, longest, #help_lines)

		local winopt = {
			title = "Help",
			relative = "editor",
			width = windim.width,
			height = windim.height,
			style = "minimal",
			border = "rounded",
			col = windim.centered_x,
			row = windim.centered_y,
		}

		ui_state.help_float = create_floating_window(winopt)
		vim.api.nvim_buf_set_lines(ui_state.help_float.buf, 0, -1, false, help_lines)
	else
		ui_state.help_float.close()
	end
end

local function setup_execute_template_keys(buf, mappings)
	local opt = { remap = true, buffer = buf }
	for mapping, meta in pairs(mappings) do
		print(mapping, meta[1])
		vim.keymap.set("n", mapping, meta[1], opt)
	end
end

function UI.execute_template_ui()
	local templates = Template.get_files()

	local select_template_callback = function(index, template_idx)
		if template_idx then -- Check if an item was actually selected (not canceled)
			print("You selected: " .. template_idx .. templates[template_idx])
		else
			print("Selection canceled.")
		end
	end

	-- Call vim.ui.select to display the options
	vim.ui.select(templates, { prompt = "Choose a template:" }, select_template_callback)
end

function UI.execute_template_ui_2()
	if not ui_state.execute_template_float or not ui_state.execute_template_float.opened then
		local windim = calc_dim(0.75, 0.75)
		local winopt = {
			title = "[Command editor] ",
			relative = "editor",
			width = windim.width,
			height = windim.height,
			style = "minimal",
			border = "rounded",
			focusable = true,
			col = windim.centered_x,
			row = windim.centered_y,
		}

		local lines = Template.test_template

		local template = Template.load(lines)

		-- for i, val in ipairs(template.lines) do
		--   print(i, val)
		-- end
		--
		-- for i, val in ipairs(template.arg_positions) do
		--   print(i, val.row, val.col)
		-- end
		ui_state.execute_template_float = create_floating_window(winopt, true)
		vim.api.nvim_buf_set_lines(ui_state.execute_template_float.buf, 0, -1, false, template.lines)
		setup_execute_template_keys(ui_state.execute_template_float.buf, {
			["<C-q>"] = { ui_state.execute_template_float.close, "Close without executing" },
		})
	else
		ui_state.execute_template_float.close()
	end
end

return UI
