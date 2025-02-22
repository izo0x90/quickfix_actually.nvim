
local Template = {
  test_template = {
    "cdo s/{{search_for}}/{{replace_with}}/c | update"
  },
  arg_pattern = "{{.-}}"
}

function Template.test(value)
  print(value)
end

function Template.load(template_lines)
  template = {
    lines = {},
    arg_positions = {}
  }

  print(template_lines, "LINES")

  for row, line in ipairs(template_lines) do
    local prev_arg_len = 0
    local match_start, match_end = string.find(line, Template.arg_pattern)

    while match_start ~= nil do
      print("Pos: ", match_start, match_end, string.sub(line, match_start, match_end))
      arg_postion = {
        row = row,
        col = match_start - prev_arg_len
      }
      table.insert(template.arg_positions, arg_postion)
      prev_arg_len = match_end - match_start
      match_start, match_end = string.find(line, Template.arg_pattern, match_end)
    end

    updated_line = string.gsub(line, Template.arg_pattern, " _ ")
    table.insert(template.lines, updated_line)
  end

  return template
end

return Template



