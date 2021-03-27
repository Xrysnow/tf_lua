--

local M = {}
local _TYPEDEF = require('tf.c.ctypes').typedef
local _ENUMDEF = require('tf.c.ctypes').enumdef
local _CALL = require('tf.c.ctypes').caller(require('tf.c._lib'))
local _FUNCDEF = require('tf.c.ctypes').addDef
-- header/c_api_eager.h

--

--- C API extensions to experiment with eager execution of kernels.
--- WARNING: Unlike tensorflow/c/c_api.h, the API here is not guaranteed to be
--- stable and can change without notice.
--- #include "tensorflow/c/c_api.h"
--- 

_TYPEDEF("TFE_ContextOptions", "struct TFE_ContextOptions")

--

--- Return a new options object.
--- 
---@return ffi.cdata @(TFE_ContextOptions *)
function M.TFE_NewContextOptions()
    return _CALL("TFE_NewContextOptions")
end
_FUNCDEF("TFE_NewContextOptions", {  }, "TFE_ContextOptions *")

--

--- Set the config in TF_ContextOptions.options.
--- config should be a serialized tensorflow.ConfigProto proto.
--- If config was not parsed successfully as a ConfigProto, record the
--- error information in *status.
--- 
---@param options ffi.cdata @(TFE_ContextOptions *)
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextOptionsSetConfig(options, proto, proto_len, status)
    return _CALL("TFE_ContextOptionsSetConfig", options, proto, proto_len, status)
end
_FUNCDEF("TFE_ContextOptionsSetConfig", { "TFE_ContextOptions *", "const void *", "size_t", "TF_Status *" }, "void")

--

--- Controls how to act when we try to run an operation on a given device but
--- some input tensors are not on that device.
--- LINT.IfChange
--- Note: Keep in sync with internal copy of enum in eager/context.h.
--- Running operations with input tensors on the wrong device will fail.
--- Copy the tensor to the right device but log a warning.
--- Silently copy the tensor, which has a performance cost since the operation
--- will be blocked till the copy completes. This is the default placement
--- policy.
--- Placement policy which silently copies int32 tensors but not other dtypes.
--- 

_TYPEDEF("TFE_ContextDevicePlacementPolicy", "enum TFE_ContextDevicePlacementPolicy { TFE_DEVICE_PLACEMENT_EXPLICIT = 0 , TFE_DEVICE_PLACEMENT_WARN = 1 , TFE_DEVICE_PLACEMENT_SILENT = 2 , TFE_DEVICE_PLACEMENT_SILENT_FOR_INT32 = 3 , }")

--

