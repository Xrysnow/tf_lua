--
local M = {}
local lib = require('tf._c_api')
M._lib = lib
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
        error(("invalid data type %d"):format(ty))
    end
    return ty
end

return M
