--

local M = {}
local _TYPEDEF = require('tf.c.ctypes').typedef
local _ENUMDEF = require('tf.c.ctypes').enumdef
local _CALL = require('tf.c.ctypes').caller(require('tf.c._lib'))
local _FUNCDEF = require('tf.c.ctypes').addDef
-- header/c_api_experimental.h

--

--- --------------------------------------------------------------------------
--- Experimental C API for TensorFlow.
--- The API here is subject to changes in the future.
--- --------------------------------------------------------------------------
--- When `enable` is true, set
--- tensorflow.ConfigProto.OptimizerOptions.global_jit_level to ON_1, and also
--- set XLA flag values to prepare for XLA compilation. Otherwise set
--- global_jit_level to OFF.
--- This and the next API are syntax sugar over TF_SetConfig(), and is used by
--- clients that cannot read/write the tensorflow.ConfigProto proto.
--- TODO: Migrate to TF_CreateConfig() below.
--- 
---@param options ffi.cdata @(TF_SessionOptions *)
---@param enable number @(unsigned char)
function M.TF_EnableXLACompilation(options, enable)
    return _CALL("TF_EnableXLACompilation", options, enable)
end
_FUNCDEF("TF_EnableXLACompilation", { "TF_SessionOptions *", "unsigned char" }, "void")

--

--- Set XLA's internal BuildXlaOpsPassFlags.tf_xla_enable_lazy_compilation to the
--- value of 'enabled'. Also returns the original value of that flag.
--- Use in tests to allow XLA to fallback to TF classic. This has global effect.
--- 
---@param enable number @(unsigned char)
---@return number @(unsigned char)
function M.TF_SetXlaEnableLazyCompilation(enable)
    return _CALL("TF_SetXlaEnableLazyCompilation", enable)
end
_FUNCDEF("TF_SetXlaEnableLazyCompilation", { "unsigned char" }, "unsigned char")

--

---@param enable number @(unsigned char)
---@return number @(unsigned char)
function M.TF_SetTfXlaCpuGlobalJit(enable)
    return _CALL("TF_SetTfXlaCpuGlobalJit", enable)
end
_FUNCDEF("TF_SetTfXlaCpuGlobalJit", { "unsigned char" }, "unsigned char")

--

--- Sets XLA's auto jit mode according to the specified string, which is parsed
--- as if passed in XLA_FLAGS. This has global effect.
--- 
---@param mode string @(const char *)
function M.TF_SetXlaAutoJitMode(mode)
    return _CALL("TF_SetXlaAutoJitMode", mode)
end
_FUNCDEF("TF_SetXlaAutoJitMode", { "const char *" }, "void")

--

--- Sets XLA's minimum cluster size. This has global effect.
--- 
---@param size number @(int)
function M.TF_SetXlaMinClusterSize(size)
    return _CALL("TF_SetXlaMinClusterSize", size)
end
_FUNCDEF("TF_SetXlaMinClusterSize", { "int" }, "void")

--

--- Gets/Sets TF/XLA flag for whether(true) or not(false) to disable constant
--- folding. This is for testing to ensure that XLA is being tested rather than
--- Tensorflow's CPU implementation through constant folding.
--- 
---@return number @(unsigned char)
function M.TF_GetXlaConstantFoldingDisabled()
    return _CALL("TF_GetXlaConstantFoldingDisabled")
end
_FUNCDEF("TF_GetXlaConstantFoldingDisabled", {  }, "unsigned char")

--

---@param should_enable number @(unsigned char)
function M.TF_SetXlaConstantFoldingDisabled(should_enable)
    return _CALL("TF_SetXlaConstantFoldingDisabled", should_enable)
end
_FUNCDEF("TF_SetXlaConstantFoldingDisabled", { "unsigned char" }, "void")

--

