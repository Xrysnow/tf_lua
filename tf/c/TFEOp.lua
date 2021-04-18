---@class tfe.TFEOp:tf.AbstractOperation
--- Description of the TensorFlow op to execute.
---
--- Assumes that the provided 'ctx' outlives the returned TFE_Op, i.e.,
--- TFE_DeleteOp() is called before TFE_DeleteContext().
---
--- Very similar to TF_OperationDescription with some differences:
--- (1) TF_Output or TFE_TensorHandle* as arguments to TF_AddInput,
---     TF_AddInputList
--- (2) TF_ColocateWith, TF_AddControlInput etc. do not make sense.
--- (3) Implementation detail: Avoid use of NodeBuilder/NodeDefBuilder since
---     the additional sanity checks there seem unnecessary;
local M = class('tfe.TFEOp')
local base = require('tf.base')
local lib = base._libeager
local libex = base._libex
local libeex = base._libeagerex
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
    --- Fetch a reference to `op`'s attributes. The returned reference is only valid
    --- while `op` is alive.
    self._attr_handle = libeex.TFE_OpGetAttrs(self.handle)
end

function M:dtor()
    lib.TFE_DeleteOp(self.handle)
    self.handle = nil
    self._attr_handle = nil
end

--- Returns the op or function name `op` will execute.
---
--- The returned string remains valid throughout the lifetime of 'op'.
function M:name()
    local s = Status()
    local ret = lib.TFE_OpGetName(self.handle, handle(s))
    s:assert()
    return ffi.string(ret)
end

function M:getContext()
    local s = Status()
    local ret = lib.TFE_OpGetContext(self.handle, handle(s))
    s:assert()
    if ffi.isnullptr(ret) then
        return nil
    end
    return require('tf.c.TFEContext')(ret)
end

---@param device_name string
function M:setDevice(device_name)
    local s = Status()
    lib.TFE_OpSetDevice(self.handle, device_name, handle(s))
    s:assert()
end

function M:getDevice()
    local s = Status()
    local ret = lib.TFE_OpGetDevice(self.handle, handle(s))
    s:assert()
    return ffi.string(ret)
end

---@param input tfe.TFETensorHandle
function M:addInput(input)
    local s = Status()
    lib.TFE_OpAddInput(self.handle, assert(handle(input)), handle(s))
    s:assert()
end

---@param inputs tfe.TFETensorHandle[]
function M:addInputList(inputs)
    local v, n = base.packHandles('TFE_TensorHandle*', inputs)
    local s = Status()
    lib.TFE_OpAddInputList(self.handle, v, n, handle(s))
    s:assert()
end

