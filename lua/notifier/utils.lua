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

-- split_into_tokens will wrap the provided string into tokens, that means
-- every word will be a token.
--
-- @param str The string to be splitted
-- @return table
utils.split_into_tokens = function(str)
  local tokens = {}
  for word in str:gmatch('%S+') do
    tokens[#tokens+1] = word
  end

  return tokens
end

-- wrap_text will wrap the provided string based on the provided length.
--
-- @param text The string to be wrapped
-- @param line_length Where the string should break
-- @return table
utils.wrap_text = function(text, line_length)
    if not line_length then
        line_length = 80
    end

    local spaceleft = line_length
    local wrapped_text = {}
    local line = {}

    for _, word in ipairs(utils.split_into_tokens(text)) do
        if #word + 1 > spaceleft then
            table.insert(wrapped_text, table.concat(line, ' '))
            line = {word}
            spaceleft = line_length - #word
        else
            table.insert(line, word)
            spaceleft = spaceleft - (#word + 1)
        end
    end

    table.insert(wrapped_text, table.concat(line, ' '))
    return wrapped_text
end

return utils
