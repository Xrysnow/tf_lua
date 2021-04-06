---@class tf.TFCheckpointReader
--- TF_NewCheckpointReader() return the CheckpointReader that can be use to
--- investigate or load the variable from the checkpoint file
local M = class('tf.TFCheckpointReader')
local libex = require('tf.c._c_api_experimental')
local Status = require('tf.c.TFStatus')
local base = require('tf.base')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end

function M:dtor()
    libex.TF_DeleteCheckpointReader(self.handle)
    self.handle = nil
end

---@param name string
function M:hasTensor(name)
    return libex.TF_CheckpointReaderHasTensor(self.handle, name) > 0
end

--- Get the variable name at the given index
---@param index number
function M:getVariableName(index)
    local p = libex.TF_CheckpointReaderGetVariable(self.handle, index)
    return ffi.string(p)
end

--- Get the number of variable in the checkpoint
---@return number
function M:size()
    return tonumber(libex.TF_CheckpointReaderSize(self.handle))
end

--- Get the number of variable in the checkpoint
---@return number
function M:getVariableCount()
    return self:size()
end

--- Get the DataType of a variable
---@param name string
function M:getVariableDataType(name)
    return libex.TF_CheckpointReaderGetVariableDataType(self.handle, name)
end

--- Get the number of dimension of a variable
---@param name string
function M:getVariableNumDims(name)
    return tonumber(libex.TF_CheckpointReaderGetVariableNumDims(self.handle, name))
end

--- Read the shape of a variable
---@param name string
function M:getVariableShape(name)
    local ndim = self:getVariableNumDims(name)
    if ndim == 0 then
        -- scalar
        return {}
    end
    local dims = ffi.new('int64_t[?]', ndim)
    local s = Status()
    libex.TF_CheckpointReaderGetVariableShape(self.handle, name, dims, ndim, handle(s))
    s:assert()
    return base.unpackDims(dims, ndim)
end

--- Load the weight of a variable
---@param name string
function M:getTensor(name)
    if not self:hasTensor(name) then
        return nil
    end
    local s = Status()
    local p = libex.TF_CheckpointReaderGetTensor(self.handle, name, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return require('tf.c.TFTensor')(p)
end

---@param filename string
function M.Create(filename)
    local s = Status()
    local p = libex.TF_NewCheckpointReader(filename, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

return M
