---@class tfe.TFETensorHandle
--- A handle to a tensor on a device.
---
--- Like a TF_Tensor, a TFE_TensorHandle refers to a tensor with a value, shape,
--- type etc. Unlike a TF_Tensor, a TFE_TensorHandle may refer to such tensors
--- placed in memory of different devices or remote address spaces.
local M = class('tf.TFETensorHandle')
local base = require('tf.base')
local lib = base._libeager
local libex = base._libex
local libeex = base._libeagerex
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end
--- Indicates that the caller will not be using `h` any more.
function M:dtor()
    lib.TFE_DeleteTensorHandle(self.handle)
    self.handle = nil
end

function M:dataType()
    return lib.TFE_TensorHandleDataType(self.handle)
end
--- This function will block till the operation that produces `h` has completed.
function M:numDims()
    local s = Status()
    local ret = lib.TFE_TensorHandleNumDims(self.handle, handle(s))
    s:assert()
    return tonumber(ret)
end

function M:numElements()
    local s = Status()
    local ret = lib.TFE_TensorHandleNumElements(self.handle, handle(s))
    s:assert()
    return ret
end
--- This function will block till the operation that produces `h` has completed.
function M:dim(dim_index)
    local s = Status()
    local ret = lib.TFE_TensorHandleDim(self.handle, dim_index, handle(s))
    s:assert()
    return ret
end
--- Returns the device of the operation that produced `h`. If `h` was produced by
--- a copy, returns the destination device of the copy. Note that the returned
--- device name is not always the device holding the tensor handle's memory. If
--- you want the latter, use TFE_TensorHandleBackingDeviceName. This function
--- will block till the operation that produces `h` has completed.
function M:deviceName()
    local s = Status()
    local ret = lib.TFE_TensorHandleDeviceName(self.handle, handle(s))
    s:assert()
    return ffi.string(ret)
end
--- Returns the name of the device in whose memory `h` resides.
---
--- This function will block till the operation that produces `h` has completed.
function M:backingDeviceName()
    local s = Status()
    local ret = lib.TFE_TensorHandleBackingDeviceName(self.handle, handle(s))
    s:assert()
    return ffi.string(ret)
end
--- Return a pointer to a new TFE_TensorHandle that shares the underlying tensor
--- with `h`. On success, `status` is set to OK. On failure, `status` reflects
--- the error and a nullptr is returned.
function M:copySharingTensor()
    local s = Status()
    local ret = lib.TFE_TensorHandleCopySharingTensor(self.handle, handle(s))
    s:assert()
    return M(ret)
end
--- This function will block till the operation that produces `h` has
--- completed. The memory returned might alias the internal memory used by
--- TensorFlow. Hence, callers should not mutate this memory (for example by
--- modifying the memory region pointed to by TF_TensorData() on the returned
--- TF_Tensor).
function M:resolve()
    local s = Status()
    local ret = lib.TFE_TensorHandleResolve(self.handle, handle(s))
    s:assert()
    if ffi.isnullptr(ret) then
        return nil
    end
    return require('tf.c.TFTensor')(ret)
end
--- Create a new TFE_TensorHandle with the same contents as 'h' but placed
--- in the memory of the device name 'device_name'.
--- If source and destination are the same device, then this creates a new handle
--- that shares the underlying buffer. Otherwise, it currently requires at least
--- one of the source or destination devices to be CPU (i.e., for the source or
--- destination tensor to be placed in host memory).
--- If async execution is enabled, the copy may be enqueued and the call will
--- return "non-ready" handle. Else, this function returns after the copy has
--- been done.
---@param ctx tfe.TFEContext
---@param device_name string
function M:copyToDevice(ctx, device_name)
    local s = Status()
    local ret = lib.TFE_TensorHandleCopyToDevice(self.handle, handle(ctx), device_name, handle(s))
    s:assert()
    if ffi.isnullptr(ret) then
        return nil
    end
    return M(ret)