--- Fetches the current number of inputs attached to `op`.
---
--- Does not use the operation's definition to determine how many inputs should
--- be attached. It is intended for use with TFE_OpGetFlatInput to inspect an
--- already-finalized operation.
---
--- Note that TFE_OpGetFlatInputCount and TFE_OpGetFlatInput operate on a flat
--- sequence of inputs, unlike TFE_OpGetInputLength (for getting the length of a
--- particular named input list, which may only be part of the op's inputs).
function M:getFlatInputCount()
    local s = Status()
    local ret = lib.TFE_OpGetFlatInputCount(self.handle, handle(s))
    s:assert()
    return tonumber(ret)
end

--- Returns a borrowed reference to one of `op`'s inputs. Use
--- `TFE_TensorHandleCopySharingTensor` to make a new reference.
---@param index number
function M:getFlatInput(index)
    local s = Status()
    local ret = lib.TFE_OpGetFlatInput(self.handle, index, handle(s))
    s:assert()
    return require('tf.c.TFETensorHandle')(ret)
end

---@param attr_name string
function M:getAttrType(attr_name)
    local is_list = ffi.new('unsigned char[1]')
    local s = Status()
    local ret = lib.TFE_OpGetAttrType(self.handle, attr_name, is_list, handle(s))
    s:assert()
    return ret, is_list[0] > 0
end

function M:setAttrString(attr_name, value, length)
    lib.TFE_OpSetAttrString(self.handle, attr_name, value, length or #value)
end

function M:setAttrInt(attr_name, value)
    lib.TFE_OpSetAttrInt(self.handle, attr_name, value)
end

function M:setAttrFloat(attr_name, value)
    lib.TFE_OpSetAttrFloat(self.handle, attr_name, value)
end

function M:setAttrBool(attr_name, value)
    lib.TFE_OpSetAttrBool(self.handle, attr_name, base.tfBool(value))
end

function M:setAttrType(attr_name, value)
    value = base.dataType(value)
    lib.TFE_OpSetAttrType(self.handle, attr_name, value)
end

function M:setAttrShape(attr_name, dims)
    local ndim = -1
    if dims then
        dims, ndim = base.packDims(dims)
    end
    local s = Status()
    lib.TFE_OpSetAttrShape(self.handle, attr_name, dims, ndim, handle(s))
    s:assert()
end

--- Sets the attribute attr_name to be a function specified by 'function'.
---
--- TODO(ashankar,iga): Add this functionality to the C API for graph
--- construction. Perhaps we want an AttrValueMap equivalent in the C API?
---@param attr_name string
---@param value tfe.TFEOp
function M:setAttrFunction(attr_name, value)
    lib.TFE_OpSetAttrFunction(self.handle, attr_name, handle(value))
end

---@param attr_name string
---@param value string
function M:setAttrFunctionName(attr_name, value)
    lib.TFE_OpSetAttrFunctionName(self.handle, attr_name, value, #value)
end

---@param attr_name string
---@param tensor tf.TFTensor
function M:setAttrTensor(attr_name, tensor)
    local s = Status()
    lib.TFE_OpSetAttrTensor(self.handle, attr_name, handle(tensor), handle(s))
    s:assert()
end

function M:setAttrStringList(attr_name, values, lengths, num_values)
    if not values then
        values, lengths, num_values = {}, nil, 0
    end
    local values_ = values
    if type(values) == 'table' then
        num_values = num_values or #values
        -- not overwrite values to avoid gc
        values_ = ffi.new('void*[?]', num_values)
        for i = 1, num_values do
            values_[i - 1] = ffi.cast('void*', values[i])
        end
        if not lengths then
            lengths = ffi.new('size_t[?]', num_values)
            for i = 1, num_values do
                lengths[i - 1] = #values[i]
            end
        end
    end
    if num_values == 0 then
        values_, lengths = nil, nil
    end
    lib.TFE_OpSetAttrStringList(self.handle, attr_name, values_, lengths, num_values)
end

function M:setAttrIntList(attr_name, values)
    local v, n = base.packValues('int64_t', values)
    lib.TFE_OpSetAttrIntList(self.handle, attr_name, v, n)
end

function M:setAttrFloatList(attr_name, values)
    local v, n = base.packValues('float', values)
    lib.TFE_OpSetAttrFloatList(self.handle, attr_name, v, n)
end

function M:setAttrBoolList(attr_name, values)
    local values_ = {}
    for i = 1, #values do
        values_[i] = base.tfBool(values[i])
    end
    local v, n = base.packValues('unsigned char', values_)
    lib.TFE_OpSetAttrBoolList(self.handle, attr_name, v, n)
end

function M:setAttrTypeList(attr_name, values)
    local v, n = base.packDataTypes(values)
    lib.TF_SetAttrTypeList(self.handle, attr_name, v, n)
end

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
    local s = Status()
    lib.TFE_OpSetAttrShapeList(self.handle, attr_name, vd, vn, #dims, handle(s))
    s:assert()
end

function M:setAttrFunctionList(attr_name, values)
    local v, n = base.packHandles('TFE_Op*', values)
    lib.TFE_OpSetAttrFunctionList(self.handle, attr_name, v, n)
end

--- Returns the length (number of tensors) of the input argument `input_name`
--- found in the provided `op`.
---@param input_name string
function M:getInputLength(input_name)
    local s = Status()
    local ret = lib.TFE_OpGetInputLength(self.handle, input_name, handle(s))
    s:assert()
    return tonumber(ret)
end

--- Returns the length (number of tensors) of the output argument `output_name`
--- found in the provided `op`.
---@param output_name string
function M:getOutputLength(output_name)
    local s = Status()
    local ret = lib.TFE_OpGetOutputLength(self.handle, output_name, handle(s))
    s:assert()
    return tonumber(ret)
end

--- Execute the operation defined by 'op' and return handles to computed
--- tensors in `retvals`.
---
--- 'retvals' must point to a pre-allocated array of TFE_TensorHandle* and
--- '*num_retvals' should be set to the size of this array. It is an error if
--- the size of 'retvals' is less than the number of outputs. This call sets
--- *num_retvals to the number of outputs.
---
--- If async execution is enabled, the call may simply enqueue the execution
--- and return "non-ready" handles in `retvals`. Note that any handles contained
--- in 'op' should not be mutated till the kernel execution actually finishes.
---
--- For sync execution, if any of the inputs to `op` are not ready, this call
--- will block till they become ready and then return when the kernel execution
--- is done.
--- TODO(agarwal): change num_retvals to int from int*.
---@return tfe.TFETensorHandle[]
function M:execute()
    local n = 8 -- max num_retvals TODO: check
    local retvals = ffi.new('TFE_TensorHandle*[?]', n)
    local num_retvals = ffi.new('int[1]', n)
    local s = Status()
    lib.TFE_Execute(self.handle, retvals, num_retvals, handle(s))
    s:assert()
    local num = num_retvals[0]
    if num == 0 then
        return {}
    else
        local ret = {}
        for i = 1, num do
            ret[i] = require('tf.c.TFETensorHandle')(retvals[i - 1])
        end
        return ret
    end
end

--

function M:inferShapes(input_shapes_vec, input_tensors)
    local input_shapes = libex.TF_NewShapeAndTypeList(#input_shapes_vec)
    for i = 1, #input_shapes_vec do
        local input_shape = input_shapes_vec[i]
        if input_shape and #input_shapes_vec > 0 then
            local v, n = base.packDims(input_shape)
            libex.TF_ShapeAndTypeListSetShape(input_shapes, i - 1, v, n)
        else
            libex.TF_ShapeAndTypeListSetUnknownShape(input_shapes, i - 1)
        end
    end
    local output_shapes = ffi.new('TF_ShapeAndTypeList*[1]')
    local input_tensors_
    if input_tensors and #input_tensors > 0 then
        assert(#input_tensors == #input_shapes_vec)
        input_tensors_ = base.packHandles('TF_Tensor*', input_tensors)
    end
    local s = Status()
    libex.TFE_InferShapes(self.handle, input_shapes, input_tensors_, nil, nil, output_shapes, nil, handle(s))
    s:assert()
    output_shapes = output_shapes[0]
    local num_items = output_shapes.num_items
    local shapes, dtypes = {}, {}
    for i = 1, num_items do
        -- TF_ShapeAndType
        local item = output_shapes.items[i - 1]
        if item.num_dims == -1 then
            shapes[i] = false
        else
            shapes[i] = base.unpackDims(item.dims, item.num_dims)
        end
        if item.dtype == 0 then
            dtypes[i] = false
        else
            dtypes[i] = item.dtype
        end
    end
    return shapes, dtypes
end

--- Resets `op_to_reset` with `op_or_function_name` and `raw_device_name`. This
--- is for performance optimization by reusing an exiting unused op rather than
--- creating a new op every time. If `raw_device_name` is `NULL` or empty, it
--- does not set the device name. If it's not `NULL`, then it attempts to parse
--- and set the device name. It's effectively `TFE_OpSetDevice`, but it is faster
--- than separately calling it because if the existing op has the same
--- `raw_device_name`, it skips parsing and just leave as it is.
function M:reset(op_or_function_name, raw_device_name)
    local s = Status()
    libeex.TFE_OpReset(self.handle, op_or_function_name, raw_device_name, handle(s))
    s:assert()
end

--- Does not overwrite or update existing attributes, but adds new ones.
function M:addAttrsFrom(other)
    libeex.TFE_OpAddAttrs(self.handle, self._attr_handle)
end

--- Serialize `attrs` as a tensorflow::NameAttrList protocol buffer (into `buf`),
--- containing the op name and a map of its attributes.
function M:serialize()
    local buf = require('tf.c.TFBuffer')()
    local s = Status()
    libeex.TFE_OpAttrsSerialize(self._attr_handle, handle(buf), handle(s))
    s:assert()
    return buf
end

--- Set an op's attribute from a serialized AttrValue protocol buffer.
---
--- Analogous to TF_SetAttrValueProto for building graph operations.
function M:setAttrValueProto(attr_name, proto, proto_len)
    local s = Status()
    libeex.TFE_OpSetAttrValueProto(self.handle, attr_name, proto, proto_len, handle(s))
    s:assert()
end

--

function M.NewOp(ctx, op_or_function_name)
    local s = Status()
    local hdl = lib.TFE_NewOp(handle(ctx), op_or_function_name, handle(s))
    s:assert()
    if ffi.isnullptr(hdl) then
        return nil
    end
    return M(hdl)
end

return M
