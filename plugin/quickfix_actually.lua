-- Title:        Quickfix Actually !
-- Description:  Some quality of life addition to quick fix lists, still keeping it vim but adding a little sanity and
--               ergonomics. It isn't the '90s and clists are used for more than chasing down cmake error dumps.
-- Last Change:  5 Apr 2023
-- Maintainer:   Hristo G. <https://github.com/izo0x90>

if vim.g.quickfix_actually_loaded == 1 then
  return
end
vim.g.quickfix_actually_loaded = 1
vim.g.quickfix_actually_debug = true -- TODO: Turn off
-- TODO: Setup user commands here