--- Create a serialized tensorflow.ConfigProto proto, where:
--- a) ConfigProto.optimizer_options.global_jit_level is set to to ON_1 if
--- `enable_xla_compilation` is non-zero, and OFF otherwise.
--- b) ConfigProto.gpu_options.allow_growth is set to `gpu_memory_allow_growth`.
--- c) ConfigProto.device_count is set to `num_cpu_devices`.
--- 
---@param enable_xla_compilation number @(unsigned char)
---@param gpu_memory_allow_growth number @(unsigned char)
---@param num_cpu_devices number @(unsigned int)
---@return ffi.cdata @(TF_Buffer *)
function M.TF_CreateConfig(enable_xla_compilation, gpu_memory_allow_growth, num_cpu_devices)
    return _CALL("TF_CreateConfig", enable_xla_compilation, gpu_memory_allow_growth, num_cpu_devices)
end
_FUNCDEF("TF_CreateConfig", { "unsigned char", "unsigned char", "unsigned int" }, "TF_Buffer *")

--

--- Create a serialized tensorflow.RunOptions proto, where RunOptions.trace_level
--- is set to FULL_TRACE if `enable_full_trace` is non-zero, and NO_TRACE
--- otherwise.
--- 
---@param enable_full_trace number @(unsigned char)
---@return ffi.cdata @(TF_Buffer *)
function M.TF_CreateRunOptions(enable_full_trace)
    return _CALL("TF_CreateRunOptions", enable_full_trace)
end
_FUNCDEF("TF_CreateRunOptions", { "unsigned char" }, "TF_Buffer *")

--

--- Returns the graph content in a human-readable format, with length set in
--- `len`. The format is subject to change in the future.
--- The returned string is heap-allocated, and caller should call free() on it.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param len ffi.cdata @(size_t *)
---@return string @(const char *)
function M.TF_GraphDebugString(graph, len)
    return _CALL("TF_GraphDebugString", graph, len)
end
_FUNCDEF("TF_GraphDebugString", { "TF_Graph *", "size_t *" }, "const char *")

--

--- Returns the function content in a human-readable format, with length set in
--- `len`. The format is subject to change in the future.
--- The returned string is heap-allocated, and caller should call free() on it.
--- Do not return const char*, because some foreign language binding
--- (e.g. swift) cannot then call free() on the returned pointer.
--- 
---@param func ffi.cdata @(TF_Function *)
---@param len ffi.cdata @(size_t *)
---@return ffi.cdata @(char *)
function M.TF_FunctionDebugString(func, len)
    return _CALL("TF_FunctionDebugString", func, len)
end
_FUNCDEF("TF_FunctionDebugString", { "TF_Function *", "size_t *" }, "char *")

--

--- On success, dequeues a tensor from a TF-managed FifoQueue given by
--- `tensor_id`, associated with `session`. There must be a graph node named
--- "fifo_queue_dequeue_<tensor_id>", to be executed by this API call.
--- Caller must call TF_DeleteTensor() over the returned tensor. If the queue is
--- empty, this call is blocked.
--- Tensors are enqueued via the corresponding TF enqueue op.
--- TODO(hongm): Add support for `timeout_ms`.
--- 
---@param session ffi.cdata @(TF_Session *)
---@param tensor_id number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Tensor *)
function M.TF_DequeueNamedTensor(session, tensor_id, status)
    return _CALL("TF_DequeueNamedTensor", session, tensor_id, status)
end
_FUNCDEF("TF_DequeueNamedTensor", { "TF_Session *", "int", "TF_Status *" }, "TF_Tensor *")

--

--- On success, enqueues `tensor` into a TF-managed FifoQueue given by
--- `tensor_id`, associated with `session`. There must be a graph node named
--- "fifo_queue_enqueue_<tensor_id>", to be executed by this API call. It reads
--- from a placeholder node "arg_tensor_enqueue_<tensor_id>".
--- `tensor` is still owned by the caller. This call will be blocked if the queue
--- has reached its capacity, and will be unblocked when the queued tensors again
--- drop below the capacity due to dequeuing.
--- Tensors are dequeued via the corresponding TF dequeue op.
--- TODO(hongm): Add support for `timeout_ms`.
--- 
---@param session ffi.cdata @(TF_Session *)
---@param tensor_id number @(int)
---@param tensor ffi.cdata @(TF_Tensor *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_EnqueueNamedTensor(session, tensor_id, tensor, status)
    return _CALL("TF_EnqueueNamedTensor", session, tensor_id, tensor, status)
end
_FUNCDEF("TF_EnqueueNamedTensor", { "TF_Session *", "int", "TF_Tensor *", "TF_Status *" }, "void")

--

--- Create a serialized tensorflow.ServerDef proto.
--- 
---@param text_proto string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Buffer *)
function M.TFE_GetServerDef(text_proto, status)
    return _CALL("TFE_GetServerDef", text_proto, status)
