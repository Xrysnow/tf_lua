--

local M = {}
local _TYPEDEF = require('ctypes').typedef
local _ENUMDEF = require('ctypes').enumdef
local _CALL = require('ctypes').caller(require('tf._lib'))
local _FUNCDEF = require('ctypes').addDef
-- header/c_api.h

--

--- --------------------------------------------------------------------------
--- --------------------------------------------------------------------------
--- TF_Version returns a string describing version information of the
--- TensorFlow library. TensorFlow using semantic versioning.
--- 
---@return string @(const char *)
function M.TF_Version()
    return _CALL("TF_Version")
end
_FUNCDEF("TF_Version", {  }, "const char *")

--

--- --------------------------------------------------------------------------
--- TF_Buffer holds a pointer to a block of data and its associated length.
--- Typically, the data consists of a serialized protocol buffer, but other data
--- may also be held in a buffer.
--- By default, TF_Buffer itself does not do any memory management of the
--- pointed-to block.  If need be, users of this struct should specify how to
--- deallocate the block by setting the `data_deallocator` function pointer.
--- 

_TYPEDEF("TF_Buffer", "struct TF_Buffer { const void * data ; size_t length ; void ( * data_deallocator ) ( void * data , size_t length ) ; }")

--

--- Makes a copy of the input and sets an appropriate deallocator.  Useful for
--- passing in read-only, input protobufs.
--- 
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@return ffi.cdata @(TF_Buffer *)
function M.TF_NewBufferFromString(proto, proto_len)
    return _CALL("TF_NewBufferFromString", proto, proto_len)
end
_FUNCDEF("TF_NewBufferFromString", { "const void *", "size_t" }, "TF_Buffer *")

--

--- Useful for passing *out* a protobuf.
--- 
---@return ffi.cdata @(TF_Buffer *)
function M.TF_NewBuffer()
    return _CALL("TF_NewBuffer")
end
_FUNCDEF("TF_NewBuffer", {  }, "TF_Buffer *")

--

---@param buffer ffi.cdata @(TF_Buffer *)
function M.TF_DeleteBuffer(buffer)
    return _CALL("TF_DeleteBuffer", buffer)
end
_FUNCDEF("TF_DeleteBuffer", { "TF_Buffer *" }, "void")

--

---@param buffer ffi.cdata @(TF_Buffer *)
---@return TF_Buffer @(TF_Buffer)
function M.TF_GetBuffer(buffer)
    return _CALL("TF_GetBuffer", buffer)
end
_FUNCDEF("TF_GetBuffer", { "TF_Buffer *" }, "TF_Buffer")

--

--- --------------------------------------------------------------------------
--- Used to return strings across the C API. The caller does not take ownership
--- of the underlying data pointer and is not responsible for freeing it.
--- 

_TYPEDEF("TF_StringView", "struct TF_StringView { const char * data ; size_t len ; }")

--

--- --------------------------------------------------------------------------
--- TF_SessionOptions holds options that can be passed during session creation.
--- 

_TYPEDEF("TF_SessionOptions", "struct TF_SessionOptions")

--

--- Return a new options object.
--- 
---@return ffi.cdata @(TF_SessionOptions *)
function M.TF_NewSessionOptions()
    return _CALL("TF_NewSessionOptions")
end
_FUNCDEF("TF_NewSessionOptions", {  }, "TF_SessionOptions *")

--

--- Set the target in TF_SessionOptions.options.
--- target can be empty, a single entry, or a comma separated list of entries.
--- Each entry is in one of the following formats :
--- "local"
--- ip:port
--- host:port
--- 
---@param options ffi.cdata @(TF_SessionOptions *)
---@param target string @(const char *)
function M.TF_SetTarget(options, target)
    return _CALL("TF_SetTarget", options, target)
end
_FUNCDEF("TF_SetTarget", { "TF_SessionOptions *", "const char *" }, "void")

--

--- Set the config in TF_SessionOptions.options.
--- config should be a serialized tensorflow.ConfigProto proto.
--- If config was not parsed successfully as a ConfigProto, record the
--- error information in *status.
--- 
---@param options ffi.cdata @(TF_SessionOptions *)
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TF_SetConfig(options, proto, proto_len, status)
    return _CALL("TF_SetConfig", options, proto, proto_len, status)
end
_FUNCDEF("TF_SetConfig", { "TF_SessionOptions *", "const void *", "size_t", "TF_Status *" }, "void")

--

--- Destroy an options object.
--- 
---@param options ffi.cdata @(TF_SessionOptions *)
function M.TF_DeleteSessionOptions(options)
    return _CALL("TF_DeleteSessionOptions", options)
end
_FUNCDEF("TF_DeleteSessionOptions", { "TF_SessionOptions *" }, "void")

--

--- TODO(jeff,sanjay):
--- - export functions to set Config fields
--- --------------------------------------------------------------------------
--- The new graph construction API, still under development.
--- Represents a computation graph.  Graphs may be shared between sessions.
--- Graphs are thread-safe when used as directed below.
--- 

_TYPEDEF("TF_Graph", "struct TF_Graph")

--

--- Return a new graph object.
--- 
---@return ffi.cdata @(TF_Graph *)
function M.TF_NewGraph()
    return _CALL("TF_NewGraph")
end
_FUNCDEF("TF_NewGraph", {  }, "TF_Graph *")

--

--- Destroy an options object.  Graph will be deleted once no more
--- TFSession's are referencing it.
--- 
---@param graph ffi.cdata @(TF_Graph *)
function M.TF_DeleteGraph(graph)
    return _CALL("TF_DeleteGraph", graph)
end
_FUNCDEF("TF_DeleteGraph", { "TF_Graph *" }, "void")

--

--- Operation being built. The underlying graph must outlive this.
--- 

_TYPEDEF("TF_OperationDescription", "struct TF_OperationDescription")

--

--- Operation that has been added to the graph. Valid until the graph is
--- deleted -- in particular adding a new operation to the graph does not
--- invalidate old TF_Operation* pointers.
--- 

_TYPEDEF("TF_Operation", "struct TF_Operation")

--

--- Represents a specific input of an operation.
--- The index of the input within oper.
--- 

_TYPEDEF("TF_Input", "struct TF_Input { TF_Operation * oper ; int index ; }")

--

--- Represents a specific output of an operation.
--- The index of the output within oper.
--- 

_TYPEDEF("TF_Output", "struct TF_Output { TF_Operation * oper ; int index ; }")

--

--- TF_Function is a grouping of operations with defined inputs and outputs.
--- Once created and added to graphs, functions can be invoked by creating an
--- operation whose operation type matches the function name.
--- 

_TYPEDEF("TF_Function", "struct TF_Function")

--

--- Function definition options. TODO(iga): Define and implement
--- 

_TYPEDEF("TF_FunctionOptions", "struct TF_FunctionOptions")

--

--- Sets the shape of the Tensor referenced by `output` in `graph` to
--- the shape described by `dims` and `num_dims`.
--- If the number of dimensions is unknown, `num_dims` must be set to
--- -1 and `dims` can be null. If a dimension is unknown, the
--- corresponding entry in the `dims` array must be -1.
--- This does not overwrite the existing shape associated with `output`,
--- but merges the input shape with the existing shape.  For example,
--- setting a shape of [-1, 2] with an existing shape [2, -1] would set
--- a final shape of [2, 2] based on shape merging semantics.
--- Returns an error into `status` if:
--- `output` is not in `graph`.
--- An invalid shape is being set (e.g., the shape being set
--- is incompatible with the existing shape).
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param output TF_Output @(TF_Output)
---@param dims ffi.cdata @(const int64_t *)
---@param num_dims number @(const int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_GraphSetTensorShape(graph, output, dims, num_dims, status)
    return _CALL("TF_GraphSetTensorShape", graph, output, dims, num_dims, status)
end
_FUNCDEF("TF_GraphSetTensorShape", { "TF_Graph *", "TF_Output", "const int64_t *", "const int", "TF_Status *" }, "void")

--

--- Returns the number of dimensions of the Tensor referenced by `output`
--- in `graph`.
--- If the number of dimensions in the shape is unknown, returns -1.
--- Returns an error into `status` if:
--- `output` is not in `graph`.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param output TF_Output @(TF_Output)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int)
function M.TF_GraphGetTensorNumDims(graph, output, status)
    return _CALL("TF_GraphGetTensorNumDims", graph, output, status)
end
_FUNCDEF("TF_GraphGetTensorNumDims", { "TF_Graph *", "TF_Output", "TF_Status *" }, "int")

--

--- Returns the shape of the Tensor referenced by `output` in `graph`
--- into `dims`. `dims` must be an array large enough to hold `num_dims`
--- entries (e.g., the return value of TF_GraphGetTensorNumDims).
--- If the number of dimensions in the shape is unknown or the shape is
--- a scalar, `dims` will remain untouched. Otherwise, each element of
--- `dims` will be set corresponding to the size of the dimension. An
--- unknown dimension is represented by `-1`.
--- Returns an error into `status` if:
--- `output` is not in `graph`.
--- `num_dims` does not match the actual number of dimensions.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param output TF_Output @(TF_Output)
---@param dims ffi.cdata @(int64_t *)
---@param num_dims number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_GraphGetTensorShape(graph, output, dims, num_dims, status)
    return _CALL("TF_GraphGetTensorShape", graph, output, dims, num_dims, status)
end
_FUNCDEF("TF_GraphGetTensorShape", { "TF_Graph *", "TF_Output", "int64_t *", "int", "TF_Status *" }, "void")

--

--- Operation will only be added to *graph when TF_FinishOperation() is
--- called (assuming TF_FinishOperation() does not return an error).
--- graph must not be deleted until after TF_FinishOperation() is
--- called.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param op_type string @(const char *)
---@param oper_name string @(const char *)
---@return ffi.cdata @(TF_OperationDescription *)
function M.TF_NewOperation(graph, op_type, oper_name)
    return _CALL("TF_NewOperation", graph, op_type, oper_name)
end
_FUNCDEF("TF_NewOperation", { "TF_Graph *", "const char *", "const char *" }, "TF_OperationDescription *")

--

--- Specify the device for `desc`.  Defaults to empty, meaning unconstrained.
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param device string @(const char *)
function M.TF_SetDevice(desc, device)
    return _CALL("TF_SetDevice", desc, device)
end
_FUNCDEF("TF_SetDevice", { "TF_OperationDescription *", "const char *" }, "void")

--

--- The calls to TF_AddInput and TF_AddInputList must match (in number,
--- order, and type) the op declaration.  For example, the "Concat" op
--- has registration:
--- REGISTER_OP("Concat")
--- .Input("concat_dim: int32")
--- .Input("values: N * T")
--- .Output("output: T")
--- .Attr("N: int >= 2")
--- .Attr("T: type");
--- that defines two inputs, "concat_dim" and "values" (in that order).
--- You must use TF_AddInput() for the first input (since it takes a
--- single tensor), and TF_AddInputList() for the second input (since
--- it takes a list, even if you were to pass a list with a single
--- tensor), as in:
--- TF_OperationDescription* desc = TF_NewOperation(graph, "Concat", "c");
--- TF_Output concat_dim_input = {...};
--- TF_AddInput(desc, concat_dim_input);
--- TF_Output values_inputs[5] = {{...}, ..., {...}};
--- TF_AddInputList(desc, values_inputs, 5);
--- For inputs that take a single tensor.
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param input TF_Output @(TF_Output)
function M.TF_AddInput(desc, input)
    return _CALL("TF_AddInput", desc, input)
end
_FUNCDEF("TF_AddInput", { "TF_OperationDescription *", "TF_Output" }, "void")

--

--- For inputs that take a list of tensors.
--- inputs must point to TF_Output[num_inputs].
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param inputs ffi.cdata @(const TF_Output *)
---@param num_inputs number @(int)
function M.TF_AddInputList(desc, inputs, num_inputs)
    return _CALL("TF_AddInputList", desc, inputs, num_inputs)
end
_FUNCDEF("TF_AddInputList", { "TF_OperationDescription *", "const TF_Output *", "int" }, "void")

--

--- Call once per control input to `desc`.
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param input ffi.cdata @(TF_Operation *)
function M.TF_AddControlInput(desc, input)
    return _CALL("TF_AddControlInput", desc, input)
end
_FUNCDEF("TF_AddControlInput", { "TF_OperationDescription *", "TF_Operation *" }, "void")

--

--- Request that `desc` be co-located on the device where `op`
--- is placed.
--- Use of this is discouraged since the implementation of device placement is
--- subject to change. Primarily intended for internal libraries
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param op ffi.cdata @(TF_Operation *)
function M.TF_ColocateWith(desc, op)
    return _CALL("TF_ColocateWith", desc, op)
end
_FUNCDEF("TF_ColocateWith", { "TF_OperationDescription *", "TF_Operation *" }, "void")

--

--- Call some TF_SetAttr*() function for every attr that is not
--- inferred from an input and doesn't have a default value you wish to
--- keep.
--- `value` must point to a string of length `length` bytes.
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(const void *)
---@param length number @(size_t)
function M.TF_SetAttrString(desc, attr_name, value, length)
    return _CALL("TF_SetAttrString", desc, attr_name, value, length)
end
_FUNCDEF("TF_SetAttrString", { "TF_OperationDescription *", "const char *", "const void *", "size_t" }, "void")

--

--- `values` and `lengths` each must have lengths `num_values`.
--- `values[i]` must point to a string of length `lengths[i]` bytes.
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const void * const *)
---@param lengths ffi.cdata @(const size_t *)
---@param num_values number @(int)
function M.TF_SetAttrStringList(desc, attr_name, values, lengths, num_values)
    return _CALL("TF_SetAttrStringList", desc, attr_name, values, lengths, num_values)
