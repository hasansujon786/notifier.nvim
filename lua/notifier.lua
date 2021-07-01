local utils = require('notifier.utils')

local M = {}
local fn = {}
local state = {
  prev_win_row = 0,
  open_win_count = 0
}

M.open = function(message, config)
  if not config then
    config = {}
  end
  local title = utils.get_default(config.title, nil)
  local visible_time = utils.get_default(config.visible_time, 3000)
  local width = title and string.len(config.title) + 8 or 40
  local height = vim.tbl_count(message) + 2
  local top = '╭' .. string.rep('─', width - 2) .. '╮'
  local mid = '│' .. string.rep(' ', width - 2) .. '│'
  local bot = '╰' .. string.rep('─', width - 2) .. '╯'
  if title then
    top = '╭' .. string.rep('─', width - (8 + string.len(config.title))) .. '─ ' .. config.title .. ' ───╮'
    -- bot = '╰' .. string.rep('─', width - (3 + string.len(config.title))) .. config.title .. '─╯'
  end

  local lines = {top}
  for _ = 1, height - 2, 1 do
    table.insert(lines, mid)
  end
  table.insert(lines, bot)

  -- Create the scratch buffer displayed in the floating window
  local buf = vim.api.nvim_create_buf(false, true)
  -- set the box in the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Create the lines for the message and put them in the buffer
  local start_col = 1 + 3
  for idx, line in ipairs(message) do
    vim.api.nvim_buf_set_text(buf, idx, start_col, idx, string.len(line) + start_col, {line})
  end

  -- Create the floating window
  local ui = vim.api.nvim_list_uis()[1]
  local opts = {
    relative= 'editor',
    width= width,
    height= height,
    col= (ui.width) - 1,
    row= (ui.height) - 3 - state.prev_win_row,
    anchor= 'SE',
    style= 'minimal',
 }
  state.prev_win_row = state.prev_win_row + height
  local winId = vim.api.nvim_open_win(buf, false, opts)

  -- Change highlighting & window options
  vim.api.nvim_win_set_option(winId, 'winhl', 'Normal:NotifierDefault')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'Notifier')

  utils.runUserAutocmdLoaded()
  state.open_win_count = state.open_win_count + 1
  vim.defer_fn(function ()
    fn.close(winId)
  end, visible_time)
end

fn.close = function(winId)
  vim.api.nvim_win_close(winId, true)
  state.open_win_count = state.open_win_count - 1
  if state.open_win_count < 1 then
   state.prev_win_row = 0
  end
end

-- lua require('notifier').open({'helo'})
-- lua require('notifier').open({'helo'}, {title = 'test'})

return M