end
_FUNCDEF("TFE_GetServerDef", { "const char *", "TF_Status *" }, "TF_Buffer *")

--

---@param status ffi.cdata @(TF_Status *)
---@param errMsg string @(const char *)
function M.TF_MakeInternalErrorStatus(status, errMsg)
    return _CALL("TF_MakeInternalErrorStatus", status, errMsg)
end
_FUNCDEF("TF_MakeInternalErrorStatus", { "TF_Status *", "const char *" }, "void")

--

--- TF_NewCheckpointReader() return the CheckpointReader that can be use to
--- investigate or load the variable from the checkpoint file
--- 

_TYPEDEF("TF_CheckpointReader", "struct TF_CheckpointReader")

--

---@param filename string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_CheckpointReader *)
function M.TF_NewCheckpointReader(filename, status)
    return _CALL("TF_NewCheckpointReader", filename, status)
end
_FUNCDEF("TF_NewCheckpointReader", { "const char *", "TF_Status *" }, "TF_CheckpointReader *")

--

---@param reader ffi.cdata @(TF_CheckpointReader *)
function M.TF_DeleteCheckpointReader(reader)
    return _CALL("TF_DeleteCheckpointReader", reader)
end
_FUNCDEF("TF_DeleteCheckpointReader", { "TF_CheckpointReader *" }, "void")

--

---@param reader ffi.cdata @(TF_CheckpointReader *)
---@param name string @(const char *)
---@return number @(int)
function M.TF_CheckpointReaderHasTensor(reader, name)
    return _CALL("TF_CheckpointReaderHasTensor", reader, name)
end
_FUNCDEF("TF_CheckpointReaderHasTensor", { "TF_CheckpointReader *", "const char *" }, "int")

--

--- Get the variable name at the given index
--- 
---@param reader ffi.cdata @(TF_CheckpointReader *)
---@param index number @(int)
---@return string @(const char *)
function M.TF_CheckpointReaderGetVariable(reader, index)
    return _CALL("TF_CheckpointReaderGetVariable", reader, index)
end
_FUNCDEF("TF_CheckpointReaderGetVariable", { "TF_CheckpointReader *", "int" }, "const char *")

--

--- Get the number of variable in the checkpoint
--- 
---@param reader ffi.cdata @(TF_CheckpointReader *)
---@return number @(int)
function M.TF_CheckpointReaderSize(reader)
    return _CALL("TF_CheckpointReaderSize", reader)
end
_FUNCDEF("TF_CheckpointReaderSize", { "TF_CheckpointReader *" }, "int")

--

--- Get the DataType of a variable
--- 
---@param reader ffi.cdata @(TF_CheckpointReader *)
---@param name string @(const char *)
---@return TF_DataType @(TF_DataType)
function M.TF_CheckpointReaderGetVariableDataType(reader, name)
    return _CALL("TF_CheckpointReaderGetVariableDataType", reader, name)
end
_FUNCDEF("TF_CheckpointReaderGetVariableDataType", { "TF_CheckpointReader *", "const char *" }, "TF_DataType")

--

--- Read the shape of a variable and write to `dims`
--- 
---@param reader ffi.cdata @(TF_CheckpointReader *)
---@param name string @(const char *)
---@param dims ffi.cdata @(int64_t *)
---@param num_dims number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_CheckpointReaderGetVariableShape(reader, name, dims, num_dims, status)
    return _CALL("TF_CheckpointReaderGetVariableShape", reader, name, dims, num_dims, status)
end
_FUNCDEF("TF_CheckpointReaderGetVariableShape", { "TF_CheckpointReader *", "const char *", "int64_t *", "int", "TF_Status *" }, "void")

--

--- Get the number of dimension of a variable
--- 
---@param reader ffi.cdata @(TF_CheckpointReader *)
---@param name string @(const char *)
---@return number @(int)
function M.TF_CheckpointReaderGetVariableNumDims(reader, name)
    return _CALL("TF_CheckpointReaderGetVariableNumDims", reader, name)
