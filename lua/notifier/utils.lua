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

utils.runUserAutocmdLoaded = function()
  vim.cmd'do User NotifierNotificationLoaded'
end

return utils
