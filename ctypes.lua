---@class ctype
local M = {}
local ffi = require('ffi')

---@class ctype_v:ffi.cdata
---@field value
--

local mt = {
    __index    = function(t, k)
        if k == 'value' then
            return rawget(t, -1)[0]
        elseif type(k) == 'number' then
            return rawget(t, -1)[0][k]
        else
            return rawget(t, k)
        end
    end,
    __newindex = function(t, k, v)
        if v == None then
            v = nil
        end
        if k == 'value' then
            rawget(t, -1)[0] = v
        elseif type(k) == 'number' then
            if type(v) == 'table' and v.value then
                v = v.value
            end
            rawget(t, -1)[0][k] = v
        else
            rawset(t, k, v)
        end
    end
}
local function create(cdata, ctype)
    return setmetatable({ [-1] = cdata, [-2] = ctype }, mt)
end

---@return fun():ctype_v
local function make_cls(name, ctype)
    local ret = { ['.classname'] = 'ctypes.' .. name }
    ret.ctype = ctype
    ret.tname = name
    setmetatable(ret, {
        __call = function(_, v)
            local cdata = ffi.new(ctype .. '[1]')
            if v and v ~= None then
                cdata[0] = ffi.cast(ctype, v)
            end
            return create(cdata, ctype)
        end,
        __mul  = function(_, other)
            assert(type(other) == 'number')
            return function()
                if other < 1 then
                    other = 1
                end
                local cdata = ffi.new(('%s*[1]'):format(ctype))
                local cdata_ = ffi.new(('%s[%d]'):format(ctype, other))
                cdata[0] = cdata_
                local ret_ = create(cdata, ctype .. '*')
                ret_['.cdata'] = cdata_
                return ret_
            end
        end
    })
    return ret
end

M.c_int = make_cls('c_int', 'int32_t')
M.c_uint = make_cls('c_uint', 'uint32_t')
M.c_int64 = make_cls('c_int', 'int64_t')
M.c_uint64 = make_cls('c_uint', 'uint64_t')

M.c_size_t = make_cls('c_uint', 'uint64_t')

M.c_float = make_cls('c_float', 'float')
M.c_double = make_cls('c_double', 'double')

M.c_void_p = make_cls('c_void_p', 'void*')
M.c_bool = make_cls('c_bool', 'bool')
M.c_char_p = make_cls('c_char_p', 'const char*')

M.int = M.c_int
M.uint = M.c_uint

---@param v ctype_v
function M.byref(v)
    if isnone(v) then
        raise('ValueError', 'attempt to ref a None value')
    end
    return rawget(v, -1)
end

---@param v ctype_v
function M.byref_const(v)
    if isnone(v) then
        raise('ValueError', 'attempt to ref a None value')
    end
    local ct = rawget(v, -2)
    if string.starts_with(ct, 'const ') then
        return rawget(v, -1)
    end
    return ffi.cast('const ' .. ct .. '*', rawget(v, -1))
end

function M.POINTER(TYPE)
    return make_cls(('ctypes.pointer<%s>'):format(TYPE.tname), TYPE.ctype .. '*')
end

--function M.c_str(s)
--    return s
--end

---@param v ctype_v
---@return string
function M.str(v)
    if type(v) ~= 'cdata' then
        v = v.value
    end
    return ffi.string(v)
end

function M.c_str(s)
    return s
end

function M.cast(v, ty)
    if type(v) ~= 'cdata' then
        v = v.value
    end
    local ret = ty()
    ret.value = ffi.cast(rawget(ret, -2), v)
    return ret
end

function M.is_ctype(o)
    local t = type(o)
    if t == 'cdata' then
        return true
    elseif t == 'table' then
        if type(o.value) == 'cdata' then
            return true
        end
    end
    return false
end

local _lib

function M.call(name, ...)
    --print('C call:', name)
    local args = { ... }
    local argc = select('#', ...)
    for i = 1, argc do
        local arg = args[i]
        if arg == None then
            args[i] = nil
        elseif type(arg) == 'table' then
            if arg.value then
                args[i] = arg.value
            end
        end
    end
    return _lib[name](unpack(args, 1, argc))
end

function M.caller(lib)
    return function(name, ...)
        _lib = lib
        return M.call(name, ...)
    end
end

function M.typedef()
end
function M.enumdef()
end
function M.addDef()
end

return M