--- LINT.ThenChange(//tensorflow/c/eager/immediate_execution_context.h)
--- Sets the default execution mode (sync/async). Note that this can be
--- overridden per thread using TFE_ContextSetExecutorForThread.
--- 
---@param options ffi.cdata @(TFE_ContextOptions *)
---@param enable number @(unsigned char)
function M.TFE_ContextOptionsSetAsync(options, enable)
    return _CALL("TFE_ContextOptionsSetAsync", options, enable)
end
_FUNCDEF("TFE_ContextOptionsSetAsync", { "TFE_ContextOptions *", "unsigned char" }, "void")

--

---@param options ffi.cdata @(TFE_ContextOptions *)
---@param policy TFE_ContextDevicePlacementPolicy @(TFE_ContextDevicePlacementPolicy)
function M.TFE_ContextOptionsSetDevicePlacementPolicy(options, policy)
    return _CALL("TFE_ContextOptionsSetDevicePlacementPolicy", options, policy)
end
_FUNCDEF("TFE_ContextOptionsSetDevicePlacementPolicy", { "TFE_ContextOptions *", "TFE_ContextDevicePlacementPolicy" }, "void")

--

--- Destroy an options object.
--- 
---@param options ffi.cdata @(TFE_ContextOptions *)
function M.TFE_DeleteContextOptions(options)
    return _CALL("TFE_DeleteContextOptions", options)
end
_FUNCDEF("TFE_DeleteContextOptions", { "TFE_ContextOptions *" }, "void")

--

--- "Context" under which operations/functions are executed. It encapsulates
--- things like the available devices, resource manager etc.
--- TFE_Context must outlive all tensor handles created using it. In other
--- words, TFE_DeleteContext() must be called after all tensor handles have
--- been deleted (with TFE_DeleteTensorHandle).
--- TODO(ashankar): Merge with TF_Session?
--- 

_TYPEDEF("TFE_Context", "struct TFE_Context")

--

---@param opts ffi.cdata @(const TFE_ContextOptions *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_Context *)
function M.TFE_NewContext(opts, status)
    return _CALL("TFE_NewContext", opts, status)
end
_FUNCDEF("TFE_NewContext", { "const TFE_ContextOptions *", "TF_Status *" }, "TFE_Context *")

--

---@param ctx ffi.cdata @(TFE_Context *)
function M.TFE_DeleteContext(ctx)
    return _CALL("TFE_DeleteContext", ctx)
end
_FUNCDEF("TFE_DeleteContext", { "TFE_Context *" }, "void")

--

---@param ctx ffi.cdata @(TFE_Context *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_DeviceList *)
function M.TFE_ContextListDevices(ctx, status)
    return _CALL("TFE_ContextListDevices", ctx, status)
end
_FUNCDEF("TFE_ContextListDevices", { "TFE_Context *", "TF_Status *" }, "TF_DeviceList *")

--

--- Clears the internal caches in the TFE context. Useful when reseeding random
--- ops.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
function M.TFE_ContextClearCaches(ctx)
    return _CALL("TFE_ContextClearCaches", ctx)
end
_FUNCDEF("TFE_ContextClearCaches", { "TFE_Context *" }, "void")

--

--- Sets a thread-local device placement policy. After this call, other calls to
--- TFE_Execute in the same thread will use the device policy specified here
--- instead of the device policy used to construct the context. This has no
--- effect on the device policy used by other program threads.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param policy TFE_ContextDevicePlacementPolicy @(TFE_ContextDevicePlacementPolicy)
function M.TFE_ContextSetThreadLocalDevicePlacementPolicy(ctx, policy)
    return _CALL("TFE_ContextSetThreadLocalDevicePlacementPolicy", ctx, policy)
end
_FUNCDEF("TFE_ContextSetThreadLocalDevicePlacementPolicy", { "TFE_Context *", "TFE_ContextDevicePlacementPolicy" }, "void")

--

--- Returns the device placement policy to be used by this context in the current
--- thread.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@return TFE_ContextDevicePlacementPolicy @(TFE_ContextDevicePlacementPolicy)
function M.TFE_ContextGetDevicePlacementPolicy(ctx)
    return _CALL("TFE_ContextGetDevicePlacementPolicy", ctx)
end
_FUNCDEF("TFE_ContextGetDevicePlacementPolicy", { "TFE_Context *" }, "TFE_ContextDevicePlacementPolicy")

--

--- A tensorflow.ServerDef specifies remote workers (in addition to the current
--- workers name). Operations created on this context can then be executed on
--- any of these remote workers by setting an appropriate device.
--- If the following is set, all servers identified by the
--- ServerDef must be up when the context is created.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param keep_alive_secs number @(int)
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextSetServerDef(ctx, keep_alive_secs, proto, proto_len, status)
    return _CALL("TFE_ContextSetServerDef", ctx, keep_alive_secs, proto, proto_len, status)
end
_FUNCDEF("TFE_ContextSetServerDef", { "TFE_Context *", "int", "const void *", "size_t", "TF_Status *" }, "void")

--

--- A handle to a tensor on a device.
--- Like a TF_Tensor, a TFE_TensorHandle refers to a tensor with a value, shape,
--- type etc. Unlike a TF_Tensor, a TFE_TensorHandle may refer to such tensors
--- placed in memory of different devices or remote address spaces.
--- 

_TYPEDEF("TFE_TensorHandle", "struct TFE_TensorHandle")

--

---@param t ffi.cdata @(const TF_Tensor *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_TensorHandle *)
function M.TFE_NewTensorHandle(t, status)
    return _CALL("TFE_NewTensorHandle", t, status)
end
_FUNCDEF("TFE_NewTensorHandle", { "const TF_Tensor *", "TF_Status *" }, "TFE_TensorHandle *")

--

--- Indicates that the caller will not be using `h` any more.
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
function M.TFE_DeleteTensorHandle(h)
    return _CALL("TFE_DeleteTensorHandle", h)
end
_FUNCDEF("TFE_DeleteTensorHandle", { "TFE_TensorHandle *" }, "void")

--

---@param h ffi.cdata @(TFE_TensorHandle *)
---@return TF_DataType @(TF_DataType)
function M.TFE_TensorHandleDataType(h)
    return _CALL("TFE_TensorHandleDataType", h)
end
_FUNCDEF("TFE_TensorHandleDataType", { "TFE_TensorHandle *" }, "TF_DataType")

--

--- This function will block till the operation that produces `h` has completed.
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int)
function M.TFE_TensorHandleNumDims(h, status)
    return _CALL("TFE_TensorHandleNumDims", h, status)
