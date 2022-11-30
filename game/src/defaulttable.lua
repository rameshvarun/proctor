local function DefaultTable(value)
    local t = {}
    return setmetatable(t, { __index = function(t, key)
        rawset(t, key, value)
        return value
    end})
end

return DefaultTable
