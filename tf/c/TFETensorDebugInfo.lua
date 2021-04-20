---@class tfe.TFETensorDebugInfo
--- Debugging/Profiling information for TFE_TensorHandle
---
--- TFE_TensorDebugInfo contains information useful for debugging and
--- profiling tensors.
local M = class('tfe.TFETensorDebugInfo')
local lib = require('tf.c._c_api_eager')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end
--- Deletes `debug_info`.
function M:dtor()
    lib.TFE_DeleteTensorDebugInfo(self.handle)
    self.handle = nil
end
--- Returns the number of dimensions used to represent the tensor on its device.
--- The number of dimensions used to represent the tensor on device can be
--- different from the number returned by TFE_TensorHandleNumDims.
--- The return value was current at the time of TFE_TensorDebugInfo creation.
function M:onDeviceNumDims()
    return tonumber(lib.TFE_TensorDebugInfoOnDeviceNumDims(self.handle))
end
--- Returns the number of elements in dimension `dim_index`.
--- Tensor representation on device can be transposed from its representation
--- on host. The data contained in dimension `dim_index` on device
--- can correspond to the data contained in another dimension in on-host
--- representation. The dimensions are indexed using the standard TensorFlow
--- major-to-minor order (slowest varying dimension first),
--- not the XLA's minor-to-major order.
--- On-device dimensions can be padded. TFE_TensorDebugInfoOnDeviceDim returns
--- the number of elements in a dimension after padding.
--- The return value was current at the time of TFE_TensorDebugInfo creation.
function M:onDeviceNumDims(dim_index)
    return lib.TFE_TensorDebugInfoOnDeviceDim(self.handle, dim_index)
end

---@param h tfe.TFETensorHandle
function M.Create(h)
    return h:tensorDebugInfo()
end

return M
