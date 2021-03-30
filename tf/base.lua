--
local M = {}
local lib = require('tf.c._c_api')
M._lib = lib
M._libeager = require('tf.c._c_api_eager')
M._libex = require('tf.c._c_api_experimental')
M._libeagerex = require('tf.c._c_api_eager_experimental')
--- TF_Version returns a string describing version information of the
--- TensorFlow library. TensorFlow using semantic versioning.
---@return string
function M.version()
    return ffi.string(lib.TF_Version())
end

function M.dataTypeSize(dt)
    dt = M.dataType(dt)
    return lib.TF_DataTypeSize(dt)
end

function M.DataTypeSize(dt)
    return M.dataTypeSize(dt)
end

function M.packDims(dims, num_dims)
    if type(dims) == 'table' then
        num_dims = #dims
        local c_dims = ffi.new('int64_t[?]', num_dims)
        for i = 1, num_dims do
            if dims[i] == false then
                c_dims[i - 1] = -1
            else
                c_dims[i - 1] = dims[i]
            end
        end
        dims = c_dims
    elseif dims == nil then
        return nil, -1
    end
    return dims, num_dims
end

function M.unpackDims(dims, num_dims)
    if type(dims) ~= 'cdata' then
        return dims
    end
    local ret = {}
    for i = 1, num_dims do
        ret[i] = dims[i - 1]
    end
    return ret
end

function M.packValues(ctype, values, size)
    local n
    if type(values) == 'table' then
        n = size or #values
        local c_values = ffi.new(ctype .. '[?]', n)
        for i = 1, n do
            c_values[i - 1] = values[i]
        end
        values = c_values
    end
    if n == 0 then
        return nil, 0
    end
    return values, n
end

function M.packDataTypes(values, size)
    local n
    if type(values) == 'table' then
        n = size or #values
        local c_values = ffi.new('TF_DataType[?]', n)
        for i = 1, n do
            c_values[i - 1] = M.dataType(values[i])
        end
        values = c_values
    end
    return values, n
end

function M.packHandles(ctype, values)
    local n
    if type(values) == 'table' then
        n = #values
        local c_values = ffi.new(ctype .. '[?]', n)
        for i = 1, n do
            if values[i] == false then
                c_values[i - 1] = nil
            else
                c_values[i - 1] = handle(values[i])
            end
        end
        values = c_values
    end
    return values, n
end

function M.tfBool(value)
    if type(value) ~= 'number' and type(value) ~= 'cdata' then
        value = value and 1 or 0
    end
    return value
end

function M.dataType(ty)
    if type(ty) == 'string' then
        local val = require('tf._enum').TF_DataType[ty:upper()]
        assert(val, ("invalid data type %q"):format(ty))
        ty = val
    end
    return ty
end
---@return string
function M.dataTypeString(ty)
    if type(ty) ~= 'string' then
        local val = tonumber(ty)
        for k, v in pairs(require('tf._enum').TF_DataType) do
            if v == val then
                return k:lower()
            end
        end
        error(("invalid data type %s"):format(ty))
    end
    return ty
end

local _ctype_map = {
    'float', -- FLOAT
    'double', -- DOUBLE
    'int32_t', -- INT32
    'uint8_t', -- UINT8
    'int16_t', -- INT16
    'int8_t', -- INT8
    'TF_TString', -- STRING
    false, -- COMPLEX64
    false, -- COMPLEX
    'int64_t', -- INT64
    'unsigned char', -- BOOL
    false, -- QINT8
    false, -- QUINT8
    false, -- QINT32
    false, -- BFLOAT16
    false, -- QINT16
    false, -- QUINT16
    'uint16_t', -- UINT16
    false, -- COMPLEX128
    false, -- HALF
    false, -- RESOURCE
    false, -- VARIANT
    'uint32_t', -- UINT32
    'uint64_t', -- UINT64
}

function M.ctypeFromDataType(ty)
    ty = M.dataType(ty)
    return _ctype_map[tonumber(ty)]
end

return M