end
_FUNCDEF("TFE_TensorHandleNumDims", { "TFE_TensorHandle *", "TF_Status *" }, "int")

--

---@param h ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int64_t)
function M.TFE_TensorHandleNumElements(h, status)
    return _CALL("TFE_TensorHandleNumElements", h, status)
end
_FUNCDEF("TFE_TensorHandleNumElements", { "TFE_TensorHandle *", "TF_Status *" }, "int64_t")

--

--- This function will block till the operation that produces `h` has completed.
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
---@param dim_index number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int64_t)
function M.TFE_TensorHandleDim(h, dim_index, status)
    return _CALL("TFE_TensorHandleDim", h, dim_index, status)
end
_FUNCDEF("TFE_TensorHandleDim", { "TFE_TensorHandle *", "int", "TF_Status *" }, "int64_t")

--

--- Returns the device of the operation that produced `h`. If `h` was produced by
--- a copy, returns the destination device of the copy. Note that the returned
--- device name is not always the device holding the tensor handle's memory. If
--- you want the latter, use TFE_TensorHandleBackingDeviceName. This function
--- will block till the operation that produces `h` has completed.
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return string @(const char *)
function M.TFE_TensorHandleDeviceName(h, status)
    return _CALL("TFE_TensorHandleDeviceName", h, status)
end
_FUNCDEF("TFE_TensorHandleDeviceName", { "TFE_TensorHandle *", "TF_Status *" }, "const char *")

--

--- Returns the name of the device in whose memory `h` resides.
--- This function will block till the operation that produces `h` has completed.
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return string @(const char *)
function M.TFE_TensorHandleBackingDeviceName(h, status)
    return _CALL("TFE_TensorHandleBackingDeviceName", h, status)
end
_FUNCDEF("TFE_TensorHandleBackingDeviceName", { "TFE_TensorHandle *", "TF_Status *" }, "const char *")

--

--- Return a pointer to a new TFE_TensorHandle that shares the underlying tensor
--- with `h`. On success, `status` is set to OK. On failure, `status` reflects
--- the error and a nullptr is returned.
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_TensorHandle *)
function M.TFE_TensorHandleCopySharingTensor(h, status)
    return _CALL("TFE_TensorHandleCopySharingTensor", h, status)
end
_FUNCDEF("TFE_TensorHandleCopySharingTensor", { "TFE_TensorHandle *", "TF_Status *" }, "TFE_TensorHandle *")

--

--- This function will block till the operation that produces `h` has
--- completed. The memory returned might alias the internal memory used by
--- TensorFlow. Hence, callers should not mutate this memory (for example by
--- modifying the memory region pointed to by TF_TensorData() on the returned
--- TF_Tensor).
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Tensor *)
function M.TFE_TensorHandleResolve(h, status)
    return _CALL("TFE_TensorHandleResolve", h, status)
end
_FUNCDEF("TFE_TensorHandleResolve", { "TFE_TensorHandle *", "TF_Status *" }, "TF_Tensor *")

--

--- Create a new TFE_TensorHandle with the same contents as 'h' but placed
--- in the memory of the device name 'device_name'.
--- If source and destination are the same device, then this creates a new handle
--- that shares the underlying buffer. Otherwise, it currently requires at least
--- one of the source or destination devices to be CPU (i.e., for the source or
--- destination tensor to be placed in host memory).
--- If async execution is enabled, the copy may be enqueued and the call will
--- return "non-ready" handle. Else, this function returns after the copy has
--- been done.
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
---@param ctx ffi.cdata @(TFE_Context *)
---@param device_name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_TensorHandle *)
function M.TFE_TensorHandleCopyToDevice(h, ctx, device_name, status)
    return _CALL("TFE_TensorHandleCopyToDevice", h, ctx, device_name, status)
