---@class tf.TFDeviceList
local M = class('tf.TFDeviceList')
local lib = require('tf.c._c_api')
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end
--- Deallocates the device list.
function M:dtor()
    lib.TF_DeleteDeviceList(self.handle)
    self.handle = nil
end
--- Counts the number of elements in the device list.
---@return number
function M:count()
    return tonumber(lib.TF_DeviceListCount(self.handle))
end
--- Retrieves the full name of the device (e.g. /job:worker/replica:0/...)
--- The return value will be a pointer to a null terminated string. The caller
--- must not modify or delete the string. It will be deallocated upon a call to
--- TF_DeleteDeviceList.
---
--- If index is out of bounds, an error code will be set in the status object,
--- and a null pointer will be returned.
---@param index number
---@return string
function M:name(index)
    local s = Status()
    local ret = lib.TF_DeviceListName(self.handle, index, handle(s))
    s:assert()
    return ffi.string(ret)
end
--- Retrieves the type of the device at the given index.
---
--- The caller must not modify or delete the string. It will be deallocated upon
--- a call to TF_DeleteDeviceList.
---
--- If index is out of bounds, an error code will be set in the status object,
--- and a null pointer will be returned.
---@param index number
---@return string
function M:type(index)
    local s = Status()
    local ret = lib.TF_DeviceListType(self.handle, index, handle(s))
    s:assert()
    return ffi.string(ret)
end
--- Retrieve the amount of memory associated with a given device.
---
--- If index is out of bounds, an error code will be set in the status object,
--- and -1 will be returned.
---@param index number
---@return number @int64_t
function M:memoryBytes(index)
    local s = Status()
    local ret = lib.TF_DeviceListMemoryBytes(self.handle, index, handle(s))
    s:assert()
    return ret
end
--- Retrieve the incarnation number of a given device.
---
--- If index is out of bounds, an error code will be set in the status object,
--- and 0 will be returned.
---@param index number
---@return number @uint64_t
function M:incarnation(index)
    local s = Status()
    local ret = lib.TF_DeviceListIncarnation(self.handle, index, handle(s))
    s:assert()
    return ret
end

return M
