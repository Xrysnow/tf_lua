---@class tf.TFAttrBuilder
--- TF_NewAttrBuilder() returns an object that you can set attributes on as
--- though it were an op. This allows querying properties of that op for
--- type-checking purposes like if the op will run on a particular device type.
local M = class('tf.TFAttrBuilder')
local libex = require('tf.c._c_api_experimental')
local Status = require('tf.c.TFStatus')
local base = require('tf.base')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end

function M:dtor()
    libex.TF_DeleteAttrBuilder(self.handle)
    self.handle = nil
end

---@param attr_name string
---@param value TF_DataType
function M:setType(attr_name, value)
    libex.TF_AttrBuilderSetType(self.handle, attr_name, value)
end

---@param attr_name string
---@param values TF_DataType[]
function M:setTypeList(attr_name, values)
    local v, n = base.packDataTypes(values)
    libex.TF_AttrBuilderSetType(self.handle, attr_name, v, n)
end

--- Checks the tensorflow::NodeDef built via the methods above to see if it can
--- run on device_type.
---@param device_type string
function M:checkCanRunOnDevice(device_type)
    local s = Status()
    libex.TF_AttrBuilderCheckCanRunOnDevice(self.handle, device_type, handle(s))
    return s
end

---@param op_name string
function M.Create(op_name)
    local p = libex.TF_NewAttrBuilder(op_name)
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

return M