end
_FUNCDEF("TFE_TensorHandleCopyToDevice", { "TFE_TensorHandle *", "TFE_Context *", "const char *", "TF_Status *" }, "TFE_TensorHandle *")

--

--- Debugging/Profiling information for TFE_TensorHandle
--- TFE_TensorDebugInfo contains information useful for debugging and
--- profiling tensors.
--- 

_TYPEDEF("TFE_TensorDebugInfo", "struct TFE_TensorDebugInfo")

--

--- Retrieves TFE_TensorDebugInfo for `handle`.
--- If TFE_TensorHandleTensorDebugInfo succeeds, `status` is set to OK and caller
--- is responsible for deleting returned TFE_TensorDebugInfo.
--- If TFE_TensorHandleTensorDebugInfo fails, `status` is set to appropriate
--- error and nullptr is returned. This function can block till the operation
--- that produces `handle` has completed.
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_TensorDebugInfo *)
function M.TFE_TensorHandleTensorDebugInfo(h, status)
    return _CALL("TFE_TensorHandleTensorDebugInfo", h, status)
end
_FUNCDEF("TFE_TensorHandleTensorDebugInfo", { "TFE_TensorHandle *", "TF_Status *" }, "TFE_TensorDebugInfo *")

--

--- Deletes `debug_info`.
--- 
---@param debug_info ffi.cdata @(TFE_TensorDebugInfo *)
function M.TFE_DeleteTensorDebugInfo(debug_info)
    return _CALL("TFE_DeleteTensorDebugInfo", debug_info)
end
_FUNCDEF("TFE_DeleteTensorDebugInfo", { "TFE_TensorDebugInfo *" }, "void")

--

--- Returns the number of dimensions used to represent the tensor on its device.
--- The number of dimensions used to represent the tensor on device can be
--- different from the number returned by TFE_TensorHandleNumDims.
--- The return value was current at the time of TFE_TensorDebugInfo creation.
--- 
---@param debug_info ffi.cdata @(TFE_TensorDebugInfo *)
---@return number @(int)
function M.TFE_TensorDebugInfoOnDeviceNumDims(debug_info)
    return _CALL("TFE_TensorDebugInfoOnDeviceNumDims", debug_info)
end
_FUNCDEF("TFE_TensorDebugInfoOnDeviceNumDims", { "TFE_TensorDebugInfo *" }, "int")

--

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
--- 
---@param debug_info ffi.cdata @(TFE_TensorDebugInfo *)
---@param dim_index number @(int)
---@return number @(int64_t)
function M.TFE_TensorDebugInfoOnDeviceDim(debug_info, dim_index)
    return _CALL("TFE_TensorDebugInfoOnDeviceDim", debug_info, dim_index)
end
_FUNCDEF("TFE_TensorDebugInfoOnDeviceDim", { "TFE_TensorDebugInfo *", "int" }, "int64_t")

--

--- Description of the TensorFlow op to execute.
--- Assumes that the provided 'ctx' outlives the returned TFE_Op, i.e.,
--- TFE_DeleteOp() is called before TFE_DeleteContext().
--- Very similar to TF_OperationDescription with some differences:
--- (1) TF_Output or TFE_TensorHandle* as arguments to TF_AddInput,
--- TF_AddInputList
--- (2) TF_ColocateWith, TF_AddControlInput etc. do not make sense.
--- (3) Implementation detail: Avoid use of NodeBuilder/NodeDefBuilder since
--- the additional sanity checks there seem unnecessary;
--- 

_TYPEDEF("TFE_Op", "struct TFE_Op")

--

---@param ctx ffi.cdata @(TFE_Context *)
---@param op_or_function_name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_Op *)
function M.TFE_NewOp(ctx, op_or_function_name, status)
    return _CALL("TFE_NewOp", ctx, op_or_function_name, status)
end
_FUNCDEF("TFE_NewOp", { "TFE_Context *", "const char *", "TF_Status *" }, "TFE_Op *")

--

---@param op ffi.cdata @(TFE_Op *)
function M.TFE_DeleteOp(op)
    return _CALL("TFE_DeleteOp", op)
end
_FUNCDEF("TFE_DeleteOp", { "TFE_Op *" }, "void")

--

