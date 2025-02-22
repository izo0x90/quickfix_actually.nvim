UI = {}

local Template = require("quickfix_actually.template")

local function create_floating_window(config, enter)
  print("ENTER", enter)
  if enter == nil then
    enter = false
  end

  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  local win = vim.api.nvim_open_win(buf, enter or false, config)

  return { buf = buf, win = win }
end

local function calc_dim(x_scale, y_scale)
  if x_scale == nil then
    x_scale = 1.0
  end

  if y_scale == nil then
    y_scale = 1.0
  end

  local vim_width = vim.o.columns
  local vim_height = vim.o.lines
  local width = math.ceil(vim_width * x_scale)
  local height = math.ceil(vim_height * y_scale)
  local centered_x = math.ceil((vim_width - width) / 2)
  local centered_y = math.ceil((vim_height - height) / 2)
  return { width = width, height = height, centered_x = centered_x, centered_y = centered_y}
end

function UI.help_ui(mappings)
  local windim = calc_dim(1, 0.125)
  local winopt = {
    relative = "editor",
    width = windim.width,
    height = windim.height,
    style = "minimal",
    border = "rounded",
    col = windim.centered_x,
    row = 0,
  }

  local help_lines = {}
  
  for mapping, meta in pairs(mappings) do
    table.insert(help_lines, mapping .. " - " .. meta[2])
  end

  help_float = create_floating_window(winopt)
  vim.api.nvim_buf_set_lines(help_float.buf, 0, -1, false, help_lines)
end

function UI.execute_template_ui()
  local windim = calc_dim(0.75, 0.75)
  local winopt = {
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
  execute_template_float = create_floating_window(winopt, true)

  vim.api.nvim_buf_set_lines(execute_template_float.buf, 0, -1, false, template.lines)
end

return UI