end
_FUNCDEF("TF_CheckpointReaderGetVariableNumDims", { "TF_CheckpointReader *", "const char *" }, "int")

--

--- Load the weight of a variable
--- 
---@param reader ffi.cdata @(TF_CheckpointReader *)
---@param name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Tensor *)
function M.TF_CheckpointReaderGetTensor(reader, name, status)
    return _CALL("TF_CheckpointReaderGetTensor", reader, name, status)
end
_FUNCDEF("TF_CheckpointReaderGetTensor", { "TF_CheckpointReader *", "const char *", "TF_Status *" }, "TF_Tensor *")

--

--- TF_NewAttrBuilder() returns an object that you can set attributes on as
--- though it were an op. This allows querying properties of that op for
--- type-checking purposes like if the op will run on a particular device type.
--- 

_TYPEDEF("TF_AttrBuilder", "struct TF_AttrBuilder")

--

---@param op_name string @(const char *)
---@return ffi.cdata @(TF_AttrBuilder *)
function M.TF_NewAttrBuilder(op_name)
    return _CALL("TF_NewAttrBuilder", op_name)
end
_FUNCDEF("TF_NewAttrBuilder", { "const char *" }, "TF_AttrBuilder *")

--

---@param builder ffi.cdata @(TF_AttrBuilder *)
function M.TF_DeleteAttrBuilder(builder)
    return _CALL("TF_DeleteAttrBuilder", builder)
end
_FUNCDEF("TF_DeleteAttrBuilder", { "TF_AttrBuilder *" }, "void")

--

---@param builder ffi.cdata @(TF_AttrBuilder *)
---@param attr_name string @(const char *)
---@param value TF_DataType @(TF_DataType)
function M.TF_AttrBuilderSetType(builder, attr_name, value)
    return _CALL("TF_AttrBuilderSetType", builder, attr_name, value)
end
_FUNCDEF("TF_AttrBuilderSetType", { "TF_AttrBuilder *", "const char *", "TF_DataType" }, "void")

--

---@param builder ffi.cdata @(TF_AttrBuilder *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const TF_DataType *)
---@param num_values number @(int)
function M.TF_AttrBuilderSetTypeList(builder, attr_name, values, num_values)
    return _CALL("TF_AttrBuilderSetTypeList", builder, attr_name, values, num_values)
end
_FUNCDEF("TF_AttrBuilderSetTypeList", { "TF_AttrBuilder *", "const char *", "const TF_DataType *", "int" }, "void")

--

--- Checks the tensorflow::NodeDef built via the methods above to see if it can
--- run on device_type.
--- 
---@param builder ffi.cdata @(TF_AttrBuilder *)
---@param device_type string @(const char *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_AttrBuilderCheckCanRunOnDevice(builder, device_type, status)
    return _CALL("TF_AttrBuilderCheckCanRunOnDevice", builder, device_type, status)
end
_FUNCDEF("TF_AttrBuilderCheckCanRunOnDevice", { "TF_AttrBuilder *", "const char *", "TF_Status *" }, "void")

--

--- For argument number input_index, fetch the corresponding number_attr that
--- needs to be updated with the argument length of the input list.
--- Returns nullptr if there is any problem like op_name is not found, or the
--- argument does not support this attribute type.
--- 
---@param op_name string @(const char *)
---@param input_index number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return string @(const char *)
function M.TF_GetNumberAttrForOpListInput(op_name, input_index, status)
    return _CALL("TF_GetNumberAttrForOpListInput", op_name, input_index, status)
end
_FUNCDEF("TF_GetNumberAttrForOpListInput", { "const char *", "int", "TF_Status *" }, "const char *")

--

--- Returns 1 if the op is stateful, 0 otherwise. The return value is undefined
--- if the status is not ok.
--- 
---@param op_type string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int)
function M.TF_OpIsStateful(op_type, status)
    return _CALL("TF_OpIsStateful", op_type, status)
end
_FUNCDEF("TF_OpIsStateful", { "const char *", "TF_Status *" }, "int")

--

