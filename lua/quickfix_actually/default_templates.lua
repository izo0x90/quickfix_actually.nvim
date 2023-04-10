local M = {}

-- I guess duplication better here than deepcopy and mutate
M.replace         = { "cdo ", "s/",
                      { type = "input", prompt = "Search for >"},
                      "/",
                      { type = "input", prompt = "Replace with >" },
                      "/ | update"
                   }

M.replace_confirm = { "cdo ", "s/",
                      { type = "input", prompt = "Search for >" },
                      "/",
                      { type = "input", prompt = "Replace with >" },
                      "/c | update"
                   }

return M
