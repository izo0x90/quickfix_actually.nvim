local ARG_SURROUND_L = "{{"
local ARG_SURROUND_R = "}}"

local Template = {
	test_template = {
		"cdo s/{{search_for}}/{{replace_with}}/c | update",
	},
	arg_pattern = ARG_SURROUND_L .. ".-" .. ARG_SURROUND_R,
}

function Template.test(value)
	print(value)
end

function Template.get_files()
	local dirname = string.sub(debug.getinfo(1).source, 2, string.len("/lua/quickfix_actually/ui.lua") * -1)
		.. "/plugin/templates"

	local files = {}

	for _, file in ipairs(vim.fn.readdir(dirname)) do
		if file:match("%.tmpl$") then
			table.insert(files, file)
		end
	end
	return files
end

function Template.load(template_lines)
	template = {
		lines = {},
		arg_positions = {},
	}

	table.insert(template.lines, "############### Command template ###############")

	for row, line in ipairs(template_lines) do
		local match_start, match_end = string.find(line, Template.arg_pattern)

		while match_start ~= nil do
			local len = match_end - match_start
			arg_postion = {
				row = row,
				col = match_start,
				col_end = match_end,
				len = len,
			}
			table.insert(template.arg_positions, arg_postion)
			match_start, match_end = string.find(line, Template.arg_pattern, match_end)
		end

		table.insert(template.lines, line)
	end

	for idx, arg in ipairs(template.arg_positions) do
		local arg_text = string.sub(template_lines[arg.row], arg.col, arg.col_end)
		local placeholder_text = "replace_for_"
			.. string.sub(arg_text, 1 + #ARG_SURROUND_L, arg.len - (#ARG_SURROUND_R - 1))
		-- On principal this should get changed to something more efficient lol
		table.insert(template.lines, idx, placeholder_text)
	end

	table.insert(template.lines, 1, "############### Command arguments ###############")

	return template
end

return Template