--- Returns the op or function name `op` will execute.
--- The returned string remains valid throughout the lifetime of 'op'.
--- 
---@param op ffi.cdata @(const TFE_Op *)
---@param status ffi.cdata @(TF_Status *)
---@return string @(const char *)
function M.TFE_OpGetName(op, status)
    return _CALL("TFE_OpGetName", op, status)
end
_FUNCDEF("TFE_OpGetName", { "const TFE_Op *", "TF_Status *" }, "const char *")

--

---@param op ffi.cdata @(const TFE_Op *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_Context *)
function M.TFE_OpGetContext(op, status)
    return _CALL("TFE_OpGetContext", op, status)
end
_FUNCDEF("TFE_OpGetContext", { "const TFE_Op *", "TF_Status *" }, "TFE_Context *")

--

---@param op ffi.cdata @(TFE_Op *)
---@param device_name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_OpSetDevice(op, device_name, status)
    return _CALL("TFE_OpSetDevice", op, device_name, status)
end
_FUNCDEF("TFE_OpSetDevice", { "TFE_Op *", "const char *", "TF_Status *" }, "void")

--

--- The returned string remains valid throughout the lifetime of 'op'.
--- 
---@param op ffi.cdata @(const TFE_Op *)
---@param status ffi.cdata @(TF_Status *)
---@return string @(const char *)
function M.TFE_OpGetDevice(op, status)
    return _CALL("TFE_OpGetDevice", op, status)
end
_FUNCDEF("TFE_OpGetDevice", { "const TFE_Op *", "TF_Status *" }, "const char *")

--

---@param op ffi.cdata @(TFE_Op *)
---@param input ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_OpAddInput(op, input, status)
    return _CALL("TFE_OpAddInput", op, input, status)