--- Platform specific initialization routine. Very few platforms actually require
--- this to be called.
--- 
---@param usage string @(const char *)
---@param argc ffi.cdata @(int *)
---@param argv ffi.cdata @(char * * *)
function M.TF_InitMain(usage, argc, argv)
    return _CALL("TF_InitMain", usage, argc, argv)
end
_FUNCDEF("TF_InitMain", { "const char *", "int *", "char * * *" }, "void")

--

--- Platform-specific implementation to return an unused port. (This should used
--- in tests only.)
--- 
---@return number @(int)
function M.TF_PickUnusedPortOrDie()
    return _CALL("TF_PickUnusedPortOrDie")
end
_FUNCDEF("TF_PickUnusedPortOrDie", {  }, "int")

--

--- Fast path method that makes constructing a single scalar tensor require less
--- overhead and copies.
--- 
---@param data_type TF_DataType @(TF_DataType)
---@param data ffi.cdata @(void *)
---@param len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_TensorHandle *)
function M.TFE_NewTensorHandleFromScalar(data_type, data, len, status)
    return _CALL("TFE_NewTensorHandleFromScalar", data_type, data, len, status)
end
_FUNCDEF("TFE_NewTensorHandleFromScalar", { "TF_DataType", "void *", "size_t", "TF_Status *" }, "TFE_TensorHandle *")

--

--- Specify the server_def that enables collective ops.
--- This is different to the above function in that it doesn't create remote
--- contexts, and remotely executing ops is not possible. It just enables
--- communication for collective ops.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_EnableCollectiveOps(ctx, proto, proto_len, status)
    return _CALL("TFE_EnableCollectiveOps", ctx, proto, proto_len, status)
end
_FUNCDEF("TFE_EnableCollectiveOps", { "TFE_Context *", "const void *", "size_t", "TF_Status *" }, "void")

--

--- Aborts all ongoing collectives with the specified status. After abortion,
--- subsequent collectives will error with this status immediately. To reset the
--- collectives, create a new EagerContext.
--- This is intended to be used when a peer failure is detected.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_AbortCollectiveOps(ctx, status)
    return _CALL("TFE_AbortCollectiveOps", ctx, status)
end
_FUNCDEF("TFE_AbortCollectiveOps", { "TFE_Context *", "TF_Status *" }, "void")

--

--- Checks the health of collective ops peers. Explicit health check is needed in
--- multi worker collective ops to detect failures in the cluster.  If a peer is
--- down, collective ops may hang.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param task string @(const char *)
---@param timeout_in_ms number @(int64_t)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_CollectiveOpsCheckPeerHealth(ctx, task, timeout_in_ms, status)
    return _CALL("TFE_CollectiveOpsCheckPeerHealth", ctx, task, timeout_in_ms, status)
end
_FUNCDEF("TFE_CollectiveOpsCheckPeerHealth", { "TFE_Context *", "const char *", "int64_t", "TF_Status *" }, "void")

--

_TYPEDEF("TF_ShapeAndType", "struct TF_ShapeAndType")

--

_TYPEDEF("TF_ShapeAndTypeList", "struct TF_ShapeAndTypeList")

--

--- API for manipulating TF_ShapeAndTypeList objects.
--- 
---@param num_shapes number @(int)
---@return ffi.cdata @(TF_ShapeAndTypeList *)
function M.TF_NewShapeAndTypeList(num_shapes)
    return _CALL("TF_NewShapeAndTypeList", num_shapes)
end
_FUNCDEF("TF_NewShapeAndTypeList", { "int" }, "TF_ShapeAndTypeList *")

--

---@param shape_list ffi.cdata @(TF_ShapeAndTypeList *)
---@param index number @(int)
---@param dims ffi.cdata @(const int64_t *)
---@param num_dims number @(int)
function M.TF_ShapeAndTypeListSetShape(shape_list, index, dims, num_dims)
    return _CALL("TF_ShapeAndTypeListSetShape", shape_list, index, dims, num_dims)
end
_FUNCDEF("TF_ShapeAndTypeListSetShape", { "TF_ShapeAndTypeList *", "int", "const int64_t *", "int" }, "void")

--

