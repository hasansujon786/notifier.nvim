local utils = {}

utils.if_nil = function(x, was_nil, was_not_nil)
  if x == nil then
    return was_nil
  else
    return was_not_nil
  end
end

utils.get_default = function(x, default)
  return utils.if_nil(x, default, x)
end

utils.get_border = function(title, width, title_pos)
  local top = '╭' .. string.rep('─', width - 2) .. '╮'
  local mid = '│' .. string.rep(' ', width - 2) .. '│'
  local bot = '╰' .. string.rep('─', width - 2) .. '╯'
  if title then
    if title_pos == 'center' or title_pos == '' then
      local even_space = string.len(title) % 2
      local pad = (width - string.len(title) - 1)/2
      top = '╭' .. string.rep('─', pad) .. title .. string.rep('─', pad - even_space) .. '╮'
    elseif title_pos == 'right' then
      top = '╭' .. string.rep('─', width - (3 + string.len(title))) .. title .. '─╮'
    end
  end

  return { top=top , mid=mid, bot=bot}
end

utils.runUserAutocmdLoaded = function()
  vim.cmd'do User NotifierNotificationLoaded'
end

return utils
