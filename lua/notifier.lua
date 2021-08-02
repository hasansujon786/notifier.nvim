local utils = require('notifier.utils')

local M = {}
local fn = {}
local state = {
  prev_win_row = 0,
  open_win_count = 0
}

M.notify = function(message, config)
  if not config then
    config = {}
  end
  local title = utils.get_default(config.title, nil)
  local title_pos = utils.get_default(config.title_pos, 'right')
  local visible_time = utils.get_default(config.close_after, 3000)
  local width = 40
  local height = vim.tbl_count(message) + 2
  local border = utils.get_border(title, width, title_pos)

  local lines = {border.top}
  for _ = 1, height - 2, 1 do
    table.insert(lines, border.mid)
  end
  table.insert(lines, border.bot)

  -- Create the scratch buffer displayed in the floating window
  local bufnr = vim.api.nvim_create_buf(false, true)
  -- set the box in the buffer
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Create the lines for the message and put them in the buffer
  local start_col = 1 + 3
  for idx, line in ipairs(message) do
    vim.api.nvim_buf_set_text(bufnr, idx, start_col, idx, string.len(line) + start_col, {line})
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
    zindex = 300,
  }
  state.prev_win_row = state.prev_win_row + height

  -- set buffer option
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'Notifier')
  vim.api.nvim_buf_set_option(bufnr, 'readonly', true)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)

  local winId = vim.api.nvim_open_win(bufnr, false, opts)
  -- set window option
  vim.api.nvim_win_set_option(winId, 'winhl', 'Normal:NotifierDefault')
  vim.api.nvim_win_set_option(winId, 'sidescrolloff', 0)

  utils.runUserAutocmdLoaded()
  state.open_win_count = state.open_win_count + 1
  vim.defer_fn(function ()
    fn.close(winId)
  end, visible_time)
end

M.alert = function (message, config)
  if not config then
    config = {}
  end
  local title = utils.get_default(config.title, '')
  local title_pos = utils.get_default(config.title_pos, 'center')
  local width = 40
  local height = 10
  -- local height = vim.tbl_count(message) + 2
  local border = utils.get_border(title, width, title_pos)

  local lines = {border.top}
  for _ = 1, height - 2, 1 do
    table.insert(lines, border.mid)
  end
  table.insert(lines, border.bot)

  -- Create the scratch buffer displayed in the floating window
  local bufnr = vim.api.nvim_create_buf(false, true)
  -- set the box in the buffer
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Create the lines for the message and put them in the buffer
  for idx, line in ipairs(message) do
    local start_col = math.floor((width - string.len(line) + 4)/2)
    local current_row = idx + 2
    local end_col = string.len(line) + start_col
    vim.api.nvim_buf_set_text(bufnr, current_row, start_col, current_row, end_col, {line})
  end

  -- Create the floating window
  local ui = vim.api.nvim_list_uis()[1]
  local opts = {
    relative= 'editor',
    width= width,
    height= height,
    col= (ui.width/2) - (width/2),
    row= (ui.height/2) - (height/2),
    anchor= 'NW',
    style= 'minimal',
    zindex = 300,
  }

  -- set buffer options
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'Notifier')
  vim.api.nvim_buf_set_option(bufnr, 'readonly', true)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)

  local winId = vim.api.nvim_open_win(bufnr, false, opts)
  -- set windows options
  vim.api.nvim_win_set_option(winId, 'winhl', 'Normal:NotifierDefault')
  vim.api.nvim_win_set_option(winId, 'sidescrolloff', 0)

  -- Set mappings in the buffer to close the window easily
  local closingKeys = { '<Esc>', '<CR>', '<Leader>', 'q' }
  for _, key in ipairs(closingKeys) do
    vim.api.nvim_buf_set_keymap(bufnr, 'n', key, ':close<CR>', {silent= true, nowait= true, noremap= true})
  end

  utils.runUserAutocmdLoaded()
end

fn.close = function(winId)
  vim.api.nvim_win_close(winId, true)
  state.open_win_count = state.open_win_count - 1
  if state.open_win_count < 1 then
   state.prev_win_row = 0
  end
end

-- lua require('notifier').notify({'helo'})
-- lua require('notifier').notify({'helo'}, {title = 'test', title_pos = 'center'})
-- lua require('notifier').alert({'helo'}, {title = 'test'})
-- function! breakhabits#createmappings(keys, message) abort
--     for key in a:keys
--         call nvim_set_keymap('n', key, ':call BreakHabitsWindow(' . string(a:message). ')<CR>', {'silent': v:true, 'nowait': v:true, 'noremap': v:true})
--     endfor
-- endfunction
-- https://www.statox.fr/posts/vim/breaking_habits_floating_window/
-- TODO: improved only

return M