end
--- Retrieves TFE_TensorDebugInfo for `handle`.
--- If TFE_TensorHandleTensorDebugInfo succeeds, `status` is set to OK and caller
--- is responsible for deleting returned TFE_TensorDebugInfo.
--- If TFE_TensorHandleTensorDebugInfo fails, `status` is set to appropriate
--- error and nullptr is returned. This function can block till the operation
--- that produces `handle` has completed.
function M:tensorDebugInfo()
    local s = Status()
    local hdl = lib.TFE_TensorHandleTensorDebugInfo(self.handle, handle(s))
    s:assert()
    if ffi.isnullptr(hdl) then
        return nil
    end
    return require('tf.c.TFETensorDebugInfo')(hdl)
end

--

--- This function will block till the operation that produces `h` has
--- completed. This is only valid on local TFE_TensorHandles. The pointer
--- returned will be on the device in which the TFE_TensorHandle resides (so e.g.
--- for a GPU tensor this will return a pointer to GPU memory). The pointer is
--- only guaranteed to be valid until TFE_DeleteTensorHandle is called on this
--- TensorHandle. Only supports POD data types.
function M:devicePointer()
    local s = Status()
    local ret = libeex.TFE_TensorHandleDevicePointer(self.handle, handle(s))
    s:assert()
    if ffi.isnullptr(ret) then
        return nil
    end
    return ret
end

--- This function will block till the operation that produces `h` has
--- completed. This is only valid on local TFE_TensorHandles. Returns the size in
--- bytes of the memory pointed to by the device pointer returned above.
function M:deviceMemorySize()
    local s = Status()
    local ret = libeex.TFE_TensorHandleDeviceMemorySize(self.handle, handle(s))
    s:assert()
    return ret
end

--- Returns the device type of the operation that produced `h`.
function M:deviceType()
    local s = Status()
    local ret = libeex.TFE_TensorHandleDeviceType(self.handle, handle(s))
    s:assert()
    if ffi.isnullptr(ret) then
        return nil
    end
    return ffi.string(ret)
end

--- Returns the device ID of the operation that produced `h`.
function M:deviceID()
    local s = Status()
    local ret = libeex.TFE_TensorHandleDeviceID(self.handle, handle(s))
    s:assert()
    return tonumber(ret)
end

--

function M.NewTensorHandle(tensor)
    local s = Status()
    local hdl = lib.TFE_NewTensorHandle(handle(tensor), handle(s))
    s:assert()
    if ffi.isnullptr(hdl) then
        return nil
    end
    return M(hdl)
end

function M.NewTensorHandleFromScalar(dtype, data, len)
    local s = Status()
    local hdl = libex.TFE_NewTensorHandleFromScalar(dtype, data, len, handle(s))
    s:assert()
    if ffi.isnullptr(hdl) then
        return nil
    end
    return M(hdl)
end

--- Given a Tensor, wrap it with a TensorHandle
---
--- Similar to TFE_NewTensorHandle, but includes a pointer to the TFE_Context.
--- The context should be identical to that of the Tensor.
function M.NewTensorHandleWithContext(ctx, tensor)
    local s = Status()
    local hdl = libeex.TFE_NewTensorHandleFromTensor(handle(ctx), handle(tensor), handle(s))
    s:assert()
    if ffi.isnullptr(hdl) then
        return nil
    end
    return M(hdl)
end

--- Create a packed TensorHandle with the given list of TensorHandles.
--- If `handles` are on the same device, assign the same device to the packed
--- handle; if `handles` are on different deivces, assign a CompositeDevice to
--- it.
function M.CreatePackedTensorHandle(ctx, handles)
    local v, n = base.packHandles('TFE_TensorHandle*', handles)
    n = ffi.new('int[1]', n)
    local s = Status()
    local hdl = libeex.TFE_CreatePackedTensorHandle(handle(ctx), v, n, handle(s))
    s:assert()
    if ffi.isnullptr(hdl) then
        return nil
    end
    return M(hdl)
end

return M
