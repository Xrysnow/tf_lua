---@class tf.TFOperationDescription
--- Operation being built. The underlying graph must outlive this.
local M = class('tf.TFOperationDescription')
local lib = require('tf.c._c_api')
local Status = require('tf.c.TFStatus')
local base = require('tf.base')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end

--- Specify the device for `desc`.  Defaults to empty, meaning unconstrained.
---@param device string
function M:setDevice(device)
    lib.TF_SetDevice(self.handle, device)
end

local function makeTFOutput(v)
    v = handle(v)
    if ffi.istype('TF_Operation*', v) then
        local out = ffi.new('TF_Output[1]')
        out[0].oper = v
        out[0].index = 0
        return out
    else
        return v
    end
end

--- For inputs that take a single tensor.
---@param input tf.TFOutput|tf.TFOperation
function M:addInput(input)
    lib.TF_AddInput(self.handle, makeTFOutput(input)[0])
end

--- The calls to TF_AddInput and TF_AddInputList must match (in number,
--- order, and type) the op declaration.  For example, the "Concat" op
--- has registration:
---   REGISTER_OP("Concat")
---       .Input("concat_dim: int32")
---       .Input("values: N * T")
---       .Output("output: T")
---       .Attr("N: int >= 2")
---       .Attr("T: type");
--- that defines two inputs, "concat_dim" and "values" (in that order).
--- You must use TF_AddInput() for the first input (since it takes a
--- single tensor), and TF_AddInputList() for the second input (since
--- it takes a list, even if you were to pass a list with a single
--- tensor), as in:
---   TF_OperationDescription* desc = TF_NewOperation(graph, "Concat", "c");
---   TF_Output concat_dim_input = {...};
---   TF_AddInput(desc, concat_dim_input);
---   TF_Output values_inputs[5] = {{...}, ..., {...}};
---   TF_AddInputList(desc, values_inputs, 5);

--- For inputs that take a list of tensors.
--- inputs must point to TF_Output[num_inputs].
---@param inputs tf.TFOutput[]|tf.TFOperation[]
function M:addInputList(inputs)
    local n = #inputs
    if n == 0 then
        return
    end
    for i = 1, n do
        inputs[i] = makeTFOutput(inputs[i])
    end
    local inputs_ = require('tf.c.TFOutput').pack(inputs)
    lib.TF_AddInputList(self.handle, inputs_, n)
end
--- Call once per control input to `desc`.
---@param input tf.TFOperation
function M:addControlInput(input)
    lib.TF_AddControlInput(self.handle, assert(handle(input)))
end
--- Request that `desc` be co-located on the device where `op`
--- is placed.
---
--- Use of this is discouraged since the implementation of device placement is
--- subject to change. Primarily intended for internal libraries
---@param op tf.TFOperation
function M:colocateWith(op)
    lib.TF_ColocateWith(self.handle, assert(handle(op)))
end

--- Call some TF_SetAttr*() function for every attr that is not
--- inferred from an input and doesn't have a default value you wish to
--- keep.

--- `value` must point to a string of length `length` bytes.
function M:setAttrString(attr_name, value, length)
    lib.TF_SetAttrString(self.handle, attr_name, value, length)
end

--- `values` and `lengths` each must have lengths `num_values`.
--- `values[i]` must point to a string of length `lengths[i]` bytes.
function M:setAttrStringList(attr_name, values, lengths, num_values)
    lib.TF_SetAttrStringList(self.handle, attr_name, values, lengths, num_values)
end

function M:setAttrInt(attr_name, value)
    lib.TF_SetAttrInt(self.handle, attr_name, value)
end

function M:setAttrIntList(attr_name, values)
    local v, n = base.packValues('int64_t', values)
    lib.TF_SetAttrIntList(self.handle, attr_name, v, n)
end

function M:setAttrFloat(attr_name, value)
    lib.TF_SetAttrFloat(self.handle, attr_name, value)
end

function M:setAttrFloatList(attr_name, values)
    local v, n = base.packValues('float', values)
    lib.TF_SetAttrFloatList(self.handle, attr_name, v, n)
end

function M:setAttrBool(attr_name, value)
    value = base.tfBool(value)
    lib.TF_SetAttrBool(self.handle, attr_name, value)
end

function M:setAttrBoolList(attr_name, values)
    local values_ = {}
    for i = 1, #values do
        values_[i] = base.tfBool(values[i])
    end
    local v, n = base.packValues('unsigned char', values_)
    lib.TF_SetAttrBoolList(self.handle, attr_name, v, n)
end

function M:setAttrType(attr_name, value)
    lib.TF_SetAttrType(self.handle, attr_name, assert(base.dataType(value), tostring(value)))
end

function M:setAttrTypeList(attr_name, values)
    local v, n = base.packDataTypes(values)
    lib.TF_SetAttrTypeList(self.handle, attr_name, v, n)
end