end
_FUNCDEF("TF_SetAttrStringList", { "TF_OperationDescription *", "const char *", "const void * const *", "const size_t *", "int" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param value number @(int64_t)
function M.TF_SetAttrInt(desc, attr_name, value)
    return _CALL("TF_SetAttrInt", desc, attr_name, value)
end
_FUNCDEF("TF_SetAttrInt", { "TF_OperationDescription *", "const char *", "int64_t" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const int64_t *)
---@param num_values number @(int)
function M.TF_SetAttrIntList(desc, attr_name, values, num_values)
    return _CALL("TF_SetAttrIntList", desc, attr_name, values, num_values)
end
_FUNCDEF("TF_SetAttrIntList", { "TF_OperationDescription *", "const char *", "const int64_t *", "int" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param value number @(float)
function M.TF_SetAttrFloat(desc, attr_name, value)
    return _CALL("TF_SetAttrFloat", desc, attr_name, value)
end
_FUNCDEF("TF_SetAttrFloat", { "TF_OperationDescription *", "const char *", "float" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const float *)
---@param num_values number @(int)
function M.TF_SetAttrFloatList(desc, attr_name, values, num_values)
    return _CALL("TF_SetAttrFloatList", desc, attr_name, values, num_values)
end
_FUNCDEF("TF_SetAttrFloatList", { "TF_OperationDescription *", "const char *", "const float *", "int" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param value number @(unsigned char)
function M.TF_SetAttrBool(desc, attr_name, value)
    return _CALL("TF_SetAttrBool", desc, attr_name, value)
end
_FUNCDEF("TF_SetAttrBool", { "TF_OperationDescription *", "const char *", "unsigned char" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const unsigned char *)
---@param num_values number @(int)
function M.TF_SetAttrBoolList(desc, attr_name, values, num_values)
    return _CALL("TF_SetAttrBoolList", desc, attr_name, values, num_values)
end
_FUNCDEF("TF_SetAttrBoolList", { "TF_OperationDescription *", "const char *", "const unsigned char *", "int" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param value TF_DataType @(TF_DataType)
function M.TF_SetAttrType(desc, attr_name, value)
    return _CALL("TF_SetAttrType", desc, attr_name, value)
end
_FUNCDEF("TF_SetAttrType", { "TF_OperationDescription *", "const char *", "TF_DataType" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(const TF_DataType *)
---@param num_values number @(int)
function M.TF_SetAttrTypeList(desc, attr_name, values, num_values)
    return _CALL("TF_SetAttrTypeList", desc, attr_name, values, num_values)
end
_FUNCDEF("TF_SetAttrTypeList", { "TF_OperationDescription *", "const char *", "const TF_DataType *", "int" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param placeholder string @(const char *)
function M.TF_SetAttrPlaceholder(desc, attr_name, placeholder)
    return _CALL("TF_SetAttrPlaceholder", desc, attr_name, placeholder)
end
_FUNCDEF("TF_SetAttrPlaceholder", { "TF_OperationDescription *", "const char *", "const char *" }, "void")

--

--- Set a 'func' attribute to the specified name.
--- `value` must point to a string of length `length` bytes.
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param value string @(const char *)
---@param length number @(size_t)
function M.TF_SetAttrFuncName(desc, attr_name, value, length)
    return _CALL("TF_SetAttrFuncName", desc, attr_name, value, length)
end
_FUNCDEF("TF_SetAttrFuncName", { "TF_OperationDescription *", "const char *", "const char *", "size_t" }, "void")

--

--- Set `num_dims` to -1 to represent "unknown rank".  Otherwise,
--- `dims` points to an array of length `num_dims`.  `dims[i]` must be
--- >= -1, with -1 meaning "unknown dimension".
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param dims ffi.cdata @(const int64_t *)
---@param num_dims number @(int)
function M.TF_SetAttrShape(desc, attr_name, dims, num_dims)
    return _CALL("TF_SetAttrShape", desc, attr_name, dims, num_dims)
end
_FUNCDEF("TF_SetAttrShape", { "TF_OperationDescription *", "const char *", "const int64_t *", "int" }, "void")

--

--- `dims` and `num_dims` must point to arrays of length `num_shapes`.
--- Set `num_dims[i]` to -1 to represent "unknown rank".  Otherwise,
--- `dims[i]` points to an array of length `num_dims[i]`.  `dims[i][j]`
--- must be >= -1, with -1 meaning "unknown dimension".
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param dims ffi.cdata @(const int64_t * const *)
---@param num_dims ffi.cdata @(const int *)
---@param num_shapes number @(int)
function M.TF_SetAttrShapeList(desc, attr_name, dims, num_dims, num_shapes)
    return _CALL("TF_SetAttrShapeList", desc, attr_name, dims, num_dims, num_shapes)
end
_FUNCDEF("TF_SetAttrShapeList", { "TF_OperationDescription *", "const char *", "const int64_t * const *", "const int *", "int" }, "void")

--

--- `proto` must point to an array of `proto_len` bytes representing a
--- binary-serialized TensorShapeProto.
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TF_SetAttrTensorShapeProto(desc, attr_name, proto, proto_len, status)
    return _CALL("TF_SetAttrTensorShapeProto", desc, attr_name, proto, proto_len, status)
end
_FUNCDEF("TF_SetAttrTensorShapeProto", { "TF_OperationDescription *", "const char *", "const void *", "size_t", "TF_Status *" }, "void")

--

--- `protos` and `proto_lens` must point to arrays of length `num_shapes`.
--- `protos[i]` must point to an array of `proto_lens[i]` bytes
--- representing a binary-serialized TensorShapeProto.
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param protos ffi.cdata @(const void * const *)
---@param proto_lens ffi.cdata @(const size_t *)
---@param num_shapes number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_SetAttrTensorShapeProtoList(desc, attr_name, protos, proto_lens, num_shapes, status)
    return _CALL("TF_SetAttrTensorShapeProtoList", desc, attr_name, protos, proto_lens, num_shapes, status)
end
_FUNCDEF("TF_SetAttrTensorShapeProtoList", { "TF_OperationDescription *", "const char *", "const void * const *", "const size_t *", "int", "TF_Status *" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(TF_Tensor *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_SetAttrTensor(desc, attr_name, value, status)
    return _CALL("TF_SetAttrTensor", desc, attr_name, value, status)
end
_FUNCDEF("TF_SetAttrTensor", { "TF_OperationDescription *", "const char *", "TF_Tensor *", "TF_Status *" }, "void")

--

---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(TF_Tensor * const *)
---@param num_values number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_SetAttrTensorList(desc, attr_name, values, num_values, status)
    return _CALL("TF_SetAttrTensorList", desc, attr_name, values, num_values, status)
end
_FUNCDEF("TF_SetAttrTensorList", { "TF_OperationDescription *", "const char *", "TF_Tensor * const *", "int", "TF_Status *" }, "void")

--

--- `proto` should point to a sequence of bytes of length `proto_len`
--- representing a binary serialization of an AttrValue protocol
--- buffer.
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param attr_name string @(const char *)
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TF_SetAttrValueProto(desc, attr_name, proto, proto_len, status)
    return _CALL("TF_SetAttrValueProto", desc, attr_name, proto, proto_len, status)
end
_FUNCDEF("TF_SetAttrValueProto", { "TF_OperationDescription *", "const char *", "const void *", "size_t", "TF_Status *" }, "void")

--

--- If this function succeeds:
--- *status is set to an OK value,
--- a TF_Operation is added to the graph,
--- a non-null value pointing to the added operation is returned --
--- this value is valid until the underlying graph is deleted.
--- Otherwise:
--- *status is set to a non-OK value,
--- the graph is not modified,
--- a null value is returned.
--- In either case, it deletes `desc`.
--- 
---@param desc ffi.cdata @(TF_OperationDescription *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Operation *)
function M.TF_FinishOperation(desc, status)
    return _CALL("TF_FinishOperation", desc, status)
end
_FUNCDEF("TF_FinishOperation", { "TF_OperationDescription *", "TF_Status *" }, "TF_Operation *")

--

--- TF_Operation functions.  Operations are immutable once created, so
--- these are all query functions.
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@return string @(const char *)
function M.TF_OperationName(oper)
    return _CALL("TF_OperationName", oper)
end
_FUNCDEF("TF_OperationName", { "TF_Operation *" }, "const char *")

--

---@param oper ffi.cdata @(TF_Operation *)
---@return string @(const char *)
function M.TF_OperationOpType(oper)
    return _CALL("TF_OperationOpType", oper)
end
_FUNCDEF("TF_OperationOpType", { "TF_Operation *" }, "const char *")

--

---@param oper ffi.cdata @(TF_Operation *)
---@return string @(const char *)
function M.TF_OperationDevice(oper)
    return _CALL("TF_OperationDevice", oper)
end
_FUNCDEF("TF_OperationDevice", { "TF_Operation *" }, "const char *")

--

---@param oper ffi.cdata @(TF_Operation *)
---@return number @(int)
function M.TF_OperationNumOutputs(oper)
    return _CALL("TF_OperationNumOutputs", oper)
end
_FUNCDEF("TF_OperationNumOutputs", { "TF_Operation *" }, "int")

--

---@param oper_out TF_Output @(TF_Output)
---@return TF_DataType @(TF_DataType)
function M.TF_OperationOutputType(oper_out)
    return _CALL("TF_OperationOutputType", oper_out)
end
_FUNCDEF("TF_OperationOutputType", { "TF_Output" }, "TF_DataType")

--

---@param oper ffi.cdata @(TF_Operation *)
---@param arg_name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int)
function M.TF_OperationOutputListLength(oper, arg_name, status)
    return _CALL("TF_OperationOutputListLength", oper, arg_name, status)
end
_FUNCDEF("TF_OperationOutputListLength", { "TF_Operation *", "const char *", "TF_Status *" }, "int")

--

---@param oper ffi.cdata @(TF_Operation *)
---@return number @(int)
function M.TF_OperationNumInputs(oper)
    return _CALL("TF_OperationNumInputs", oper)
end
_FUNCDEF("TF_OperationNumInputs", { "TF_Operation *" }, "int")

--

---@param oper_in TF_Input @(TF_Input)
---@return TF_DataType @(TF_DataType)
function M.TF_OperationInputType(oper_in)
    return _CALL("TF_OperationInputType", oper_in)
end
_FUNCDEF("TF_OperationInputType", { "TF_Input" }, "TF_DataType")

--

---@param oper ffi.cdata @(TF_Operation *)
---@param arg_name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int)
function M.TF_OperationInputListLength(oper, arg_name, status)
    return _CALL("TF_OperationInputListLength", oper, arg_name, status)
end
_FUNCDEF("TF_OperationInputListLength", { "TF_Operation *", "const char *", "TF_Status *" }, "int")

--

--- In this code:
--- TF_Output producer = TF_OperationInput(consumer);
--- There is an edge from producer.oper's output (given by
--- producer.index) to consumer.oper's input (given by consumer.index).
--- 
---@param oper_in TF_Input @(TF_Input)
---@return TF_Output @(TF_Output)
function M.TF_OperationInput(oper_in)
    return _CALL("TF_OperationInput", oper_in)
end
_FUNCDEF("TF_OperationInput", { "TF_Input" }, "TF_Output")

--

--- Get list of all inputs of a specific operation.  `inputs` must point to
--- an array of length at least `max_inputs` (ideally set to
--- TF_OperationNumInputs(oper)).  Beware that a concurrent
--- modification of the graph can increase the number of inputs of
--- an operation.
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param inputs ffi.cdata @(TF_Output *)
---@param max_inputs number @(int)
function M.TF_OperationAllInputs(oper, inputs, max_inputs)
    return _CALL("TF_OperationAllInputs", oper, inputs, max_inputs)
end
_FUNCDEF("TF_OperationAllInputs", { "TF_Operation *", "TF_Output *", "int" }, "void")

--

--- Get the number of current consumers of a specific output of an
--- operation.  Note that this number can change when new operations
--- are added to the graph.
--- 
---@param oper_out TF_Output @(TF_Output)
---@return number @(int)
function M.TF_OperationOutputNumConsumers(oper_out)
    return _CALL("TF_OperationOutputNumConsumers", oper_out)
end
_FUNCDEF("TF_OperationOutputNumConsumers", { "TF_Output" }, "int")

--

--- Get list of all current consumers of a specific output of an
--- operation.  `consumers` must point to an array of length at least
--- `max_consumers` (ideally set to
--- TF_OperationOutputNumConsumers(oper_out)).  Beware that a concurrent
--- modification of the graph can increase the number of consumers of
--- an operation.  Returns the number of output consumers (should match
--- TF_OperationOutputNumConsumers(oper_out)).
--- 
---@param oper_out TF_Output @(TF_Output)
---@param consumers ffi.cdata @(TF_Input *)
---@param max_consumers number @(int)
---@return number @(int)
function M.TF_OperationOutputConsumers(oper_out, consumers, max_consumers)
    return _CALL("TF_OperationOutputConsumers", oper_out, consumers, max_consumers)
end
_FUNCDEF("TF_OperationOutputConsumers", { "TF_Output", "TF_Input *", "int" }, "int")

--

--- Get the number of control inputs to an operation.
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@return number @(int)
function M.TF_OperationNumControlInputs(oper)
    return _CALL("TF_OperationNumControlInputs", oper)
end
_FUNCDEF("TF_OperationNumControlInputs", { "TF_Operation *" }, "int")

--

--- Get list of all control inputs to an operation.  `control_inputs` must
--- point to an array of length `max_control_inputs` (ideally set to
--- TF_OperationNumControlInputs(oper)).  Returns the number of control
--- inputs (should match TF_OperationNumControlInputs(oper)).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param control_inputs ffi.cdata @(TF_Operation * *)
---@param max_control_inputs number @(int)
---@return number @(int)
function M.TF_OperationGetControlInputs(oper, control_inputs, max_control_inputs)
    return _CALL("TF_OperationGetControlInputs", oper, control_inputs, max_control_inputs)
end
_FUNCDEF("TF_OperationGetControlInputs", { "TF_Operation *", "TF_Operation * *", "int" }, "int")

--

--- Get the number of operations that have `*oper` as a control input.
--- Note that this number can change when new operations are added to
--- the graph.
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@return number @(int)
function M.TF_OperationNumControlOutputs(oper)
    return _CALL("TF_OperationNumControlOutputs", oper)
end
_FUNCDEF("TF_OperationNumControlOutputs", { "TF_Operation *" }, "int")

--

--- Get the list of operations that have `*oper` as a control input.
--- `control_outputs` must point to an array of length at least
--- `max_control_outputs` (ideally set to
--- TF_OperationNumControlOutputs(oper)). Beware that a concurrent
--- modification of the graph can increase the number of control
--- outputs.  Returns the number of control outputs (should match
--- TF_OperationNumControlOutputs(oper)).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param control_outputs ffi.cdata @(TF_Operation * *)
---@param max_control_outputs number @(int)
---@return number @(int)
function M.TF_OperationGetControlOutputs(oper, control_outputs, max_control_outputs)
    return _CALL("TF_OperationGetControlOutputs", oper, control_outputs, max_control_outputs)
end
_FUNCDEF("TF_OperationGetControlOutputs", { "TF_Operation *", "TF_Operation * *", "int" }, "int")

--

--- TF_AttrMetadata describes the value of an attribute on an operation.
--- A boolean: 1 if the attribute value is a list, 0 otherwise.
--- Length of the list if is_list is true. Undefined otherwise.
--- Type of elements of the list if is_list != 0.
--- Type of the single value stored in the attribute if is_list == 0.
--- Total size the attribute value.
--- The units of total_size depend on is_list and type.
--- (1) If type == TF_ATTR_STRING and is_list == 0
--- then total_size is the byte size of the string
--- valued attribute.
--- (2) If type == TF_ATTR_STRING and is_list == 1
--- then total_size is the cumulative byte size
--- of all the strings in the list.
--- (3) If type == TF_ATTR_SHAPE and is_list == 0
--- then total_size is the number of dimensions
--- of the shape valued attribute, or -1
--- if its rank is unknown.
--- (4) If type == TF_ATTR_SHAPE and is_list == 1
--- then total_size is the cumulative number
--- of dimensions of all shapes in the list.
--- (5) Otherwise, total_size is undefined.
--- 

_TYPEDEF("TF_AttrMetadata", "struct TF_AttrMetadata { unsigned char is_list ; int64_t list_size ; TF_AttrType type ; int64_t total_size ; }")

--

--- Returns metadata about the value of the attribute `attr_name` of `oper`.
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return TF_AttrMetadata @(TF_AttrMetadata)
function M.TF_OperationGetAttrMetadata(oper, attr_name, status)
    return _CALL("TF_OperationGetAttrMetadata", oper, attr_name, status)
end
_FUNCDEF("TF_OperationGetAttrMetadata", { "TF_Operation *", "const char *", "TF_Status *" }, "TF_AttrMetadata")

--

--- Fills in `value` with the value of the attribute `attr_name`.  `value` must
--- point to an array of length at least `max_length` (ideally set to
--- TF_AttrMetadata.total_size from TF_OperationGetAttrMetadata(oper,
--- attr_name)).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(void *)
---@param max_length number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrString(oper, attr_name, value, max_length, status)
    return _CALL("TF_OperationGetAttrString", oper, attr_name, value, max_length, status)
end
_FUNCDEF("TF_OperationGetAttrString", { "TF_Operation *", "const char *", "void *", "size_t", "TF_Status *" }, "void")

--

--- Get the list of strings in the value of the attribute `attr_name`.  Fills in
--- `values` and `lengths`, each of which must point to an array of length at
--- least `max_values`.
--- The elements of values will point to addresses in `storage` which must be at
--- least `storage_size` bytes in length.  Ideally, max_values would be set to
--- TF_AttrMetadata.list_size and `storage` would be at least
--- TF_AttrMetadata.total_size, obtained from TF_OperationGetAttrMetadata(oper,
--- attr_name).
--- Fails if storage_size is too small to hold the requested number of strings.
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(void * *)
---@param lengths ffi.cdata @(size_t *)
---@param max_values number @(int)
---@param storage ffi.cdata @(void *)
---@param storage_size number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrStringList(oper, attr_name, values, lengths, max_values, storage, storage_size, status)
    return _CALL("TF_OperationGetAttrStringList", oper, attr_name, values, lengths, max_values, storage, storage_size, status)
end
_FUNCDEF("TF_OperationGetAttrStringList", { "TF_Operation *", "const char *", "void * *", "size_t *", "int", "void *", "size_t", "TF_Status *" }, "void")

--

---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(int64_t *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrInt(oper, attr_name, value, status)
    return _CALL("TF_OperationGetAttrInt", oper, attr_name, value, status)
end
_FUNCDEF("TF_OperationGetAttrInt", { "TF_Operation *", "const char *", "int64_t *", "TF_Status *" }, "void")

--

--- Fills in `values` with the value of the attribute `attr_name` of `oper`.
--- `values` must point to an array of length at least `max_values` (ideally set
--- TF_AttrMetadata.list_size from TF_OperationGetAttrMetadata(oper,
--- attr_name)).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(int64_t *)
---@param max_values number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrIntList(oper, attr_name, values, max_values, status)
    return _CALL("TF_OperationGetAttrIntList", oper, attr_name, values, max_values, status)
end
_FUNCDEF("TF_OperationGetAttrIntList", { "TF_Operation *", "const char *", "int64_t *", "int", "TF_Status *" }, "void")

--

---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(float *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrFloat(oper, attr_name, value, status)
    return _CALL("TF_OperationGetAttrFloat", oper, attr_name, value, status)
end
_FUNCDEF("TF_OperationGetAttrFloat", { "TF_Operation *", "const char *", "float *", "TF_Status *" }, "void")

--

--- Fills in `values` with the value of the attribute `attr_name` of `oper`.
--- `values` must point to an array of length at least `max_values` (ideally set
--- to TF_AttrMetadata.list_size from TF_OperationGetAttrMetadata(oper,
--- attr_name)).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(float *)
---@param max_values number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrFloatList(oper, attr_name, values, max_values, status)
    return _CALL("TF_OperationGetAttrFloatList", oper, attr_name, values, max_values, status)
end
_FUNCDEF("TF_OperationGetAttrFloatList", { "TF_Operation *", "const char *", "float *", "int", "TF_Status *" }, "void")

--

---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(unsigned char *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrBool(oper, attr_name, value, status)
    return _CALL("TF_OperationGetAttrBool", oper, attr_name, value, status)
end
_FUNCDEF("TF_OperationGetAttrBool", { "TF_Operation *", "const char *", "unsigned char *", "TF_Status *" }, "void")

--

--- Fills in `values` with the value of the attribute `attr_name` of `oper`.
--- `values` must point to an array of length at least `max_values` (ideally set
--- to TF_AttrMetadata.list_size from TF_OperationGetAttrMetadata(oper,
--- attr_name)).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(unsigned char *)
---@param max_values number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrBoolList(oper, attr_name, values, max_values, status)
    return _CALL("TF_OperationGetAttrBoolList", oper, attr_name, values, max_values, status)
end
_FUNCDEF("TF_OperationGetAttrBoolList", { "TF_Operation *", "const char *", "unsigned char *", "int", "TF_Status *" }, "void")

--

---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(TF_DataType *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrType(oper, attr_name, value, status)
    return _CALL("TF_OperationGetAttrType", oper, attr_name, value, status)
end
_FUNCDEF("TF_OperationGetAttrType", { "TF_Operation *", "const char *", "TF_DataType *", "TF_Status *" }, "void")

--

--- Fills in `values` with the value of the attribute `attr_name` of `oper`.
--- `values` must point to an array of length at least `max_values` (ideally set
--- to TF_AttrMetadata.list_size from TF_OperationGetAttrMetadata(oper,
--- attr_name)).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(TF_DataType *)
---@param max_values number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrTypeList(oper, attr_name, values, max_values, status)
    return _CALL("TF_OperationGetAttrTypeList", oper, attr_name, values, max_values, status)
end
_FUNCDEF("TF_OperationGetAttrTypeList", { "TF_Operation *", "const char *", "TF_DataType *", "int", "TF_Status *" }, "void")

--

--- Fills in `value` with the value of the attribute `attr_name` of `oper`.
--- `values` must point to an array of length at least `num_dims` (ideally set to
--- TF_Attr_Meta.size from TF_OperationGetAttrMetadata(oper, attr_name)).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(int64_t *)
---@param num_dims number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrShape(oper, attr_name, value, num_dims, status)
    return _CALL("TF_OperationGetAttrShape", oper, attr_name, value, num_dims, status)
end
_FUNCDEF("TF_OperationGetAttrShape", { "TF_Operation *", "const char *", "int64_t *", "int", "TF_Status *" }, "void")

--

--- Fills in `dims` with the list of shapes in the attribute `attr_name` of
--- `oper` and `num_dims` with the corresponding number of dimensions. On return,
--- for every i where `num_dims[i]` > 0, `dims[i]` will be an array of
--- `num_dims[i]` elements. A value of -1 for `num_dims[i]` indicates that the
--- i-th shape in the list is unknown.
--- The elements of `dims` will point to addresses in `storage` which must be
--- large enough to hold at least `storage_size` int64_ts.  Ideally, `num_shapes`
--- would be set to TF_AttrMetadata.list_size and `storage_size` would be set to
--- TF_AttrMetadata.total_size from TF_OperationGetAttrMetadata(oper,
--- attr_name).
--- Fails if storage_size is insufficient to hold the requested shapes.
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param dims ffi.cdata @(int64_t * *)
---@param num_dims ffi.cdata @(int *)
---@param num_shapes number @(int)
---@param storage ffi.cdata @(int64_t *)
---@param storage_size number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrShapeList(oper, attr_name, dims, num_dims, num_shapes, storage, storage_size, status)
    return _CALL("TF_OperationGetAttrShapeList", oper, attr_name, dims, num_dims, num_shapes, storage, storage_size, status)
end
_FUNCDEF("TF_OperationGetAttrShapeList", { "TF_Operation *", "const char *", "int64_t * *", "int *", "int", "int64_t *", "int", "TF_Status *" }, "void")

--

--- Sets `value` to the binary-serialized TensorShapeProto of the value of
--- `attr_name` attribute of `oper`'.
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrTensorShapeProto(oper, attr_name, value, status)
    return _CALL("TF_OperationGetAttrTensorShapeProto", oper, attr_name, value, status)
end
_FUNCDEF("TF_OperationGetAttrTensorShapeProto", { "TF_Operation *", "const char *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- Fills in `values` with binary-serialized TensorShapeProto values of the
--- attribute `attr_name` of `oper`. `values` must point to an array of length at
--- least `num_values` (ideally set to TF_AttrMetadata.list_size from
--- TF_OperationGetAttrMetadata(oper, attr_name)).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(TF_Buffer * *)
---@param max_values number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrTensorShapeProtoList(oper, attr_name, values, max_values, status)
    return _CALL("TF_OperationGetAttrTensorShapeProtoList", oper, attr_name, values, max_values, status)
end
_FUNCDEF("TF_OperationGetAttrTensorShapeProtoList", { "TF_Operation *", "const char *", "TF_Buffer * *", "int", "TF_Status *" }, "void")

--

--- Gets the TF_Tensor valued attribute of `attr_name` of `oper`.
--- Allocates a new TF_Tensor which the caller is expected to take
--- ownership of (and can deallocate using TF_DeleteTensor).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param value ffi.cdata @(TF_Tensor * *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrTensor(oper, attr_name, value, status)
    return _CALL("TF_OperationGetAttrTensor", oper, attr_name, value, status)
end
_FUNCDEF("TF_OperationGetAttrTensor", { "TF_Operation *", "const char *", "TF_Tensor * *", "TF_Status *" }, "void")

--

--- Fills in `values` with the TF_Tensor values of the attribute `attr_name` of
--- `oper`. `values` must point to an array of TF_Tensor* of length at least
--- `max_values` (ideally set to TF_AttrMetadata.list_size from
--- TF_OperationGetAttrMetadata(oper, attr_name)).
--- The caller takes ownership of all the non-null TF_Tensor* entries in `values`
--- (which can be deleted using TF_DeleteTensor(values[i])).
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param values ffi.cdata @(TF_Tensor * *)
---@param max_values number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrTensorList(oper, attr_name, values, max_values, status)
    return _CALL("TF_OperationGetAttrTensorList", oper, attr_name, values, max_values, status)
end
_FUNCDEF("TF_OperationGetAttrTensorList", { "TF_Operation *", "const char *", "TF_Tensor * *", "int", "TF_Status *" }, "void")

--

--- Sets `output_attr_value` to the binary-serialized AttrValue proto
--- representation of the value of the `attr_name` attr of `oper`.
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param attr_name string @(const char *)
---@param output_attr_value ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationGetAttrValueProto(oper, attr_name, output_attr_value, status)
    return _CALL("TF_OperationGetAttrValueProto", oper, attr_name, output_attr_value, status)
end
_FUNCDEF("TF_OperationGetAttrValueProto", { "TF_Operation *", "const char *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- Returns the operation in the graph with `oper_name`. Returns nullptr if
--- no operation found.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param oper_name string @(const char *)
---@return ffi.cdata @(TF_Operation *)
function M.TF_GraphOperationByName(graph, oper_name)
    return _CALL("TF_GraphOperationByName", graph, oper_name)
end
_FUNCDEF("TF_GraphOperationByName", { "TF_Graph *", "const char *" }, "TF_Operation *")

--

--- Iterate through the operations of a graph.  To use:
--- size_t pos = 0;
--- TF_Operation* oper;
--- while ((oper = TF_GraphNextOperation(graph, &pos)) != nullptr) {
--- DoSomethingWithOperation(oper);
--- }
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param pos ffi.cdata @(size_t *)
---@return ffi.cdata @(TF_Operation *)
function M.TF_GraphNextOperation(graph, pos)
    return _CALL("TF_GraphNextOperation", graph, pos)
end
_FUNCDEF("TF_GraphNextOperation", { "TF_Graph *", "size_t *" }, "TF_Operation *")

--

--- Write out a serialized representation of `graph` (as a GraphDef protocol
--- message) to `output_graph_def` (allocated by TF_NewBuffer()).
--- `output_graph_def`'s underlying buffer will be freed when TF_DeleteBuffer()
--- is called.
--- May fail on very large graphs in the future.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param output_graph_def ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_GraphToGraphDef(graph, output_graph_def, status)
    return _CALL("TF_GraphToGraphDef", graph, output_graph_def, status)
end
_FUNCDEF("TF_GraphToGraphDef", { "TF_Graph *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- Returns the serialized OpDef proto with name `op_name`, or a bad status if no
--- such op exists. This can return OpDefs of functions copied into the graph.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param op_name string @(const char *)
---@param output_op_def ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_GraphGetOpDef(graph, op_name, output_op_def, status)
    return _CALL("TF_GraphGetOpDef", graph, op_name, output_op_def, status)
end
_FUNCDEF("TF_GraphGetOpDef", { "TF_Graph *", "const char *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- Returns the serialized VersionDef proto for this graph.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param output_version_def ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_GraphVersions(graph, output_version_def, status)
    return _CALL("TF_GraphVersions", graph, output_version_def, status)
end
_FUNCDEF("TF_GraphVersions", { "TF_Graph *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- TF_ImportGraphDefOptions holds options that can be passed to
--- TF_GraphImportGraphDef.
--- 

_TYPEDEF("TF_ImportGraphDefOptions", "struct TF_ImportGraphDefOptions")

--

---@return ffi.cdata @(TF_ImportGraphDefOptions *)
function M.TF_NewImportGraphDefOptions()
    return _CALL("TF_NewImportGraphDefOptions")
end
_FUNCDEF("TF_NewImportGraphDefOptions", {  }, "TF_ImportGraphDefOptions *")

--

---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
function M.TF_DeleteImportGraphDefOptions(opts)
    return _CALL("TF_DeleteImportGraphDefOptions", opts)
end
_FUNCDEF("TF_DeleteImportGraphDefOptions", { "TF_ImportGraphDefOptions *" }, "void")

--

--- Set the prefix to be prepended to the names of nodes in `graph_def` that will
--- be imported into `graph`. `prefix` is copied and has no lifetime
--- requirements.
--- 
---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
---@param prefix string @(const char *)
function M.TF_ImportGraphDefOptionsSetPrefix(opts, prefix)
    return _CALL("TF_ImportGraphDefOptionsSetPrefix", opts, prefix)
end
_FUNCDEF("TF_ImportGraphDefOptionsSetPrefix", { "TF_ImportGraphDefOptions *", "const char *" }, "void")

--

--- Set the execution device for nodes in `graph_def`.
--- Only applies to nodes where a device was not already explicitly specified.
--- `device` is copied and has no lifetime requirements.
--- 
---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
---@param device string @(const char *)
function M.TF_ImportGraphDefOptionsSetDefaultDevice(opts, device)
    return _CALL("TF_ImportGraphDefOptionsSetDefaultDevice", opts, device)
end
_FUNCDEF("TF_ImportGraphDefOptionsSetDefaultDevice", { "TF_ImportGraphDefOptions *", "const char *" }, "void")

--

--- Set whether to uniquify imported operation names. If true, imported operation
--- names will be modified if their name already exists in the graph. If false,
--- conflicting names will be treated as an error. Note that this option has no
--- effect if a prefix is set, since the prefix will guarantee all names are
--- unique. Defaults to false.
--- 
---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
---@param uniquify_names number @(unsigned char)
function M.TF_ImportGraphDefOptionsSetUniquifyNames(opts, uniquify_names)
    return _CALL("TF_ImportGraphDefOptionsSetUniquifyNames", opts, uniquify_names)
end
_FUNCDEF("TF_ImportGraphDefOptionsSetUniquifyNames", { "TF_ImportGraphDefOptions *", "unsigned char" }, "void")

--

--- If true, the specified prefix will be modified if it already exists as an
--- operation name or prefix in the graph. If false, a conflicting prefix will be
--- treated as an error. This option has no effect if no prefix is specified.
--- 
---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
---@param uniquify_prefix number @(unsigned char)
function M.TF_ImportGraphDefOptionsSetUniquifyPrefix(opts, uniquify_prefix)
    return _CALL("TF_ImportGraphDefOptionsSetUniquifyPrefix", opts, uniquify_prefix)
end
_FUNCDEF("TF_ImportGraphDefOptionsSetUniquifyPrefix", { "TF_ImportGraphDefOptions *", "unsigned char" }, "void")

--

--- Set any imported nodes with input `src_name:src_index` to have that input
--- replaced with `dst`. `src_name` refers to a node in the graph to be imported,
--- `dst` references a node already existing in the graph being imported into.
--- `src_name` is copied and has no lifetime requirements.
--- 
---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
---@param src_name string @(const char *)
---@param src_index number @(int)
---@param dst TF_Output @(TF_Output)
function M.TF_ImportGraphDefOptionsAddInputMapping(opts, src_name, src_index, dst)
    return _CALL("TF_ImportGraphDefOptionsAddInputMapping", opts, src_name, src_index, dst)
end
_FUNCDEF("TF_ImportGraphDefOptionsAddInputMapping", { "TF_ImportGraphDefOptions *", "const char *", "int", "TF_Output" }, "void")

--

--- Set any imported nodes with control input `src_name` to have that input
--- replaced with `dst`. `src_name` refers to a node in the graph to be imported,
--- `dst` references an operation already existing in the graph being imported
--- into. `src_name` is copied and has no lifetime requirements.
--- 
---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
---@param src_name string @(const char *)
---@param dst ffi.cdata @(TF_Operation *)
function M.TF_ImportGraphDefOptionsRemapControlDependency(opts, src_name, dst)
    return _CALL("TF_ImportGraphDefOptionsRemapControlDependency", opts, src_name, dst)
end
_FUNCDEF("TF_ImportGraphDefOptionsRemapControlDependency", { "TF_ImportGraphDefOptions *", "const char *", "TF_Operation *" }, "void")

--

--- Cause the imported graph to have a control dependency on `oper`. `oper`
--- should exist in the graph being imported into.
--- 
---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
---@param oper ffi.cdata @(TF_Operation *)
function M.TF_ImportGraphDefOptionsAddControlDependency(opts, oper)
    return _CALL("TF_ImportGraphDefOptionsAddControlDependency", opts, oper)
end
_FUNCDEF("TF_ImportGraphDefOptionsAddControlDependency", { "TF_ImportGraphDefOptions *", "TF_Operation *" }, "void")

--

--- Add an output in `graph_def` to be returned via the `return_outputs` output
--- parameter of TF_GraphImportGraphDef(). If the output is remapped via an input
--- mapping, the corresponding existing tensor in `graph` will be returned.
--- `oper_name` is copied and has no lifetime requirements.
--- 
---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
---@param oper_name string @(const char *)
---@param index number @(int)
function M.TF_ImportGraphDefOptionsAddReturnOutput(opts, oper_name, index)
    return _CALL("TF_ImportGraphDefOptionsAddReturnOutput", opts, oper_name, index)
end
_FUNCDEF("TF_ImportGraphDefOptionsAddReturnOutput", { "TF_ImportGraphDefOptions *", "const char *", "int" }, "void")

--

--- Returns the number of return outputs added via
--- TF_ImportGraphDefOptionsAddReturnOutput().
--- 
---@param opts ffi.cdata @(const TF_ImportGraphDefOptions *)
---@return number @(int)
function M.TF_ImportGraphDefOptionsNumReturnOutputs(opts)
    return _CALL("TF_ImportGraphDefOptionsNumReturnOutputs", opts)
end
_FUNCDEF("TF_ImportGraphDefOptionsNumReturnOutputs", { "const TF_ImportGraphDefOptions *" }, "int")

--

--- Add an operation in `graph_def` to be returned via the `return_opers` output
--- parameter of TF_GraphImportGraphDef(). `oper_name` is copied and has no
--- lifetime requirements.
--- 
---@param opts ffi.cdata @(TF_ImportGraphDefOptions *)
---@param oper_name string @(const char *)
function M.TF_ImportGraphDefOptionsAddReturnOperation(opts, oper_name)
    return _CALL("TF_ImportGraphDefOptionsAddReturnOperation", opts, oper_name)
end
_FUNCDEF("TF_ImportGraphDefOptionsAddReturnOperation", { "TF_ImportGraphDefOptions *", "const char *" }, "void")

--

--- Returns the number of return operations added via
--- TF_ImportGraphDefOptionsAddReturnOperation().
--- 
---@param opts ffi.cdata @(const TF_ImportGraphDefOptions *)
---@return number @(int)
function M.TF_ImportGraphDefOptionsNumReturnOperations(opts)
    return _CALL("TF_ImportGraphDefOptionsNumReturnOperations", opts)
end
_FUNCDEF("TF_ImportGraphDefOptionsNumReturnOperations", { "const TF_ImportGraphDefOptions *" }, "int")

--

--- TF_ImportGraphDefResults holds results that are generated by
--- TF_GraphImportGraphDefWithResults().
--- 

_TYPEDEF("TF_ImportGraphDefResults", "struct TF_ImportGraphDefResults")

--

--- Fetches the return outputs requested via
--- TF_ImportGraphDefOptionsAddReturnOutput(). The number of fetched outputs is
--- returned in `num_outputs`. The array of return outputs is returned in
--- `outputs`. `*outputs` is owned by and has the lifetime of `results`.
--- 
---@param results ffi.cdata @(TF_ImportGraphDefResults *)
---@param num_outputs ffi.cdata @(int *)
---@param outputs ffi.cdata @(TF_Output * *)
function M.TF_ImportGraphDefResultsReturnOutputs(results, num_outputs, outputs)
    return _CALL("TF_ImportGraphDefResultsReturnOutputs", results, num_outputs, outputs)
end
_FUNCDEF("TF_ImportGraphDefResultsReturnOutputs", { "TF_ImportGraphDefResults *", "int *", "TF_Output * *" }, "void")

--

--- Fetches the return operations requested via
--- TF_ImportGraphDefOptionsAddReturnOperation(). The number of fetched
--- operations is returned in `num_opers`. The array of return operations is
--- returned in `opers`. `*opers` is owned by and has the lifetime of `results`.
--- 
---@param results ffi.cdata @(TF_ImportGraphDefResults *)
---@param num_opers ffi.cdata @(int *)
---@param opers ffi.cdata @(TF_Operation * * *)
function M.TF_ImportGraphDefResultsReturnOperations(results, num_opers, opers)
    return _CALL("TF_ImportGraphDefResultsReturnOperations", results, num_opers, opers)
end
_FUNCDEF("TF_ImportGraphDefResultsReturnOperations", { "TF_ImportGraphDefResults *", "int *", "TF_Operation * * *" }, "void")

--

--- Fetches any input mappings requested via
--- TF_ImportGraphDefOptionsAddInputMapping() that didn't appear in the GraphDef
--- and weren't used as input to any node in the imported graph def. The number
--- of fetched mappings is returned in `num_missing_unused_input_mappings`. The
--- array of each mapping's source node name is returned in `src_names`, and the
--- array of each mapping's source index is returned in `src_indexes`.
--- `*src_names`, `*src_indexes`, and the memory backing each string in
--- `src_names` are owned by and have the lifetime of `results`.
--- 
---@param results ffi.cdata @(TF_ImportGraphDefResults *)
---@param num_missing_unused_input_mappings ffi.cdata @(int *)
---@param src_names ffi.cdata @(const char * * *)
---@param src_indexes ffi.cdata @(int * *)
function M.TF_ImportGraphDefResultsMissingUnusedInputMappings(results, num_missing_unused_input_mappings, src_names, src_indexes)
    return _CALL("TF_ImportGraphDefResultsMissingUnusedInputMappings", results, num_missing_unused_input_mappings, src_names, src_indexes)
end
_FUNCDEF("TF_ImportGraphDefResultsMissingUnusedInputMappings", { "TF_ImportGraphDefResults *", "int *", "const char * * *", "int * *" }, "void")

--

--- Deletes a results object returned by TF_GraphImportGraphDefWithResults().
--- 
---@param results ffi.cdata @(TF_ImportGraphDefResults *)
function M.TF_DeleteImportGraphDefResults(results)
    return _CALL("TF_DeleteImportGraphDefResults", results)
end
_FUNCDEF("TF_DeleteImportGraphDefResults", { "TF_ImportGraphDefResults *" }, "void")

--

--- Import the graph serialized in `graph_def` into `graph`.  Returns nullptr and
--- a bad status on error. Otherwise, returns a populated
--- TF_ImportGraphDefResults instance. The returned instance must be deleted via
--- TF_DeleteImportGraphDefResults().
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param graph_def ffi.cdata @(const TF_Buffer *)
---@param options ffi.cdata @(const TF_ImportGraphDefOptions *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_ImportGraphDefResults *)
function M.TF_GraphImportGraphDefWithResults(graph, graph_def, options, status)
    return _CALL("TF_GraphImportGraphDefWithResults", graph, graph_def, options, status)
end
_FUNCDEF("TF_GraphImportGraphDefWithResults", { "TF_Graph *", "const TF_Buffer *", "const TF_ImportGraphDefOptions *", "TF_Status *" }, "TF_ImportGraphDefResults *")

--

--- Import the graph serialized in `graph_def` into `graph`.
--- Convenience function for when only return outputs are needed.
--- `num_return_outputs` must be the number of return outputs added (i.e. the
--- result of TF_ImportGraphDefOptionsNumReturnOutputs()).  If
--- `num_return_outputs` is non-zero, `return_outputs` must be of length
--- `num_return_outputs`. Otherwise it can be null.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param graph_def ffi.cdata @(const TF_Buffer *)
---@param options ffi.cdata @(const TF_ImportGraphDefOptions *)
---@param return_outputs ffi.cdata @(TF_Output *)
---@param num_return_outputs number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_GraphImportGraphDefWithReturnOutputs(graph, graph_def, options, return_outputs, num_return_outputs, status)
    return _CALL("TF_GraphImportGraphDefWithReturnOutputs", graph, graph_def, options, return_outputs, num_return_outputs, status)
end
_FUNCDEF("TF_GraphImportGraphDefWithReturnOutputs", { "TF_Graph *", "const TF_Buffer *", "const TF_ImportGraphDefOptions *", "TF_Output *", "int", "TF_Status *" }, "void")

--

--- Import the graph serialized in `graph_def` into `graph`.
--- Convenience function for when no results are needed.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param graph_def ffi.cdata @(const TF_Buffer *)
---@param options ffi.cdata @(const TF_ImportGraphDefOptions *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_GraphImportGraphDef(graph, graph_def, options, status)
    return _CALL("TF_GraphImportGraphDef", graph, graph_def, options, status)
end
_FUNCDEF("TF_GraphImportGraphDef", { "TF_Graph *", "const TF_Buffer *", "const TF_ImportGraphDefOptions *", "TF_Status *" }, "void")

--

--- Adds a copy of function `func` and optionally its gradient function `grad`
--- to `g`. Once `func`/`grad` is added to `g`, it can be called by creating
--- an operation using the function's name.
--- Any changes to `func`/`grad` (including deleting it) done after this method
--- returns, won't affect the copy of `func`/`grad` in `g`.
--- If `func` or `grad` are already in `g`, TF_GraphCopyFunction has no
--- effect on them, but can establish the function->gradient relationship
--- between them if `func` does not already have a gradient. If `func` already
--- has a gradient different from `grad`, an error is returned.
--- `func` must not be null.
--- If `grad` is null and `func` is not in `g`, `func` is added without a
--- gradient.
--- If `grad` is null and `func` is in `g`, TF_GraphCopyFunction is a noop.
--- `grad` must have appropriate signature as described in the doc of
--- GradientDef in tensorflow/core/framework/function.proto.
--- If successful, status is set to OK and `func` and `grad` are added to `g`.
--- Otherwise, status is set to the encountered error and `g` is unmodified.
--- 
---@param g ffi.cdata @(TF_Graph *)
---@param func ffi.cdata @(const TF_Function *)
---@param grad ffi.cdata @(const TF_Function *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_GraphCopyFunction(g, func, grad, status)
    return _CALL("TF_GraphCopyFunction", g, func, grad, status)
end
_FUNCDEF("TF_GraphCopyFunction", { "TF_Graph *", "const TF_Function *", "const TF_Function *", "TF_Status *" }, "void")

--

--- Returns the number of TF_Functions registered in `g`.
--- 
---@param g ffi.cdata @(TF_Graph *)
---@return number @(int)
function M.TF_GraphNumFunctions(g)
    return _CALL("TF_GraphNumFunctions", g)
end
_FUNCDEF("TF_GraphNumFunctions", { "TF_Graph *" }, "int")

--

--- Fills in `funcs` with the TF_Function* registered in `g`.
--- `funcs` must point to an array of TF_Function* of length at least
--- `max_func`. In usual usage, max_func should be set to the result of
--- TF_GraphNumFunctions(g). In this case, all the functions registered in
--- `g` will be returned. Else, an unspecified subset.
--- If successful, returns the number of TF_Function* successfully set in
--- `funcs` and sets status to OK. The caller takes ownership of
--- all the returned TF_Functions. They must be deleted with TF_DeleteFunction.
--- On error, returns 0, sets status to the encountered error, and the contents
--- of funcs will be undefined.
--- 
---@param g ffi.cdata @(TF_Graph *)
---@param funcs ffi.cdata @(TF_Function * *)
---@param max_func number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int)
function M.TF_GraphGetFunctions(g, funcs, max_func, status)
    return _CALL("TF_GraphGetFunctions", g, funcs, max_func, status)
end
_FUNCDEF("TF_GraphGetFunctions", { "TF_Graph *", "TF_Function * *", "int", "TF_Status *" }, "int")

--

--- Note: The following function may fail on very large protos in the future.
--- 
---@param oper ffi.cdata @(TF_Operation *)
---@param output_node_def ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_OperationToNodeDef(oper, output_node_def, status)
    return _CALL("TF_OperationToNodeDef", oper, output_node_def, status)
end
_FUNCDEF("TF_OperationToNodeDef", { "TF_Operation *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- The number of inputs to the while loop, i.e. the number of loop variables.
--- This is the size of cond_inputs, body_inputs, and body_outputs.
--- The while condition graph. The inputs are the current values of the loop
--- variables. The output should be a scalar boolean.
--- The loop body graph. The inputs are the current values of the loop
--- variables. The outputs are the updated values of the loop variables.
--- Unique null-terminated name for this while loop. This is used as a prefix
--- for created operations.
--- 

_TYPEDEF("TF_WhileParams", "struct TF_WhileParams { const int ninputs ; TF_Graph * const cond_graph ; const TF_Output * const cond_inputs ; TF_Output cond_output ; TF_Graph * const body_graph ; const TF_Output * const body_inputs ; TF_Output * const body_outputs ; const char * name ; }")

--

--- Creates a TF_WhileParams for creating a while loop in `g`. `inputs` are
--- outputs that already exist in `g` used as initial values for the loop
--- variables.
--- The returned TF_WhileParams will have all fields initialized except
--- `cond_output`, `body_outputs`, and `name`. The `body_outputs` buffer will be
--- allocated to size `ninputs`. The caller should build `cond_graph` and
--- `body_graph` starting from the inputs, and store the final outputs in
--- `cond_output` and `body_outputs`.
--- If `status` is OK, the caller must call either TF_FinishWhile or
--- TF_AbortWhile on the returned TF_WhileParams. If `status` isn't OK, the
--- returned TF_WhileParams is not valid, and the caller should not call
--- TF_FinishWhile() or TF_AbortWhile().
--- Missing functionality (TODO):
--- - Gradients
--- - Reference-type inputs
--- - Directly referencing external tensors from the cond/body graphs (this is
--- possible in the Python API)
--- 
---@param g ffi.cdata @(TF_Graph *)
---@param inputs ffi.cdata @(TF_Output *)
---@param ninputs number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return TF_WhileParams @(TF_WhileParams)
function M.TF_NewWhile(g, inputs, ninputs, status)
    return _CALL("TF_NewWhile", g, inputs, ninputs, status)
end
_FUNCDEF("TF_NewWhile", { "TF_Graph *", "TF_Output *", "int", "TF_Status *" }, "TF_WhileParams")

--

--- Builds the while loop specified by `params` and returns the output tensors of
--- the while loop in `outputs`. `outputs` should be allocated to size
--- `params.ninputs`.
--- `params` is no longer valid once this returns.
--- Either this or TF_AbortWhile() must be called after a successful
--- TF_NewWhile() call.
--- 
---@param params ffi.cdata @(const TF_WhileParams *)
---@param status ffi.cdata @(TF_Status *)
---@param outputs ffi.cdata @(TF_Output *)
function M.TF_FinishWhile(params, status, outputs)
    return _CALL("TF_FinishWhile", params, status, outputs)
end
_FUNCDEF("TF_FinishWhile", { "const TF_WhileParams *", "TF_Status *", "TF_Output *" }, "void")

--

--- Frees `params`s resources without building a while loop. `params` is no
--- longer valid after this returns. Either this or TF_FinishWhile() must be
--- called after a successful TF_NewWhile() call.
--- 
---@param params ffi.cdata @(const TF_WhileParams *)
function M.TF_AbortWhile(params)
    return _CALL("TF_AbortWhile", params)
end
_FUNCDEF("TF_AbortWhile", { "const TF_WhileParams *" }, "void")

--

--- Adds operations to compute the partial derivatives of sum of `y`s w.r.t `x`s,
--- i.e., d(y_1 + y_2 + ...)/dx_1, d(y_1 + y_2 + ...)/dx_2...
--- `dx` are used as initial gradients (which represent the symbolic partial
--- derivatives of some loss function `L` w.r.t. `y`).
--- `dx` must be nullptr or have size `ny`.
--- If `dx` is nullptr, the implementation will use dx of `OnesLike` for all
--- shapes in `y`.
--- The partial derivatives are returned in `dy`. `dy` should be allocated to
--- size `nx`.
--- Gradient nodes are automatically named under the "gradients/" prefix. To
--- guarantee name uniqueness, subsequent calls to the same graph will
--- append an incremental tag to the prefix: "gradients_1/", "gradients_2/", ...
--- See TF_AddGradientsWithPrefix, which provides a means to specify a custom
--- name prefix for operations added to a graph to compute the gradients.
--- WARNING: This function does not yet support all the gradients that python
--- supports. See
--- https://www.tensorflow.org/code/tensorflow/cc/gradients/README.md
--- for instructions on how to add C++ more gradients.
--- 
---@param g ffi.cdata @(TF_Graph *)
---@param y ffi.cdata @(TF_Output *)
---@param ny number @(int)
---@param x ffi.cdata @(TF_Output *)
---@param nx number @(int)
---@param dx ffi.cdata @(TF_Output *)
---@param status ffi.cdata @(TF_Status *)
---@param dy ffi.cdata @(TF_Output *)
function M.TF_AddGradients(g, y, ny, x, nx, dx, status, dy)
    return _CALL("TF_AddGradients", g, y, ny, x, nx, dx, status, dy)
end
_FUNCDEF("TF_AddGradients", { "TF_Graph *", "TF_Output *", "int", "TF_Output *", "int", "TF_Output *", "TF_Status *", "TF_Output *" }, "void")

--

--- Adds operations to compute the partial derivatives of sum of `y`s w.r.t `x`s,
--- i.e., d(y_1 + y_2 + ...)/dx_1, d(y_1 + y_2 + ...)/dx_2...
--- This is a variant of TF_AddGradients that allows to caller to pass a custom
--- name prefix to the operations added to a graph to compute the gradients.
--- `dx` are used as initial gradients (which represent the symbolic partial
--- derivatives of some loss function `L` w.r.t. `y`).
--- `dx` must be nullptr or have size `ny`.
--- If `dx` is nullptr, the implementation will use dx of `OnesLike` for all
--- shapes in `y`.
--- The partial derivatives are returned in `dy`. `dy` should be allocated to
--- size `nx`.
--- `prefix` names the scope into which all gradients operations are being added.
--- `prefix` must be unique within the provided graph otherwise this operation
--- will fail. If `prefix` is nullptr, the default prefixing behaviour takes
--- place, see TF_AddGradients for more details.
--- WARNING: This function does not yet support all the gradients that python
--- supports. See
--- https://www.tensorflow.org/code/tensorflow/cc/gradients/README.md
--- for instructions on how to add C++ more gradients.
--- 
---@param g ffi.cdata @(TF_Graph *)
---@param prefix string @(const char *)
---@param y ffi.cdata @(TF_Output *)
---@param ny number @(int)
---@param x ffi.cdata @(TF_Output *)
---@param nx number @(int)
---@param dx ffi.cdata @(TF_Output *)
---@param status ffi.cdata @(TF_Status *)
---@param dy ffi.cdata @(TF_Output *)
function M.TF_AddGradientsWithPrefix(g, prefix, y, ny, x, nx, dx, status, dy)
    return _CALL("TF_AddGradientsWithPrefix", g, prefix, y, ny, x, nx, dx, status, dy)
end
_FUNCDEF("TF_AddGradientsWithPrefix", { "TF_Graph *", "const char *", "TF_Output *", "int", "TF_Output *", "int", "TF_Output *", "TF_Status *", "TF_Output *" }, "void")

--

--- Create a TF_Function from a TF_Graph
--- Params:
--- fn_body - the graph whose operations (or subset of whose operations) will be
--- converted to TF_Function.
--- fn_name - the name of the new TF_Function. Should match the operation
--- name (OpDef.name) regexp [A-Z][A-Za-z0-9_.\\-/]*.
--- If `append_hash_to_fn_name` is false, `fn_name` must be distinct
--- from other function and operation names (at least those
--- registered in graphs where this function will be used).
--- append_hash_to_fn_name - Must be 0 or 1. If set to 1, the actual name
--- of the function will be `fn_name` appended with
--- '_<hash_of_this_function's_definition>'.
--- If set to 0, the function's name will be `fn_name`.
--- num_opers - `num_opers` contains the number of elements in the `opers` array
--- or a special value of -1 meaning that no array is given.
--- The distinction between an empty array of operations and no
--- array of operations is necessary to distinguish the case of
--- creating a function with no body (e.g. identity or permutation)
--- and the case of creating a function whose body contains all
--- the nodes in the graph (except for the automatic skipping, see
--- below).
--- opers - Array of operations to become the body of the function or null.
--- - If no array is given (`num_opers`  = -1), all the
--- operations in `fn_body` will become part of the function
--- except operations referenced in `inputs`. These operations
--- must have a single output (these operations are typically
--- placeholders created for the sole purpose of representing
--- an input. We can relax this constraint if there are
--- compelling use cases).
--- - If an array is given (`num_opers` >= 0), all operations
--- in it will become part of the function. In particular, no
--- automatic skipping of dummy input operations is performed.
--- ninputs - number of elements in `inputs` array
--- inputs - array of TF_Outputs that specify the inputs to the function.
--- If `ninputs` is zero (the function takes no inputs), `inputs`
--- can be null. The names used for function inputs are normalized
--- names of the operations (usually placeholders) pointed to by
--- `inputs`. These operation names should start with a letter.
--- Normalization will convert all letters to lowercase and
--- non-alphanumeric characters to '_' to make resulting names match
--- the "[a-z][a-z0-9_]*" pattern for operation argument names.
--- `inputs` cannot contain the same tensor twice.
--- noutputs - number of elements in `outputs` array
--- outputs - array of TF_Outputs that specify the outputs of the function.
--- If `noutputs` is zero (the function returns no outputs), `outputs`
--- can be null. `outputs` can contain the same tensor more than once.
--- output_names - The names of the function's outputs. `output_names` array
--- must either have the same length as `outputs`
--- (i.e. `noutputs`) or be null. In the former case,
--- the names should match the regular expression for ArgDef
--- names - "[a-z][a-z0-9_]*". In the latter case,
--- names for outputs will be generated automatically.
--- opts - various options for the function, e.g. XLA's inlining control.
--- description - optional human-readable description of this function.
--- status - Set to OK on success and an appropriate error on failure.
--- Note that when the same TF_Output is listed as both an input and an output,
--- the corresponding function's output will equal to this input,
--- instead of the original node's output.
--- Callers must also satisfy the following constraints:
--- - `inputs` cannot refer to TF_Outputs within a control flow context. For
--- example, one cannot use the output of "switch" node as input.
--- - `inputs` and `outputs` cannot have reference types. Reference types are
--- not exposed through C API and are being replaced with Resources. We support
--- reference types inside function's body to support legacy code. Do not
--- use them in new code.
--- - Every node in the function's body must have all of its inputs (including
--- control inputs). In other words, for every node in the body, each input
--- must be either listed in `inputs` or must come from another node in
--- the body. In particular, it is an error to have a control edge going from
--- a node outside of the body into a node in the body. This applies to control
--- edges going from nodes referenced in `inputs` to nodes in the body when
--- the former nodes are not in the body (automatically skipped or not
--- included in explicitly specified body).
--- Returns:
--- On success, a newly created TF_Function instance. It must be deleted by
--- calling TF_DeleteFunction.
--- On failure, null.
--- 
---@param fn_body ffi.cdata @(const TF_Graph *)
---@param fn_name string @(const char *)
---@param append_hash_to_fn_name number @(unsigned char)
---@param num_opers number @(int)
---@param opers ffi.cdata @(const TF_Operation * const *)
---@param ninputs number @(int)
---@param inputs ffi.cdata @(const TF_Output *)
---@param noutputs number @(int)
---@param outputs ffi.cdata @(const TF_Output *)
---@param output_names ffi.cdata @(const char * const *)
---@param opts ffi.cdata @(const TF_FunctionOptions *)
---@param description string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Function *)
function M.TF_GraphToFunction(fn_body, fn_name, append_hash_to_fn_name, num_opers, opers, ninputs, inputs, noutputs, outputs, output_names, opts, description, status)
    return _CALL("TF_GraphToFunction", fn_body, fn_name, append_hash_to_fn_name, num_opers, opers, ninputs, inputs, noutputs, outputs, output_names, opts, description, status)
end
_FUNCDEF("TF_GraphToFunction", { "const TF_Graph *", "const char *", "unsigned char", "int", "const TF_Operation * const *", "int", "const TF_Output *", "int", "const TF_Output *", "const char * const *", "const TF_FunctionOptions *", "const char *", "TF_Status *" }, "TF_Function *")

--

--- Similar to TF_GraphToFunction but allows specifying control outputs of the
--- function.
--- The arguments of TF_GraphToFunction have the same meaning, but the new
--- arguments are as follows:
--- ncontrol_outputs: Number of control outputs of the function.
--- control_outputs: vector of TF_Operation objects to be marked as control
--- outputs of the function. Operations marked as control outputs are
--- guaranteed to execute.
--- control_output_names: Optional. If not nullptr, vector of strings, one
--- per control output, with their names to be added to the function's
--- OpDef.
--- 
---@param fn_body ffi.cdata @(const TF_Graph *)
---@param fn_name string @(const char *)
---@param append_hash_to_fn_name number @(unsigned char)
---@param num_opers number @(int)
---@param opers ffi.cdata @(const TF_Operation * const *)
---@param ninputs number @(int)
---@param inputs ffi.cdata @(const TF_Output *)
---@param noutputs number @(int)
---@param outputs ffi.cdata @(const TF_Output *)
---@param output_names ffi.cdata @(const char * const *)
---@param ncontrol_outputs number @(int)
---@param control_outputs ffi.cdata @(const TF_Operation * const *)
---@param control_output_names ffi.cdata @(const char * const *)
---@param opts ffi.cdata @(const TF_FunctionOptions *)
---@param description string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Function *)
function M.TF_GraphToFunctionWithControlOutputs(fn_body, fn_name, append_hash_to_fn_name, num_opers, opers, ninputs, inputs, noutputs, outputs, output_names, ncontrol_outputs, control_outputs, control_output_names, opts, description, status)
    return _CALL("TF_GraphToFunctionWithControlOutputs", fn_body, fn_name, append_hash_to_fn_name, num_opers, opers, ninputs, inputs, noutputs, outputs, output_names, ncontrol_outputs, control_outputs, control_output_names, opts, description, status)
end
_FUNCDEF("TF_GraphToFunctionWithControlOutputs", { "const TF_Graph *", "const char *", "unsigned char", "int", "const TF_Operation * const *", "int", "const TF_Output *", "int", "const TF_Output *", "const char * const *", "int", "const TF_Operation * const *", "const char * const *", "const TF_FunctionOptions *", "const char *", "TF_Status *" }, "TF_Function *")

--

--- Returns the name of the graph function.
--- The return value points to memory that is only usable until the next
--- mutation to *func.
--- 
---@param func ffi.cdata @(TF_Function *)
---@return string @(const char *)
function M.TF_FunctionName(func)
    return _CALL("TF_FunctionName", func)
end
_FUNCDEF("TF_FunctionName", { "TF_Function *" }, "const char *")

--

--- Write out a serialized representation of `func` (as a FunctionDef protocol
--- message) to `output_func_def` (allocated by TF_NewBuffer()).
--- `output_func_def`'s underlying buffer will be freed when TF_DeleteBuffer()
--- is called.
--- May fail on very large graphs in the future.
--- 
---@param func ffi.cdata @(TF_Function *)
---@param output_func_def ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_FunctionToFunctionDef(func, output_func_def, status)
    return _CALL("TF_FunctionToFunctionDef", func, output_func_def, status)
end
_FUNCDEF("TF_FunctionToFunctionDef", { "TF_Function *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- Construct and return the function whose FunctionDef representation is
--- serialized in `proto`. `proto_len` must equal the number of bytes
--- pointed to by `proto`.
--- Returns:
--- On success, a newly created TF_Function instance. It must be deleted by
--- calling TF_DeleteFunction.
--- On failure, null.
--- 
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Function *)
function M.TF_FunctionImportFunctionDef(proto, proto_len, status)
    return _CALL("TF_FunctionImportFunctionDef", proto, proto_len, status)
end
_FUNCDEF("TF_FunctionImportFunctionDef", { "const void *", "size_t", "TF_Status *" }, "TF_Function *")

--

--- Sets function attribute named `attr_name` to value stored in `proto`.
--- If this attribute is already set to another value, it is overridden.
--- `proto` should point to a sequence of bytes of length `proto_len`
--- representing a binary serialization of an AttrValue protocol
--- buffer.
--- 
---@param func ffi.cdata @(TF_Function *)
---@param attr_name string @(const char *)
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TF_FunctionSetAttrValueProto(func, attr_name, proto, proto_len, status)
    return _CALL("TF_FunctionSetAttrValueProto", func, attr_name, proto, proto_len, status)
end
_FUNCDEF("TF_FunctionSetAttrValueProto", { "TF_Function *", "const char *", "const void *", "size_t", "TF_Status *" }, "void")

--

--- Sets `output_attr_value` to the binary-serialized AttrValue proto
--- representation of the value of the `attr_name` attr of `func`.
--- If `attr_name` attribute is not present, status is set to an error.
--- 
---@param func ffi.cdata @(TF_Function *)
---@param attr_name string @(const char *)
---@param output_attr_value ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_FunctionGetAttrValueProto(func, attr_name, output_attr_value, status)
    return _CALL("TF_FunctionGetAttrValueProto", func, attr_name, output_attr_value, status)
end
_FUNCDEF("TF_FunctionGetAttrValueProto", { "TF_Function *", "const char *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- Frees the memory used by the `func` struct.
--- TF_DeleteFunction is a noop if `func` is null.
--- Deleting a function does not remove it from any graphs it was copied to.
--- 
---@param func ffi.cdata @(TF_Function *)
function M.TF_DeleteFunction(func)
    return _CALL("TF_DeleteFunction", func)
end
_FUNCDEF("TF_DeleteFunction", { "TF_Function *" }, "void")

--

--- Attempts to evaluate `output`. This will only be possible if `output` doesn't
--- depend on any graph inputs (this function is safe to call if this isn't the
--- case though).
--- If the evaluation is successful, this function returns true and `output`s
--- value is returned in `result`. Otherwise returns false. An error status is
--- returned if something is wrong with the graph or input. Note that this may
--- return false even if no error status is set.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param output TF_Output @(TF_Output)
---@param result ffi.cdata @(TF_Tensor * *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(unsigned char)
function M.TF_TryEvaluateConstant(graph, output, result, status)
    return _CALL("TF_TryEvaluateConstant", graph, output, result, status)
end
_FUNCDEF("TF_TryEvaluateConstant", { "TF_Graph *", "TF_Output", "TF_Tensor * *", "TF_Status *" }, "unsigned char")

--

--- TODO(josh11b): Register OpDef, available to all operations added
--- to this graph.
--- --------------------------------------------------------------------------
--- API for driving Graph execution.
--- 

_TYPEDEF("TF_Session", "struct TF_Session")

--

--- Return a new execution session with the associated graph, or NULL on
--- error. Does not take ownership of any input parameters.
--- `graph` must be a valid graph (not deleted or nullptr). `graph` will be be
--- kept alive for the lifetime of the returned TF_Session. New nodes can still
--- be added to `graph` after this call.
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param opts ffi.cdata @(const TF_SessionOptions *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Session *)
function M.TF_NewSession(graph, opts, status)
    return _CALL("TF_NewSession", graph, opts, status)
end
_FUNCDEF("TF_NewSession", { "TF_Graph *", "const TF_SessionOptions *", "TF_Status *" }, "TF_Session *")

--

--- This function creates a new TF_Session (which is created on success) using
--- `session_options`, and then initializes state (restoring tensors and other
--- assets) using `run_options`.
--- Any NULL and non-NULL value combinations for (`run_options, `meta_graph_def`)
--- are valid.
--- - `export_dir` must be set to the path of the exported SavedModel.
--- - `tags` must include the set of tags used to identify one MetaGraphDef in
--- the SavedModel.
--- - `graph` must be a graph newly allocated with TF_NewGraph().
--- If successful, populates `graph` with the contents of the Graph and
--- `meta_graph_def` with the MetaGraphDef of the loaded model.
--- 
---@param session_options ffi.cdata @(const TF_SessionOptions *)
---@param run_options ffi.cdata @(const TF_Buffer *)
---@param export_dir string @(const char *)
---@param tags ffi.cdata @(const char * const *)
---@param tags_len number @(int)
---@param graph ffi.cdata @(TF_Graph *)
---@param meta_graph_def ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Session *)
function M.TF_LoadSessionFromSavedModel(session_options, run_options, export_dir, tags, tags_len, graph, meta_graph_def, status)
    return _CALL("TF_LoadSessionFromSavedModel", session_options, run_options, export_dir, tags, tags_len, graph, meta_graph_def, status)
end
_FUNCDEF("TF_LoadSessionFromSavedModel", { "const TF_SessionOptions *", "const TF_Buffer *", "const char *", "const char * const *", "int", "TF_Graph *", "TF_Buffer *", "TF_Status *" }, "TF_Session *")

--

--- Close a session.
--- Contacts any other processes associated with the session, if applicable.
--- May not be called after TF_DeleteSession().
--- 
---@param session ffi.cdata @(TF_Session *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_CloseSession(session, status)
    return _CALL("TF_CloseSession", session, status)
end
_FUNCDEF("TF_CloseSession", { "TF_Session *", "TF_Status *" }, "void")

--

--- Destroy a session object.
--- Even if error information is recorded in *status, this call discards all
--- local resources associated with the session.  The session may not be used
--- during or after this call (and the session drops its reference to the
--- corresponding graph).
--- 
---@param session ffi.cdata @(TF_Session *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_DeleteSession(session, status)
    return _CALL("TF_DeleteSession", session, status)
end
_FUNCDEF("TF_DeleteSession", { "TF_Session *", "TF_Status *" }, "void")

--

--- Run the graph associated with the session starting with the supplied inputs
--- (inputs[0,ninputs-1] with corresponding values in input_values[0,ninputs-1]).
--- Any NULL and non-NULL value combinations for (`run_options`,
--- `run_metadata`) are valid.
--- - `run_options` may be NULL, in which case it will be ignored; or
--- non-NULL, in which case it must point to a `TF_Buffer` containing the
--- serialized representation of a `RunOptions` protocol buffer.
--- - `run_metadata` may be NULL, in which case it will be ignored; or
--- non-NULL, in which case it must point to an empty, freshly allocated
--- `TF_Buffer` that may be updated to contain the serialized representation
--- of a `RunMetadata` protocol buffer.
--- The caller retains ownership of `input_values` (which can be deleted using
--- TF_DeleteTensor). The caller also retains ownership of `run_options` and/or
--- `run_metadata` (when not NULL) and should manually call TF_DeleteBuffer on
--- them.
--- On success, the tensors corresponding to outputs[0,noutputs-1] are placed in
--- output_values[]. Ownership of the elements of output_values[] is transferred
--- to the caller, which must eventually call TF_DeleteTensor on them.
--- On failure, output_values[] contains NULLs.
--- RunOptions
--- Input tensors
--- Output tensors
--- Target operations
--- RunMetadata
--- Output status
--- 
---@param session ffi.cdata @(TF_Session *)
---@param run_options ffi.cdata @(const TF_Buffer *)
---@param inputs ffi.cdata @(const TF_Output *)
---@param input_values ffi.cdata @(TF_Tensor * const *)
---@param ninputs number @(int)
---@param outputs ffi.cdata @(const TF_Output *)
---@param output_values ffi.cdata @(TF_Tensor * *)
---@param noutputs number @(int)
---@param target_opers ffi.cdata @(const TF_Operation * const *)
---@param ntargets number @(int)
---@param run_metadata ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_SessionRun(session, run_options, inputs, input_values, ninputs, outputs, output_values, noutputs, target_opers, ntargets, run_metadata, status)
    return _CALL("TF_SessionRun", session, run_options, inputs, input_values, ninputs, outputs, output_values, noutputs, target_opers, ntargets, run_metadata, status)
end
_FUNCDEF("TF_SessionRun", { "TF_Session *", "const TF_Buffer *", "const TF_Output *", "TF_Tensor * const *", "int", "const TF_Output *", "TF_Tensor * *", "int", "const TF_Operation * const *", "int", "TF_Buffer *", "TF_Status *" }, "void")

--

--- Set up the graph with the intended feeds (inputs) and fetches (outputs) for a
--- sequence of partial run calls.
--- On success, returns a handle that is used for subsequent PRun calls. The
--- handle should be deleted with TF_DeletePRunHandle when it is no longer
--- needed.
--- On failure, out_status contains a tensorflow::Status with an error
--- message. *handle is set to nullptr.
--- Input names
--- Output names
--- Target operations
--- Output handle
--- Output status
--- 
---@param session ffi.cdata @(TF_Session *)
---@param inputs ffi.cdata @(const TF_Output *)
---@param ninputs number @(int)
---@param outputs ffi.cdata @(const TF_Output *)
---@param noutputs number @(int)
---@param target_opers ffi.cdata @(const TF_Operation * const *)
---@param ntargets number @(int)
---@param handle ffi.cdata @(const char * *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_SessionPRunSetup(session, inputs, ninputs, outputs, noutputs, target_opers, ntargets, handle, status)
    return _CALL("TF_SessionPRunSetup", session, inputs, ninputs, outputs, noutputs, target_opers, ntargets, handle, status)
end
_FUNCDEF("TF_SessionPRunSetup", { "TF_Session *", "const TF_Output *", "int", "const TF_Output *", "int", "const TF_Operation * const *", "int", "const char * *", "TF_Status *" }, "void")

--

--- Continue to run the graph with additional feeds and fetches. The
--- execution state is uniquely identified by the handle.
--- Input tensors
--- Output tensors
--- Target operations
--- Output status
--- 
---@param session ffi.cdata @(TF_Session *)
---@param handle string @(const char *)
---@param inputs ffi.cdata @(const TF_Output *)
---@param input_values ffi.cdata @(TF_Tensor * const *)
---@param ninputs number @(int)
---@param outputs ffi.cdata @(const TF_Output *)
---@param output_values ffi.cdata @(TF_Tensor * *)
---@param noutputs number @(int)
---@param target_opers ffi.cdata @(const TF_Operation * const *)
---@param ntargets number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_SessionPRun(session, handle, inputs, input_values, ninputs, outputs, output_values, noutputs, target_opers, ntargets, status)
    return _CALL("TF_SessionPRun", session, handle, inputs, input_values, ninputs, outputs, output_values, noutputs, target_opers, ntargets, status)
end
_FUNCDEF("TF_SessionPRun", { "TF_Session *", "const char *", "const TF_Output *", "TF_Tensor * const *", "int", "const TF_Output *", "TF_Tensor * *", "int", "const TF_Operation * const *", "int", "TF_Status *" }, "void")

--

--- Deletes a handle allocated by TF_SessionPRunSetup.
--- Once called, no more calls to TF_SessionPRun should be made.
--- 
---@param handle string @(const char *)
function M.TF_DeletePRunHandle(handle)
    return _CALL("TF_DeletePRunHandle", handle)
end
_FUNCDEF("TF_DeletePRunHandle", { "const char *" }, "void")

--

--- --------------------------------------------------------------------------
--- The deprecated session API.  Please switch to the above instead of
--- TF_ExtendGraph(). This deprecated API can be removed at any time without
--- notice.
--- 

_TYPEDEF("TF_DeprecatedSession", "struct TF_DeprecatedSession")

--

---@param session ffi.cdata @(const TF_SessionOptions *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_DeprecatedSession *)
function M.TF_NewDeprecatedSession(session, status)
    return _CALL("TF_NewDeprecatedSession", session, status)
end
_FUNCDEF("TF_NewDeprecatedSession", { "const TF_SessionOptions *", "TF_Status *" }, "TF_DeprecatedSession *")

--

---@param session ffi.cdata @(TF_DeprecatedSession *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_CloseDeprecatedSession(session, status)
    return _CALL("TF_CloseDeprecatedSession", session, status)
end
_FUNCDEF("TF_CloseDeprecatedSession", { "TF_DeprecatedSession *", "TF_Status *" }, "void")

--

---@param session ffi.cdata @(TF_DeprecatedSession *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_DeleteDeprecatedSession(session, status)
    return _CALL("TF_DeleteDeprecatedSession", session, status)
end
_FUNCDEF("TF_DeleteDeprecatedSession", { "TF_DeprecatedSession *", "TF_Status *" }, "void")

--

---@param opt ffi.cdata @(const TF_SessionOptions *)
---@param containers ffi.cdata @(const char * *)
---@param ncontainers number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_Reset(opt, containers, ncontainers, status)
    return _CALL("TF_Reset", opt, containers, ncontainers, status)
end
_FUNCDEF("TF_Reset", { "const TF_SessionOptions *", "const char * *", "int", "TF_Status *" }, "void")

--

--- Treat the bytes proto[0,proto_len-1] as a serialized GraphDef and
--- add the nodes in that GraphDef to the graph for the session.
--- Prefer use of TF_Session and TF_GraphImportGraphDef over this.
--- 
---@param session ffi.cdata @(TF_DeprecatedSession *)
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TF_ExtendGraph(session, proto, proto_len, status)
    return _CALL("TF_ExtendGraph", session, proto, proto_len, status)
end
_FUNCDEF("TF_ExtendGraph", { "TF_DeprecatedSession *", "const void *", "size_t", "TF_Status *" }, "void")

--

--- See TF_SessionRun() above.
--- 
---@param session ffi.cdata @(TF_DeprecatedSession *)
---@param run_options ffi.cdata @(const TF_Buffer *)
---@param input_names ffi.cdata @(const char * *)
---@param inputs ffi.cdata @(TF_Tensor * *)
---@param ninputs number @(int)
---@param output_names ffi.cdata @(const char * *)
---@param outputs ffi.cdata @(TF_Tensor * *)
---@param noutputs number @(int)
---@param target_oper_names ffi.cdata @(const char * *)
---@param ntargets number @(int)
---@param run_metadata ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_Run(session, run_options, input_names, inputs, ninputs, output_names, outputs, noutputs, target_oper_names, ntargets, run_metadata, status)
    return _CALL("TF_Run", session, run_options, input_names, inputs, ninputs, output_names, outputs, noutputs, target_oper_names, ntargets, run_metadata, status)
end
_FUNCDEF("TF_Run", { "TF_DeprecatedSession *", "const TF_Buffer *", "const char * *", "TF_Tensor * *", "int", "const char * *", "TF_Tensor * *", "int", "const char * *", "int", "TF_Buffer *", "TF_Status *" }, "void")

--

--- See TF_SessionPRunSetup() above.
--- 
---@param session ffi.cdata @(TF_DeprecatedSession *)
---@param input_names ffi.cdata @(const char * *)
---@param ninputs number @(int)
---@param output_names ffi.cdata @(const char * *)
---@param noutputs number @(int)
---@param target_oper_names ffi.cdata @(const char * *)
---@param ntargets number @(int)
---@param handle ffi.cdata @(const char * *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_PRunSetup(session, input_names, ninputs, output_names, noutputs, target_oper_names, ntargets, handle, status)
    return _CALL("TF_PRunSetup", session, input_names, ninputs, output_names, noutputs, target_oper_names, ntargets, handle, status)
end
_FUNCDEF("TF_PRunSetup", { "TF_DeprecatedSession *", "const char * *", "int", "const char * *", "int", "const char * *", "int", "const char * *", "TF_Status *" }, "void")

--

--- See TF_SessionPRun above.
--- 
---@param session ffi.cdata @(TF_DeprecatedSession *)
---@param handle string @(const char *)
---@param input_names ffi.cdata @(const char * *)
---@param inputs ffi.cdata @(TF_Tensor * *)
---@param ninputs number @(int)
---@param output_names ffi.cdata @(const char * *)
---@param outputs ffi.cdata @(TF_Tensor * *)
---@param noutputs number @(int)
---@param target_oper_names ffi.cdata @(const char * *)
---@param ntargets number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_PRun(session, handle, input_names, inputs, ninputs, output_names, outputs, noutputs, target_oper_names, ntargets, status)
    return _CALL("TF_PRun", session, handle, input_names, inputs, ninputs, output_names, outputs, noutputs, target_oper_names, ntargets, status)
end
_FUNCDEF("TF_PRun", { "TF_DeprecatedSession *", "const char *", "const char * *", "TF_Tensor * *", "int", "const char * *", "TF_Tensor * *", "int", "const char * *", "int", "TF_Status *" }, "void")

--

_TYPEDEF("TF_DeviceList", "struct TF_DeviceList")

--

--- Lists all devices in a TF_Session.
--- Caller takes ownership of the returned TF_DeviceList* which must eventually
--- be freed with a call to TF_DeleteDeviceList.
--- 
---@param session ffi.cdata @(TF_Session *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_DeviceList *)
function M.TF_SessionListDevices(session, status)
    return _CALL("TF_SessionListDevices", session, status)
end
_FUNCDEF("TF_SessionListDevices", { "TF_Session *", "TF_Status *" }, "TF_DeviceList *")

--

--- Lists all devices in a TF_Session.
--- Caller takes ownership of the returned TF_DeviceList* which must eventually
--- be freed with a call to TF_DeleteDeviceList.
--- 
---@param session ffi.cdata @(TF_DeprecatedSession *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_DeviceList *)
function M.TF_DeprecatedSessionListDevices(session, status)
    return _CALL("TF_DeprecatedSessionListDevices", session, status)
end
_FUNCDEF("TF_DeprecatedSessionListDevices", { "TF_DeprecatedSession *", "TF_Status *" }, "TF_DeviceList *")

--

--- Deallocates the device list.
--- 
---@param list ffi.cdata @(TF_DeviceList *)
function M.TF_DeleteDeviceList(list)
    return _CALL("TF_DeleteDeviceList", list)
end
_FUNCDEF("TF_DeleteDeviceList", { "TF_DeviceList *" }, "void")

--

--- Counts the number of elements in the device list.
--- 
---@param list ffi.cdata @(const TF_DeviceList *)
---@return number @(int)
function M.TF_DeviceListCount(list)
    return _CALL("TF_DeviceListCount", list)
end
_FUNCDEF("TF_DeviceListCount", { "const TF_DeviceList *" }, "int")

--

--- Retrieves the full name of the device (e.g. /job:worker/replica:0/...)
--- The return value will be a pointer to a null terminated string. The caller
--- must not modify or delete the string. It will be deallocated upon a call to
--- TF_DeleteDeviceList.
--- If index is out of bounds, an error code will be set in the status object,
--- and a null pointer will be returned.
--- 
---@param list ffi.cdata @(const TF_DeviceList *)
---@param index number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return string @(const char *)
function M.TF_DeviceListName(list, index, status)
    return _CALL("TF_DeviceListName", list, index, status)
end
_FUNCDEF("TF_DeviceListName", { "const TF_DeviceList *", "int", "TF_Status *" }, "const char *")

--

--- Retrieves the type of the device at the given index.
--- The caller must not modify or delete the string. It will be deallocated upon
--- a call to TF_DeleteDeviceList.
--- If index is out of bounds, an error code will be set in the status object,
--- and a null pointer will be returned.
--- 
---@param list ffi.cdata @(const TF_DeviceList *)
---@param index number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return string @(const char *)
function M.TF_DeviceListType(list, index, status)
    return _CALL("TF_DeviceListType", list, index, status)
end
_FUNCDEF("TF_DeviceListType", { "const TF_DeviceList *", "int", "TF_Status *" }, "const char *")

--

--- Retrieve the amount of memory associated with a given device.
--- If index is out of bounds, an error code will be set in the status object,
--- and -1 will be returned.
--- 
---@param list ffi.cdata @(const TF_DeviceList *)
---@param index number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int64_t)
function M.TF_DeviceListMemoryBytes(list, index, status)
    return _CALL("TF_DeviceListMemoryBytes", list, index, status)
end
_FUNCDEF("TF_DeviceListMemoryBytes", { "const TF_DeviceList *", "int", "TF_Status *" }, "int64_t")

--

--- Retrieve the incarnation number of a given device.
--- If index is out of bounds, an error code will be set in the status object,
--- and 0 will be returned.
--- 
---@param list ffi.cdata @(const TF_DeviceList *)
---@param index number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return number @(uint64_t)
function M.TF_DeviceListIncarnation(list, index, status)
    return _CALL("TF_DeviceListIncarnation", list, index, status)
end
_FUNCDEF("TF_DeviceListIncarnation", { "const TF_DeviceList *", "int", "TF_Status *" }, "uint64_t")

--

--- --------------------------------------------------------------------------
--- Load plugins containing custom ops and kernels
--- TF_Library holds information about dynamically loaded TensorFlow plugins.
--- 

_TYPEDEF("TF_Library", "struct TF_Library")

--

--- Load the library specified by library_filename and register the ops and
--- kernels present in that library.
--- Pass "library_filename" to a platform-specific mechanism for dynamically
--- loading a library. The rules for determining the exact location of the
--- library are platform-specific and are not documented here.
--- On success, place OK in status and return the newly created library handle.
--- The caller owns the library handle.
--- On failure, place an error status in status and return NULL.
--- 
---@param library_filename string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Library *)
function M.TF_LoadLibrary(library_filename, status)
    return _CALL("TF_LoadLibrary", library_filename, status)
end
_FUNCDEF("TF_LoadLibrary", { "const char *", "TF_Status *" }, "TF_Library *")

--

--- Get the OpList of OpDefs defined in the library pointed by lib_handle.
--- Returns a TF_Buffer. The memory pointed to by the result is owned by
--- lib_handle. The data in the buffer will be the serialized OpList proto for
--- ops defined in the library.
--- 
---@param lib_handle ffi.cdata @(TF_Library *)
---@return TF_Buffer @(TF_Buffer)
function M.TF_GetOpList(lib_handle)
    return _CALL("TF_GetOpList", lib_handle)
end
_FUNCDEF("TF_GetOpList", { "TF_Library *" }, "TF_Buffer")

--

--- Frees the memory associated with the library handle.
--- Does NOT unload the library.
--- 
---@param lib_handle ffi.cdata @(TF_Library *)
function M.TF_DeleteLibraryHandle(lib_handle)
    return _CALL("TF_DeleteLibraryHandle", lib_handle)
end
_FUNCDEF("TF_DeleteLibraryHandle", { "TF_Library *" }, "void")

--

--- Get the OpList of all OpDefs defined in this address space.
--- Returns a TF_Buffer, ownership of which is transferred to the caller
--- (and can be freed using TF_DeleteBuffer).
--- The data in the buffer will be the serialized OpList proto for ops registered
--- in this address space.
--- 
---@return ffi.cdata @(TF_Buffer *)
function M.TF_GetAllOpList()
    return _CALL("TF_GetAllOpList")
end
_FUNCDEF("TF_GetAllOpList", {  }, "TF_Buffer *")

--

--- TF_ApiDefMap encapsulates a collection of API definitions for an operation.
--- This object maps the name of a TensorFlow operation to a description of the
--- API to generate for it, as defined by the ApiDef protocol buffer (
--- https://www.tensorflow.org/code/tensorflow/core/framework/api_def.proto)
--- The ApiDef messages are typically used to generate convenience wrapper
--- functions for TensorFlow operations in various language bindings.
--- 

_TYPEDEF("TF_ApiDefMap", "struct TF_ApiDefMap")

--

--- Creates a new TF_ApiDefMap instance.
--- Params:
--- op_list_buffer - TF_Buffer instance containing serialized OpList
--- protocol buffer. (See
--- https://www.tensorflow.org/code/tensorflow/core/framework/op_def.proto
--- for the OpList proto definition).
--- status - Set to OK on success and an appropriate error on failure.
--- 
---@param op_list_buffer ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_ApiDefMap *)
function M.TF_NewApiDefMap(op_list_buffer, status)
    return _CALL("TF_NewApiDefMap", op_list_buffer, status)
end
_FUNCDEF("TF_NewApiDefMap", { "TF_Buffer *", "TF_Status *" }, "TF_ApiDefMap *")

--

--- Deallocates a TF_ApiDefMap.
--- 
---@param apimap ffi.cdata @(TF_ApiDefMap *)
function M.TF_DeleteApiDefMap(apimap)
    return _CALL("TF_DeleteApiDefMap", apimap)
end
_FUNCDEF("TF_DeleteApiDefMap", { "TF_ApiDefMap *" }, "void")

--

--- Add ApiDefs to the map.
--- `text` corresponds to a text representation of an ApiDefs protocol message.
--- (https://www.tensorflow.org/code/tensorflow/core/framework/api_def.proto).
--- The provided ApiDefs will be merged with existing ones in the map, with
--- precedence given to the newly added version in case of conflicts with
--- previous calls to TF_ApiDefMapPut.
--- 
---@param api_def_map ffi.cdata @(TF_ApiDefMap *)
---@param text string @(const char *)
---@param text_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TF_ApiDefMapPut(api_def_map, text, text_len, status)
    return _CALL("TF_ApiDefMapPut", api_def_map, text, text_len, status)
end
_FUNCDEF("TF_ApiDefMapPut", { "TF_ApiDefMap *", "const char *", "size_t", "TF_Status *" }, "void")

--

--- Returns a serialized ApiDef protocol buffer for the TensorFlow operation
--- named `name`.
--- 
---@param api_def_map ffi.cdata @(TF_ApiDefMap *)
---@param name string @(const char *)
---@param name_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Buffer *)
function M.TF_ApiDefMapGet(api_def_map, name, name_len, status)
    return _CALL("TF_ApiDefMapGet", api_def_map, name, name_len, status)
end
_FUNCDEF("TF_ApiDefMapGet", { "TF_ApiDefMap *", "const char *", "size_t", "TF_Status *" }, "TF_Buffer *")

--

--- --------------------------------------------------------------------------
--- Kernel definition information.
--- Returns a serialized KernelList protocol buffer containing KernelDefs for all
--- registered kernels.
--- 
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Buffer *)
function M.TF_GetAllRegisteredKernels(status)
    return _CALL("TF_GetAllRegisteredKernels", status)
end
_FUNCDEF("TF_GetAllRegisteredKernels", { "TF_Status *" }, "TF_Buffer *")

--

--- Returns a serialized KernelList protocol buffer containing KernelDefs for all
--- kernels registered for the operation named `name`.
--- 
---@param name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Buffer *)
function M.TF_GetRegisteredKernelsForOp(name, status)
    return _CALL("TF_GetRegisteredKernelsForOp", name, status)
end
_FUNCDEF("TF_GetRegisteredKernelsForOp", { "const char *", "TF_Status *" }, "TF_Buffer *")

--

--- Update edge, switch input/ output in a node
--- 
---@param graph ffi.cdata @(TF_Graph *)
---@param new_src TF_Output @(TF_Output)
---@param dst TF_Input @(TF_Input)
---@param status ffi.cdata @(TF_Status *)
function M.TF_UpdateEdge(graph, new_src, dst, status)
    return _CALL("TF_UpdateEdge", graph, new_src, dst, status)
end
_FUNCDEF("TF_UpdateEdge", { "TF_Graph *", "TF_Output", "TF_Input", "TF_Status *" }, "void")

--

--- --------------------------------------------------------------------------
--- In-process TensorFlow server functionality, for use in distributed training.
--- A Server instance encapsulates a set of devices and a Session target that
--- can participate in distributed training. A server belongs to a cluster
--- (specified by a ClusterSpec), and corresponds to a particular task in a
--- named job. The server can communicate with any other server in the same
--- cluster.
--- In-process TensorFlow server.
--- 

_TYPEDEF("TF_Server", "struct TF_Server")

--

--- Creates a new in-process TensorFlow server configured using a serialized
--- ServerDef protocol buffer provided via `proto` and `proto_len`.
--- The server will not serve any requests until TF_ServerStart is invoked.
--- The server will stop serving requests once TF_ServerStop or
--- TF_DeleteServer is invoked.
--- 
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Server *)
function M.TF_NewServer(proto, proto_len, status)
    return _CALL("TF_NewServer", proto, proto_len, status)
end
_FUNCDEF("TF_NewServer", { "const void *", "size_t", "TF_Status *" }, "TF_Server *")

--

--- Starts an in-process TensorFlow server.
--- 
---@param server ffi.cdata @(TF_Server *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_ServerStart(server, status)
    return _CALL("TF_ServerStart", server, status)
end
_FUNCDEF("TF_ServerStart", { "TF_Server *", "TF_Status *" }, "void")

--

--- Stops an in-process TensorFlow server.
--- 
---@param server ffi.cdata @(TF_Server *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_ServerStop(server, status)
    return _CALL("TF_ServerStop", server, status)
end
_FUNCDEF("TF_ServerStop", { "TF_Server *", "TF_Status *" }, "void")

--

--- Blocks until the server has been successfully stopped (via TF_ServerStop or
--- TF_ServerClose).
--- 
---@param server ffi.cdata @(TF_Server *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_ServerJoin(server, status)
    return _CALL("TF_ServerJoin", server, status)
end
_FUNCDEF("TF_ServerJoin", { "TF_Server *", "TF_Status *" }, "void")

--

--- Returns the target string that can be provided to TF_SetTarget() to connect
--- a TF_Session to `server`.
--- The returned string is valid only until TF_DeleteServer is invoked.
--- 
---@param server ffi.cdata @(TF_Server *)
---@return string @(const char *)
function M.TF_ServerTarget(server)
    return _CALL("TF_ServerTarget", server)
end
_FUNCDEF("TF_ServerTarget", { "TF_Server *" }, "const char *")

--

--- Destroy an in-process TensorFlow server, frees memory. If server is running
--- it will be stopped and joined.
--- 
---@param server ffi.cdata @(TF_Server *)
function M.TF_DeleteServer(server)
    return _CALL("TF_DeleteServer", server)
end
_FUNCDEF("TF_DeleteServer", { "TF_Server *" }, "void")

--

--- Register a listener method that processes printed messages.
--- If any listeners are registered, the print operator will call all listeners
--- with the printed messages and immediately return without writing to the
--- logs.
--- 
---@param listener ffi.cdata @(void *)
function M.TF_RegisterLogListener(listener)
    return _CALL("TF_RegisterLogListener", listener)
end
_FUNCDEF("TF_RegisterLogListener", { "void *" }, "void")

--

--- void TF_RegisterLogListener(void (*listener)(const char*));
--- Register a FileSystem plugin from filename `plugin_filename`.
--- On success, place OK in status.
--- On failure, place an error status in status.
--- 
---@param plugin_filename string @(const char *)
---@param status ffi.cdata @(TF_Status *)
function M.TF_RegisterFilesystemPlugin(plugin_filename, status)
    return _CALL("TF_RegisterFilesystemPlugin", plugin_filename, status)
end
_FUNCDEF("TF_RegisterFilesystemPlugin", { "const char *", "TF_Status *" }, "void")

--

------------------------------------------------------------------------------
-- header/tf_datatype.h
------------------------------------------------------------------------------

--

--- TF_DataTypeSize returns the sizeof() for the underlying type corresponding
--- to the given TF_DataType enum value. Returns 0 for variable length types
--- (eg. TF_STRING) or on failure.
---
---@param dt TF_DataType @(TF_DataType)
---@return number @(size_t)
function M.TF_DataTypeSize(dt)
    return _CALL("TF_DataTypeSize", dt)
end
_FUNCDEF("TF_DataTypeSize", { "TF_DataType" }, "size_t")

--

------------------------------------------------------------------------------
-- header/tf_status.h
------------------------------------------------------------------------------

--

_TYPEDEF("TF_Status", "struct TF_Status")

--

--

--- --------------------------------------------------------------------------
--- Return a new status object.
---
---@return ffi.cdata @(TF_Status *)
function M.TF_NewStatus()
    return _CALL("TF_NewStatus")
end
_FUNCDEF("TF_NewStatus", {  }, "TF_Status *")

--

--- Delete a previously created status object.
---
---@param s ffi.cdata @(TF_Status *)
function M.TF_DeleteStatus(s)
    return _CALL("TF_DeleteStatus", s)
end
_FUNCDEF("TF_DeleteStatus", { "TF_Status *" }, "void")

--

--- Record <code, msg> in *s.  Any previous information is lost.
--- A common use is to clear a status: TF_SetStatus(s, TF_OK, "");
---
---@param s ffi.cdata @(TF_Status *)
---@param code TF_Code @(TF_Code)
---@param msg string @(const char *)
function M.TF_SetStatus(s, code, msg)
    return _CALL("TF_SetStatus", s, code, msg)
end
_FUNCDEF("TF_SetStatus", { "TF_Status *", "TF_Code", "const char *" }, "void")

--

--- Convert from an I/O error code (e.g., errno) to a TF_Status value.
--- Any previous information is lost. Prefer to use this instead of TF_SetStatus
--- when the error comes from I/O operations.
---
---@param s ffi.cdata @(TF_Status *)
---@param error_code number @(int)
---@param context string @(const char *)
function M.TF_SetStatusFromIOError(s, error_code, context)
    return _CALL("TF_SetStatusFromIOError", s, error_code, context)
end
_FUNCDEF("TF_SetStatusFromIOError", { "TF_Status *", "int", "const char *" }, "void")

--

--- Return the code record in *s.
---
---@param s ffi.cdata @(const TF_Status *)
---@return TF_Code @(TF_Code)
function M.TF_GetCode(s)
    return _CALL("TF_GetCode", s)
end
_FUNCDEF("TF_GetCode", { "const TF_Status *" }, "TF_Code")

--

--- Return a pointer to the (null-terminated) error message in *s.  The
--- return value points to memory that is only usable until the next
--- mutation to *s.  Always returns an empty string if TF_GetCode(s) is
--- TF_OK.
---
---@param s ffi.cdata @(const TF_Status *)
---@return string @(const char *)
function M.TF_Message(s)
    return _CALL("TF_Message", s)
end
_FUNCDEF("TF_Message", { "const TF_Status *" }, "const char *")

--

------------------------------------------------------------------------------
-- header/tf_tensor.h
------------------------------------------------------------------------------

_TYPEDEF("TF_Bool", "unsigned char")

--

--- Allocator Attributes used for tensor allocation.
--- Set boolean to 1 for CPU allocation, else 0.
---

_TYPEDEF("TF_AllocatorAttributes", "struct TF_AllocatorAttributes { size_t struct_size ; TF_Bool on_host ; }")

--

--- #define TF_ALLOCATOR_ATTRIBUTES_STRUCT_SIZE \
--- //   TF_OFFSET_OF_END(TF_AllocatorAttributes, on_host)
--- --------------------------------------------------------------------------
--- TF_Tensor holds a multi-dimensional array of elements of a single data type.
--- For all types other than TF_STRING, the data buffer stores elements
--- in row major order.  E.g. if data is treated as a vector of TF_DataType:
--- element 0:   index (0, ..., 0)
--- element 1:   index (0, ..., 1)
--- ...
--- The format for TF_STRING tensors is:
--- start_offset: array[uint64]
--- data:         byte[...]
--- The string length (as a varint, start_offset[i + 1] - start_offset[i]),
--- followed by the contents of the string is encoded at data[start_offset[i]].
--- TF_StringEncode and TF_StringDecode facilitate this encoding.
---

_TYPEDEF("TF_Tensor", "struct TF_Tensor")

--

--- Return a new tensor that holds the bytes data[0,len-1].
--- The data will be deallocated by a subsequent call to TF_DeleteTensor via:
--- (*deallocator)(data, len, deallocator_arg)
--- Clients must provide a custom deallocator function so they can pass in
--- memory managed by something like numpy.
--- May return NULL (and invoke the deallocator) if the provided data buffer
--- (data, len) is inconsistent with a tensor of the given TF_DataType
--- and the shape specified by (dima, num_dims).
--- void (*deallocator)(void* data, size_t len, void* arg),
---
---@param type TF_DataType @(TF_DataType)
---@param dims ffi.cdata @(const int64_t *)
---@param num_dims number @(int)
---@param data ffi.cdata @(void *)
---@param len number @(size_t)
---@param deallocator ffi.cdata @(void *)
---@param deallocator_arg ffi.cdata @(void *)
---@return ffi.cdata @(TF_Tensor *)
function M.TF_NewTensor(type, dims, num_dims, data, len, deallocator, deallocator_arg)
    return _CALL("TF_NewTensor", type, dims, num_dims, data, len, deallocator, deallocator_arg)
end
_FUNCDEF("TF_NewTensor", { "TF_DataType", "const int64_t *", "int", "void *", "size_t", "void *", "void *" }, "TF_Tensor *")

--

--- Allocate and return a new Tensor.
--- This function is an alternative to TF_NewTensor and should be used when
--- memory is allocated to pass the Tensor to the C API. The allocated memory
--- satisfies TensorFlow's memory alignment preferences and should be preferred
--- over calling malloc and free.
--- The caller must set the Tensor values by writing them to the pointer returned
--- by TF_TensorData with length TF_TensorByteSize.
---
---@param type TF_DataType @(TF_DataType)
---@param dims ffi.cdata @(const int64_t *)
---@param num_dims number @(int)
---@param len number @(size_t)
---@return ffi.cdata @(TF_Tensor *)
function M.TF_AllocateTensor(type, dims, num_dims, len)
    return _CALL("TF_AllocateTensor", type, dims, num_dims, len)
end
_FUNCDEF("TF_AllocateTensor", { "TF_DataType", "const int64_t *", "int", "size_t" }, "TF_Tensor *")

--

--- Deletes `tensor` and returns a new TF_Tensor with the same content if
--- possible. Returns nullptr and leaves `tensor` untouched if not.
---
---@param tensor ffi.cdata @(TF_Tensor *)
---@return ffi.cdata @(TF_Tensor *)
function M.TF_TensorMaybeMove(tensor)
    return _CALL("TF_TensorMaybeMove", tensor)
end
_FUNCDEF("TF_TensorMaybeMove", { "TF_Tensor *" }, "TF_Tensor *")

--

--- Destroy a tensor.
---
---@param tensor ffi.cdata @(TF_Tensor *)
function M.TF_DeleteTensor(tensor)
    return _CALL("TF_DeleteTensor", tensor)
end
_FUNCDEF("TF_DeleteTensor", { "TF_Tensor *" }, "void")

--

--- Return the type of a tensor element.
---
---@param tensor ffi.cdata @(const TF_Tensor *)
---@return TF_DataType @(TF_DataType)
function M.TF_TensorType(tensor)
    return _CALL("TF_TensorType", tensor)
end
_FUNCDEF("TF_TensorType", { "const TF_Tensor *" }, "TF_DataType")

--

--- Return the number of dimensions that the tensor has.
---
---@param tensor ffi.cdata @(const TF_Tensor *)
---@return number @(int)
function M.TF_NumDims(tensor)
    return _CALL("TF_NumDims", tensor)
end
_FUNCDEF("TF_NumDims", { "const TF_Tensor *" }, "int")

--

--- Return the length of the tensor in the "dim_index" dimension.
--- REQUIRES: 0 <= dim_index < TF_NumDims(tensor)
---
---@param tensor ffi.cdata @(const TF_Tensor *)
---@param dim_index number @(int)
---@return number @(int64_t)
function M.TF_Dim(tensor, dim_index)
    return _CALL("TF_Dim", tensor, dim_index)
end
_FUNCDEF("TF_Dim", { "const TF_Tensor *", "int" }, "int64_t")

--

--- Return the size of the underlying data in bytes.
---
---@param tensor ffi.cdata @(const TF_Tensor *)
---@return number @(size_t)
function M.TF_TensorByteSize(tensor)
    return _CALL("TF_TensorByteSize", tensor)
end
_FUNCDEF("TF_TensorByteSize", { "const TF_Tensor *" }, "size_t")

--

--- Return a pointer to the underlying data buffer.
---
---@param tensor ffi.cdata @(const TF_Tensor *)
---@return ffi.cdata @(void *)
function M.TF_TensorData(tensor)
    return _CALL("TF_TensorData", tensor)
end
_FUNCDEF("TF_TensorData", { "const TF_Tensor *" }, "void *")

--

--- Returns the number of elements in the tensor.
---
---@param tensor ffi.cdata @(const TF_Tensor *)
---@return number @(int64_t)
function M.TF_TensorElementCount(tensor)
    return _CALL("TF_TensorElementCount", tensor)
end
_FUNCDEF("TF_TensorElementCount", { "const TF_Tensor *" }, "int64_t")

--

--- Copy the internal data representation of `from` to `to`. `new_dims` and
--- `num_new_dims` specify the new shape of the `to` tensor, `type` specifies its
--- data type. On success, *status is set to TF_OK and the two tensors share the
--- same data buffer.
--- This call requires that the `from` tensor and the given type and shape (dims
--- and num_dims) are "compatible" (i.e. they occupy the same number of bytes).
--- Specifically, given from_type_size = TF_DataTypeSize(TF_TensorType(from)):
--- ShapeElementCount(dims, num_dims) * TF_DataTypeSize(type)
--- must equal
--- TF_TensorElementCount(from) * from_type_size
--- where TF_ShapeElementCount would be the number of elements in a tensor with
--- the given shape.
--- In addition, this function requires:
--- TF_DataTypeSize(TF_TensorType(from)) != 0
--- TF_DataTypeSize(type) != 0
--- If any of the requirements are not met, *status is set to
--- TF_INVALID_ARGUMENT.
---
---@param from ffi.cdata @(const TF_Tensor *)
---@param type TF_DataType @(TF_DataType)
---@param to ffi.cdata @(TF_Tensor *)
---@param new_dims ffi.cdata @(const int64_t *)
---@param num_new_dims number @(int)
---@param status ffi.cdata @(TF_Status *)
function M.TF_TensorBitcastFrom(from, type, to, new_dims, num_new_dims, status)
    return _CALL("TF_TensorBitcastFrom", from, type, to, new_dims, num_new_dims, status)
end
_FUNCDEF("TF_TensorBitcastFrom", { "const TF_Tensor *", "TF_DataType", "TF_Tensor *", "const int64_t *", "int", "TF_Status *" }, "void")

--

--- Returns bool iff this tensor is aligned.
---
---@param tensor ffi.cdata @(const TF_Tensor *)
---@return boolean @(bool)
function M.TF_TensorIsAligned(tensor)
    return _CALL("TF_TensorIsAligned", tensor)
end
_FUNCDEF("TF_TensorIsAligned", { "const TF_Tensor *" }, "bool")

--

return M