end
_FUNCDEF("TFE_OpAddInput", { "TFE_Op *", "TFE_TensorHandle *", "TF_Status *" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param inputs ffi.cdata @(TFE_TensorHandle * *)
---@param num_inputs number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_OpAddInputList(op, inputs, num_inputs, status)
    return _CALL("TFE_OpAddInputList", op, inputs, num_inputs, status)
end
_FUNCDEF("TFE_OpAddInputList", { "TFE_Op *", "TFE_TensorHandle * *", "int", "TF_Status *" }, "void")

--

--- Fetches the current number of inputs attached to `op`.
--- Does not use the operation's definition to determine how many inputs should
--- be attached. It is intended for use with TFE_OpGetFlatInput to inspect an
--- already-finalized operation.
--- Note that TFE_OpGetFlatInputCount and TFE_OpGetFlatInput operate on a flat
--- sequence of inputs, unlike TFE_OpGetInputLength (for getting the length of a
--- particular named input list, which may only be part of the op's inputs).
--- 
---@param op ffi.cdata @(const TFE_Op *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int)
function M.TFE_OpGetFlatInputCount(op, status)
    return _CALL("TFE_OpGetFlatInputCount", op, status)
end
_FUNCDEF("TFE_OpGetFlatInputCount", { "const TFE_Op *", "TF_Status *" }, "int")

--

--- Returns a borrowed reference to one of `op`'s inputs. Use
--- `TFE_TensorHandleCopySharingTensor` to make a new reference.
--- 
---@param op ffi.cdata @(const TFE_Op *)
---@param index number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_TensorHandle *)
function M.TFE_OpGetFlatInput(op, index, status)
    return _CALL("TFE_OpGetFlatInput", op, index, status)
end
_FUNCDEF("TFE_OpGetFlatInput", { "const TFE_Op *", "int", "TF_Status *" }, "TFE_TensorHandle *")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param is_list ffi.cdata @(unsigned char *)
---@param status ffi.cdata @(TF_Status *)
---@return TF_AttrType @(TF_AttrType)
function M.TFE_OpGetAttrType(op, attr_name, is_list, status)
    return _CALL("TFE_OpGetAttrType", op, attr_name, is_list, status)
end
_FUNCDEF("TFE_OpGetAttrType", { "TFE_Op *", "const char *", "unsigned char *", "TF_Status *" }, "TF_AttrType")

--

--- Get an attribute type given an op name; a fusion of TFE_NewOp and
--- TFE_OpGetAttrType for use from Python without the overhead of the individual
--- calls and memory management of TFE_Op.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param op_or_function_name string @(const char *)
---@param attr_name string @(const char *)
---@param is_list ffi.cdata @(unsigned char *)
---@param status ffi.cdata @(TF_Status *)
---@return TF_AttrType @(TF_AttrType)
function M.TFE_OpNameGetAttrType(ctx, op_or_function_name, attr_name, is_list, status)
    return _CALL("TFE_OpNameGetAttrType", ctx, op_or_function_name, attr_name, is_list, status)
end
_FUNCDEF("TFE_OpNameGetAttrType", { "TFE_Context *", "const char *", "const char *", "unsigned char *", "TF_Status *" }, "TF_AttrType")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(const void *)
---@param length number @(size_t)
function M.TFE_OpSetAttrString(op, attr_name, value, length)
    return _CALL("TFE_OpSetAttrString", op, attr_name, value, length)
end
_FUNCDEF("TFE_OpSetAttrString", { "TFE_Op *", "const char *", "const void *", "size_t" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param value number @(int64_t)
function M.TFE_OpSetAttrInt(op, attr_name, value)
    return _CALL("TFE_OpSetAttrInt", op, attr_name, value)
end
_FUNCDEF("TFE_OpSetAttrInt", { "TFE_Op *", "const char *", "int64_t" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param value number @(float)
function M.TFE_OpSetAttrFloat(op, attr_name, value)
    return _CALL("TFE_OpSetAttrFloat", op, attr_name, value)
end
_FUNCDEF("TFE_OpSetAttrFloat", { "TFE_Op *", "const char *", "float" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param value number @(unsigned char)
function M.TFE_OpSetAttrBool(op, attr_name, value)
    return _CALL("TFE_OpSetAttrBool", op, attr_name, value)
end
_FUNCDEF("TFE_OpSetAttrBool", { "TFE_Op *", "const char *", "unsigned char" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param value TF_DataType @(TF_DataType)
function M.TFE_OpSetAttrType(op, attr_name, value)
    return _CALL("TFE_OpSetAttrType", op, attr_name, value)
end
_FUNCDEF("TFE_OpSetAttrType", { "TFE_Op *", "const char *", "TF_DataType" }, "void")

--

--- If the number of dimensions is unknown, `num_dims` must be set to
--- -1 and `dims` can be null.  If a dimension is unknown, the
--- corresponding entry in the `dims` array must be -1.
--- 
---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param dims ffi.cdata @(const int64_t *)
---@param num_dims number @(const int)
---@param out_status ffi.cdata @(TF_Status *)
function M.TFE_OpSetAttrShape(op, attr_name, dims, num_dims, out_status)
    return _CALL("TFE_OpSetAttrShape", op, attr_name, dims, num_dims, out_status)
end
_FUNCDEF("TFE_OpSetAttrShape", { "TFE_Op *", "const char *", "const int64_t *", "const int", "TF_Status *" }, "void")

--

--- Sets the attribute attr_name to be a function specified by 'function'.
--- TODO(ashankar,iga): Add this functionality to the C API for graph
--- construction. Perhaps we want an AttrValueMap equivalent in the C API?
--- 
---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(const TFE_Op *)
function M.TFE_OpSetAttrFunction(op, attr_name, value)
    return _CALL("TFE_OpSetAttrFunction", op, attr_name, value)
end
_FUNCDEF("TFE_OpSetAttrFunction", { "TFE_Op *", "const char *", "const TFE_Op *" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param data string @(const char *)
---@param length number @(size_t)
function M.TFE_OpSetAttrFunctionName(op, attr_name, data, length)
    return _CALL("TFE_OpSetAttrFunctionName", op, attr_name, data, length)
end
_FUNCDEF("TFE_OpSetAttrFunctionName", { "TFE_Op *", "const char *", "const char *", "size_t" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param tensor ffi.cdata @(TF_Tensor *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_OpSetAttrTensor(op, attr_name, tensor, status)
    return _CALL("TFE_OpSetAttrTensor", op, attr_name, tensor, status)
end
_FUNCDEF("TFE_OpSetAttrTensor", { "TFE_Op *", "const char *", "TF_Tensor *", "TF_Status *" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const void * const *)
---@param lengths ffi.cdata @(const size_t *)
---@param num_values number @(int)
function M.TFE_OpSetAttrStringList(op, attr_name, values, lengths, num_values)
    return _CALL("TFE_OpSetAttrStringList", op, attr_name, values, lengths, num_values)
end
_FUNCDEF("TFE_OpSetAttrStringList", { "TFE_Op *", "const char *", "const void * const *", "const size_t *", "int" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const int64_t *)
---@param num_values number @(int)
function M.TFE_OpSetAttrIntList(op, attr_name, values, num_values)
    return _CALL("TFE_OpSetAttrIntList", op, attr_name, values, num_values)
end
_FUNCDEF("TFE_OpSetAttrIntList", { "TFE_Op *", "const char *", "const int64_t *", "int" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const float *)
---@param num_values number @(int)
function M.TFE_OpSetAttrFloatList(op, attr_name, values, num_values)
    return _CALL("TFE_OpSetAttrFloatList", op, attr_name, values, num_values)
end
_FUNCDEF("TFE_OpSetAttrFloatList", { "TFE_Op *", "const char *", "const float *", "int" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const unsigned char *)
---@param num_values number @(int)
function M.TFE_OpSetAttrBoolList(op, attr_name, values, num_values)
    return _CALL("TFE_OpSetAttrBoolList", op, attr_name, values, num_values)
end
_FUNCDEF("TFE_OpSetAttrBoolList", { "TFE_Op *", "const char *", "const unsigned char *", "int" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const TF_DataType *)
---@param num_values number @(int)
function M.TFE_OpSetAttrTypeList(op, attr_name, values, num_values)
    return _CALL("TFE_OpSetAttrTypeList", op, attr_name, values, num_values)
end
_FUNCDEF("TFE_OpSetAttrTypeList", { "TFE_Op *", "const char *", "const TF_DataType *", "int" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param dims ffi.cdata @(const int64_t * *)
---@param num_dims ffi.cdata @(const int *)
---@param num_values number @(int)
---@param out_status ffi.cdata @(TF_Status *)
function M.TFE_OpSetAttrShapeList(op, attr_name, dims, num_dims, num_values, out_status)
    return _CALL("TFE_OpSetAttrShapeList", op, attr_name, dims, num_dims, num_values, out_status)
end
_FUNCDEF("TFE_OpSetAttrShapeList", { "TFE_Op *", "const char *", "const int64_t * *", "const int *", "int", "TF_Status *" }, "void")

--

---@param op ffi.cdata @(TFE_Op *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(const TFE_Op * *)
---@param num_values number @(int)
function M.TFE_OpSetAttrFunctionList(op, attr_name, value, num_values)
    return _CALL("TFE_OpSetAttrFunctionList", op, attr_name, value, num_values)
end
_FUNCDEF("TFE_OpSetAttrFunctionList", { "TFE_Op *", "const char *", "const TFE_Op * *", "int" }, "void")

--

--- Returns the length (number of tensors) of the input argument `input_name`
--- found in the provided `op`.
--- 
---@param op ffi.cdata @(TFE_Op *)
---@param input_name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int)
function M.TFE_OpGetInputLength(op, input_name, status)
    return _CALL("TFE_OpGetInputLength", op, input_name, status)
end
_FUNCDEF("TFE_OpGetInputLength", { "TFE_Op *", "const char *", "TF_Status *" }, "int")

--

--- Returns the length (number of tensors) of the output argument `output_name`
--- found in the provided `op`.
--- 
---@param op ffi.cdata @(TFE_Op *)
---@param output_name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int)
function M.TFE_OpGetOutputLength(op, output_name, status)
    return _CALL("TFE_OpGetOutputLength", op, output_name, status)
end
_FUNCDEF("TFE_OpGetOutputLength", { "TFE_Op *", "const char *", "TF_Status *" }, "int")

--

--- Execute the operation defined by 'op' and return handles to computed
--- tensors in `retvals`.
--- 'retvals' must point to a pre-allocated array of TFE_TensorHandle* and
--- '*num_retvals' should be set to the size of this array. It is an error if
--- the size of 'retvals' is less than the number of outputs. This call sets
--- num_retvals to the number of outputs.
--- If async execution is enabled, the call may simply enqueue the execution
--- and return "non-ready" handles in `retvals`. Note that any handles contained
--- in 'op' should not be mutated till the kernel execution actually finishes.
--- For sync execution, if any of the inputs to `op` are not ready, this call
--- will block till they become ready and then return when the kernel execution
--- is done.
--- TODO(agarwal): change num_retvals to int from int*.
--- 
---@param op ffi.cdata @(TFE_Op *)
---@param retvals ffi.cdata @(TFE_TensorHandle * *)
---@param num_retvals ffi.cdata @(int *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_Execute(op, retvals, num_retvals, status)
    return _CALL("TFE_Execute", op, retvals, num_retvals, status)
end
_FUNCDEF("TFE_Execute", { "TFE_Op *", "TFE_TensorHandle * *", "int *", "TF_Status *" }, "void")

--

--- Add a function (serialized FunctionDef protocol buffer) to ctx so
--- that it can be invoked using TFE_Execute.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param serialized_function_def string @(const char *)
---@param size number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextAddFunctionDef(ctx, serialized_function_def, size, status)
    return _CALL("TFE_ContextAddFunctionDef", ctx, serialized_function_def, size, status)
end
_FUNCDEF("TFE_ContextAddFunctionDef", { "TFE_Context *", "const char *", "size_t", "TF_Status *" }, "void")

--

--- Adds a function (created from TF_GraphToFunction or
--- TF_FunctionImportFunctionDef) to the context, allowing it to be executed with
--- TFE_Execute by creating an op with the same name as the function.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param function ffi.cdata @(TF_Function *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextAddFunction(ctx, fun, status)
    return _CALL("TFE_ContextAddFunction", ctx, fun, status)
end
_FUNCDEF("TFE_ContextAddFunction", { "TFE_Context *", "TF_Function *", "TF_Status *" }, "void")

--

--- Removes a function from the context. Once removed, you can no longer
--- TFE_Execute it or TFE_Execute any TFE_Op which has it as an attribute or any
--- other function which calls it as an attribute.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextRemoveFunction(ctx, name, status)
    return _CALL("TFE_ContextRemoveFunction", ctx, name, status)
end
_FUNCDEF("TFE_ContextRemoveFunction", { "TFE_Context *", "const char *", "TF_Status *" }, "void")

--

--- Checks whether a function is registered under `name`.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param name string @(const char *)
---@return number @(unsigned char)
function M.TFE_ContextHasFunction(ctx, name)
    return _CALL("TFE_ContextHasFunction", ctx, name)
end
_FUNCDEF("TFE_ContextHasFunction", { "TFE_Context *", "const char *" }, "unsigned char")

--

--- Enables tracing of RunMetadata on the ops executed from this context.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
function M.TFE_ContextEnableRunMetadata(ctx)
    return _CALL("TFE_ContextEnableRunMetadata", ctx)
end
_FUNCDEF("TFE_ContextEnableRunMetadata", { "TFE_Context *" }, "void")

--

--- Disables tracing of RunMetadata on the ops executed from this context.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
function M.TFE_ContextDisableRunMetadata(ctx)
    return _CALL("TFE_ContextDisableRunMetadata", ctx)
end
_FUNCDEF("TFE_ContextDisableRunMetadata", { "TFE_Context *" }, "void")

--

--- Populates the passed-in buffer with a serialized RunMetadata protocol buffer
--- containing any run metadata information accumulated so far and clears this
--- information.
--- If async mode is enabled, this call blocks till all currently pending ops are
--- done.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param buf ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextExportRunMetadata(ctx, buf, status)
    return _CALL("TFE_ContextExportRunMetadata", ctx, buf, status)
end
_FUNCDEF("TFE_ContextExportRunMetadata", { "TFE_Context *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- Some TF ops need a step container to be set to limit the lifetime of some
--- resources (mostly TensorArray and Stack, used in while loop gradients in
--- graph mode). Calling this on a context tells it to start a step.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
function M.TFE_ContextStartStep(ctx)
    return _CALL("TFE_ContextStartStep", ctx)
end
_FUNCDEF("TFE_ContextStartStep", { "TFE_Context *" }, "void")

--

--- Ends a step. When there is no active step (that is, every started step has
--- been ended) step containers will be cleared. Note: it is not safe to call
--- TFE_ContextEndStep while ops which rely on the step container may be running.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
function M.TFE_ContextEndStep(ctx)
    return _CALL("TFE_ContextEndStep", ctx)
end
_FUNCDEF("TFE_ContextEndStep", { "TFE_Context *" }, "void")

--


return M