function M:setAttrPlaceholder(attr_name, placeholder)
    lib.TF_SetAttrPlaceholder(self.handle, attr_name, placeholder)
end
--- Set a 'func' attribute to the specified name.
--- `value` must point to a string of length `length` bytes.
function M:setAttrFuncName(attr_name, value)
    lib.TF_SetAttrFuncName(self.handle, attr_name, value, #value)
end
--- Set `num_dims` to -1 to represent "unknown rank".  Otherwise,
--- `dims` points to an array of length `num_dims`.  `dims[i]` must be
--- >= -1, with -1 meaning "unknown dimension".
---@param attr_name string
---@param dims number[]|nil
function M:setAttrShape(attr_name, dims)
    local v, n = nil, -1
    if dims then
        v, n = base.packDims(dims)
    end
    lib.TF_SetAttrShape(self.handle, attr_name, v, n)
end
--- `dims` and `num_dims` must point to arrays of length `num_shapes`.
--- Set `num_dims[i]` to -1 to represent "unknown rank".  Otherwise,
--- `dims[i]` points to an array of length `num_dims[i]`.  `dims[i][j]`
--- must be >= -1, with -1 meaning "unknown dimension".
---@param attr_name string
---@param dims number[][]
function M:setAttrShapeList(attr_name, dims)
    local dims_ = {}
    local num_dims = {}
    for i = 1, #dims do
        local v, n = nil, -1
        if dims[i] then
            v, n = base.packDims(dims[i])
        end
        dims_[i] = v
        num_dims[i] = n
    end
    local vd, _ = base.packValues('int64_t*', dims_, #dims)
    local vn, _ = base.packValues('int', num_dims)
    lib.TF_SetAttrShapeList(self.handle, attr_name, vd, vn, #dims)
end
--- `proto` must point to an array of `proto_len` bytes representing a
--- binary-serialized TensorShapeProto.
function M:setAttrTensorShapeProto(attr_name, proto, proto_len)
    local s = Status()
    lib.TF_SetAttrTensorShapeProto(self.handle, attr_name, proto, proto_len, handle(s))
    s:assert()
end
--- `protos` and `proto_lens` must point to arrays of length `num_shapes`.
--- `protos[i]` must point to an array of `proto_lens[i]` bytes
--- representing a binary-serialized TensorShapeProto.
function M:setAttrTensorShapeProtoList(attr_name, protos, proto_lens)
    local protos_, n = base.packValues('void*', protos)
    local proto_lens_, _ = base.packValues('size_t', proto_lens)
    local s = Status()
    lib.TF_SetAttrTensorShapeProtoList(self.handle, attr_name, protos_, proto_lens_, n, handle(s))
    s:assert()
end

---@param attr_name string
---@param value tf.TFTensor
function M:setAttrTensor(attr_name, value)
    local s = Status()
    lib.TF_SetAttrTensor(self.handle, attr_name, handle(value), handle(s))
    s:assert()
end

---@param attr_name string
---@param values tf.TFTensor[]
function M:setAttrTensorList(attr_name, values)
    local s = Status()
    local v, n = base.packHandles('TF_Tensor*', values)
    lib.TF_SetAttrTensorList(self.handle, attr_name, v, n, handle(s))
    s:assert()
end
--- `proto` should point to a sequence of bytes of length `proto_len`
--- representing a binary serialization of an AttrValue protocol
--- buffer.
function M:setAttrValueProto(attr_name, proto, proto_len)
    local s = Status()
    lib.TF_SetAttrValueProto(self.handle, attr_name, proto, proto_len, handle(s))
    s:assert()
end
--- If this function succeeds:
---   * *status is set to an OK value,
---   * a TF_Operation is added to the graph,
---   * a non-null value pointing to the added operation is returned --
---     this value is valid until the underlying graph is deleted.
--- Otherwise:
---   * *status is set to a non-OK value,
---   * the graph is not modified,
---   * a null value is returned.
--- In either case, it deletes `desc`.
function M:finishOperation()
    local s = Status()
    local ret = lib.TF_FinishOperation(self.handle, handle(s))
    s:assert()
    if ffi.isnullptr(ret) then
        return nil
    end
    return require('tf.c.TFOperation')(ret)
end

--

---@param attr_name string
---@param value tf.TFFunction
function M:setAttrFunction(attr_name, value)
    if type(value) ~= 'string' then
        value = value:name()
    end
    self:setAttrFuncName(attr_name, value)
end

function M:setAttrFunctionList(attr_name, values)
    error('TFOperationDescription dose not support setAttrFunctionList')
end

--

--- Operation will only be added to *graph when TF_FinishOperation() is
--- called (assuming TF_FinishOperation() does not return an error).
--- *graph must not be deleted until after TF_FinishOperation() is
--- called.
---@param graph tf.TFGraph
---@param op_type string
---@param oper_name string
function M.NewOperation(graph, op_type, oper_name)
    local p = lib.TF_NewOperation(handle(graph), op_type, oper_name)
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

return M
