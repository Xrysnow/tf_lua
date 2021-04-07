--
local getmetatable = getmetatable
local type = type

function bool(o)
    if o == None then
        return false
    end
    local ty = type(o)
    if ty == 'boolean' then
        return o
    elseif ty == 'number' then
        return o ~= 0
    elseif ty == 'cdata' then
        return o ~= 0
    elseif ty == 'nil' then
        return false
    elseif ty == 'table' then
        if getmetatable(o) == nil then
            return not table.empty(o)
        end
    end
    return true
end

function len(o)
    if type(o) == 'string' then
        return #o
    end
    local mt = getmetatable(o)
    if mt and mt.__len then
        return #o
    else
        local ret = 0
        for _, _ in pairs(o) do
            ret = ret + 1
        end
        return ret
    end
end

function setattr(t, k, v)
    t[k] = v
end

function raise(...)
    local args = { ... }
    local argc = select('#', ...)
    local str = {}
    for i = 1, argc do
        str[i] = tostring(args[i])
    end
    error(table.concat(str, '\t'))
end

function iter(o)
    if o.__iter then
        local i = o:__iter()
        if type(i) == 'function' then
            return i
        else
            local function f()
                return i:__next()
            end
            return f
        end
    else
        local i = 0
        local function f()
            i = i + 1
            return o[i]
        end
        return f
    end
end

None = setmetatable({}, {
    __tostring = function()
        return 'None'
    end,
    __index    = function()
        error('attempt to index None')
    end,
    __newindex = function()
        error('attempt to index None')
    end,
})

function with(scope, f)
    if scope.__enter then
        scope:__enter()
    end
    local ret = { f() }
    if scope.__exit then
        scope:__exit()
    end
    return unpack(ret, 1, table.maxn(ret))
end