---@param shape_list ffi.cdata @(TF_ShapeAndTypeList *)
---@param index number @(int)
function M.TF_ShapeAndTypeListSetUnknownShape(shape_list, index)
    return _CALL("TF_ShapeAndTypeListSetUnknownShape", shape_list, index)
end
_FUNCDEF("TF_ShapeAndTypeListSetUnknownShape", { "TF_ShapeAndTypeList *", "int" }, "void")

--

---@param shape_list ffi.cdata @(TF_ShapeAndTypeList *)
---@param index number @(int)
---@param dtype TF_DataType @(TF_DataType)
function M.TF_ShapeAndTypeListSetDtype(shape_list, index, dtype)
    return _CALL("TF_ShapeAndTypeListSetDtype", shape_list, index, dtype)
end
_FUNCDEF("TF_ShapeAndTypeListSetDtype", { "TF_ShapeAndTypeList *", "int", "TF_DataType" }, "void")

--

---@param shape_list ffi.cdata @(TF_ShapeAndTypeList *)
function M.TF_DeleteShapeAndTypeList(shape_list)
    return _CALL("TF_DeleteShapeAndTypeList", shape_list)
end
_FUNCDEF("TF_DeleteShapeAndTypeList", { "TF_ShapeAndTypeList *" }, "void")

--

---@param shape_list_array ffi.cdata @(TF_ShapeAndTypeList * *)
---@param num_items number @(int)
function M.TF_DeleteShapeAndTypeListArray(shape_list_array, num_items)
    return _CALL("TF_DeleteShapeAndTypeListArray", shape_list_array, num_items)
end
_FUNCDEF("TF_DeleteShapeAndTypeListArray", { "TF_ShapeAndTypeList * *", "int" }, "void")

--

--- Infer shapes for the given `op`. The arguments mimic the arguments of the
--- `shape_inference::InferenceContext` constructor. Note the following:
--- - The inputs of the `op` are not used for shape inference. So, it is
--- OK to not have the inputs properly set in `op`. See `input_tensors`
--- if you want shape inference to consider the input tensors of the
--- op for shape inference.
--- - The types need not be set in `input_shapes` as it is not used.
--- - The number of `input_tensors` should be the same as the number of items
--- in `input_shapes`.
--- The results are returned in `output_shapes` and
--- `output_resource_shapes_and_types`. The caller is responsible for freeing the
--- memory in these buffers by calling `TF_DeleteShapeAndTypeList`.
--- 
---@param op ffi.cdata @(TFE_Op *)
---@param input_shapes ffi.cdata @(TF_ShapeAndTypeList *)
---@param input_tensors ffi.cdata @(TF_Tensor * *)
---@param input_tensor_as_shapes ffi.cdata @(TF_ShapeAndTypeList *)
---@param input_resource_shapes_and_types ffi.cdata @(TF_ShapeAndTypeList * *)
---@param output_shapes ffi.cdata @(TF_ShapeAndTypeList * *)
---@param output_resource_shapes_and_types ffi.cdata @(TF_ShapeAndTypeList * * *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_InferShapes(op, input_shapes, input_tensors, input_tensor_as_shapes, input_resource_shapes_and_types, output_shapes, output_resource_shapes_and_types, status)
    return _CALL("TFE_InferShapes", op, input_shapes, input_tensors, input_tensor_as_shapes, input_resource_shapes_and_types, output_shapes, output_resource_shapes_and_types, status)
end
_FUNCDEF("TFE_InferShapes", { "TFE_Op *", "TF_ShapeAndTypeList *", "TF_Tensor * *", "TF_ShapeAndTypeList *", "TF_ShapeAndTypeList * *", "TF_ShapeAndTypeList * *", "TF_ShapeAndTypeList * * *", "TF_Status *" }, "void")

--

---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
---@param enable number @(unsigned char)
function M.TF_ImportGraphDefOptionsSetValidateColocationConstraints(opts, enable)
    return _CALL("TF_ImportGraphDefOptionsSetValidateColocationConstraints", opts, enable)
end
_FUNCDEF("TF_ImportGraphDefOptionsSetValidateColocationConstraints", { "TF_ImportGraphDefOptions *", "unsigned char" }, "void")

--


return M

