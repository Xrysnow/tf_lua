---@class tf.TFOperation
--- Operation that has been added to the graph. Valid until the graph is
--- deleted -- in particular adding a new operation to the graph does not
--- invalidate old TF_Operation* pointers.
local M = class('tf.TFOperation')
local base = require('tf.base')
local lib = base._lib
local libex = base._libex
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(not ffi.isnullptr(hdl))
    self.handle = hdl
    self._outputListLength = {}
    self._inputListLength = {}
end

function M:name()
    ---@type string
    self._name = self._name or ffi.string(lib.TF_OperationName(self.handle))
    return self._name
end

function M:opType()
    ---@type string
    self._opType = self._opType or ffi.string(lib.TF_OperationOpType(self.handle))
    return self._opType
end

function M:getDevice()
    ---@type string
    self._device = self._device or ffi.string(lib.TF_OperationDevice(self.handle))
    return self._device ~= '' and self._device or nil
end

function M:numOutputs()
    ---@type number
    self._numOutputs = self._numOutputs or lib.TF_OperationNumOutputs(self.handle)
    return self._numOutputs
end

function M:outputListLength(arg_name)
    if not self._outputListLength[arg_name] then
        local s = Status()
        self._outputListLength[arg_name] = lib.TF_OperationOutputListLength(self.handle, handle(s))
        s:assert()
    end
    return self._outputListLength[arg_name]
end

function M:numInputs()
    ---@type number
    self._numInputs = self._numInputs or lib.TF_OperationNumInputs(self.handle)
    return self._numInputs
end

function M:inputListLength(arg_name)
    if not self._inputListLength[arg_name] then
        local s = Status()
        self._inputListLength[arg_name] = lib.TF_OperationInputListLength(self.handle, handle(s))
        s:assert()
    end
    return self._inputListLength[arg_name]
end
--- Get list of all inputs of a specific operation.  `inputs` must point to
--- an array of length at least `max_inputs` (ideally set to
--- TF_OperationNumInputs(oper)).  Beware that a concurrent
--- modification of the graph can increase the number of inputs of
--- an operation.
---@return tf.TFOutput[]
function M:allInputs()
    local n = self:numInputs()
    -- will be destructed
    local inputs = ffi.new('TF_Output[?]', n)
    lib.TF_OperationAllInputs(self.handle, inputs, n)
    local ret = {}
    for i = 1, n do
        local hdl = ffi.new('TF_Output[1]')
        hdl[0] = inputs[i - 1]
        ret[i] = require('tf.c.TFOutput')(hdl)
    end
    return ret
end
--- Get the number of control inputs to an operation.
function M:numControlInputs()
    ---@type number
    self._numControlInputs = self._numControlInputs or lib.TF_OperationNumControlInputs(self.handle)
    return self._numControlInputs
end
--- Get list of all control inputs to an operation.  `control_inputs` must
--- point to an array of length `max_control_inputs` (ideally set to
--- TF_OperationNumControlInputs(oper)).  Returns the number of control
--- inputs (should match TF_OperationNumControlInputs(oper)).
---@return tf.TFOperation[]
function M:getControlInputs()
    local n = self:numControlInputs()
    local control_inputs = ffi.new('TF_Operation*[?]', n)
    lib.TF_OperationGetControlInputs(self.handle, control_inputs, n)
    local ret = {}
    for i = 1, n do
        ret[i] = M(control_inputs[i - 1])
    end
    return ret
end
--- Get the number of operations that have `*oper` as a control input.
--- Note that this number can change when new operations are added to
--- the graph.
---@return number
function M:numControlOutputs()
    -- this number can change when new operations are added to the graph
    return tonumber(lib.TF_OperationNumControlOutputs(self.handle))
end
--- Get the list of operations that have `*oper` as a control input.
--- `control_outputs` must point to an array of length at least
--- `max_control_outputs` (ideally set to
--- TF_OperationNumControlOutputs(oper)). Beware that a concurrent
--- modification of the graph can increase the number of control
--- outputs.  Returns the number of control outputs (should match
--- TF_OperationNumControlOutputs(oper)).
---@return tf.TFOperation[]
function M:getControlOutputs()
    local n = self:numControlInputs()
    local control_outputs = ffi.new('TF_Operation*[?]', n)
    lib.TF_OperationGetControlOutputs(self.handle, control_outputs, n)
    local ret = {}
    for i = 1, n do
        ret[i] = M(control_outputs[i - 1])
    end
    return ret
end
--- Returns metadata about the value of the attribute `attr_name` of `oper`.
---@param attr_name string
function M:getAttrMetadata(attr_name)
    local s = Status()
    local ret = lib.TF_OperationGetAttrMetadata(self.handle, attr_name, handle(s))
    s:assert()
    return ret
end
--- Fills in `value` with the value of the attribute `attr_name`.  `value` must
--- point to an array of length at least `max_length` (ideally set to
--- TF_AttrMetadata.total_size from TF_OperationGetAttrMetadata(oper,
--- attr_name)).
---@param attr_name string
---@return ffi.cdata, number @char[?], int64_t
function M:getAttrString(attr_name)
    local meta = self:getAttrMetadata(attr_name)
    local value_size = meta.total_size
    local value = ffi.new('char[?]', value_size)
    local s = Status()
    lib.TF_OperationGetAttrString(self.handle, attr_name, value, value_size, handle(s))
    s:assert()
    return value, value_size
end

---@param attr_name string
function M:getAttrStringList(attr_name)
    local meta = self:getAttrMetadata(attr_name)
    assert(meta.is_list == 1)
    local list_size = meta.list_size
    local total_size = meta.total_size
    local values = ffi.new('void*[?]', list_size)
    local lengths = ffi.new('size_t[?]', list_size)
    local storage = ffi.new('char[?]', total_size)
    local s = Status()
    lib.TF_OperationGetAttrStringList(self.handle, attr_name, values, lengths, list_size, storage, total_size, handle(s))
    s:assert()
    return storage, total_size, values, lengths
end

function M:getAttrInt(attr_name)
    local value = ffi.new('int64_t[1]')
    local s = Status()
    lib.TF_OperationGetAttrInt(self.handle, attr_name, value, handle(s))
    s:assert()
    return value[0]
end

function M:getAttrIntList(attr_name)
    local meta = self:getAttrMetadata(attr_name)
    assert(meta.is_list == 1)
    local value_size = meta.list_size
    local values = ffi.new('int64_t[?]', value_size)
    local s = Status()
    lib.TF_OperationGetAttrIntList(self.handle, attr_name, values, value_size, handle(s))
    s:assert()
    return values, value_size
end

function M:getAttrFloat(attr_name)
    local value = ffi.new('float[1]')
    local s = Status()
    lib.TF_OperationGetAttrFloat(self.handle, attr_name, value, handle(s))
    s:assert()
    return value[0]
end

function M:getAttrFloatList(attr_name)
    local meta = self:getAttrMetadata(attr_name)
    assert(meta.is_list == 1)
    local value_size = meta.list_size
    local values = ffi.new('float[?]', value_size)
    local s = Status()
    lib.TF_OperationGetAttrFloatList(self.handle, attr_name, values, value_size, handle(s))
    s:assert()
    return values, value_size
end

function M:getAttrBool(attr_name)
    local value = ffi.new('unsigned char[1]')
    local s = Status()
    lib.TF_OperationGetAttrBool(self.handle, attr_name, value, handle(s))
    s:assert()
    return value[0]
end

function M:getAttrBoolList(attr_name)
    local meta = self:getAttrMetadata(attr_name)
    assert(meta.is_list == 1)
    local value_size = meta.list_size
    local values = ffi.new('unsigned char[?]', value_size)
    local s = Status()
    lib.TF_OperationGetAttrBoolList(self.handle, attr_name, values, value_size, handle(s))
    s:assert()
    return values, value_size
end

function M:getAttrType(attr_name)
    local value = ffi.new('TF_DataType[1]')
    local s = Status()
    lib.TF_OperationGetAttrType(self.handle, attr_name, value, handle(s))
    s:assert()
    return value[0]
end

function M:getAttrTypeList(attr_name)
    local meta = self:getAttrMetadata(attr_name)
    assert(meta.is_list == 1)
    local value_size = meta.list_size
    local values = ffi.new('TF_DataType[?]', value_size)
    local s = Status()
    lib.TF_OperationGetAttrTypeList(self.handle, attr_name, values, value_size, handle(s))
    s:assert()
    return values, value_size
end

function M:getAttrShape(attr_name)
    local meta = self:getAttrMetadata(attr_name)
    assert(meta.is_list == 0)
    local ndim = meta.total_size
    assert(ndim ~= -1, ('unknown shape for %q'):format(attr_name))
    if ndim == 0 then
        -- scalar
        return {}
    end
    local value = ffi.new('int64_t[?]', ndim)
    local s = Status()
    lib.TF_OperationGetAttrShape(self.handle, attr_name, value, ndim, handle(s))
    s:assert()
    return base.unpackDims(value, ndim)
end

function M:getAttrShapeList(attr_name)
    local meta = self:getAttrMetadata(attr_name)
    assert(meta.is_list == 1)
    local list_size = meta.list_size
    local total_size = meta.total_size
    local values = ffi.new('int64_t*[?]', list_size)
    local lengths = ffi.new('int[?]', list_size)
    local storage = ffi.new('int64_t[?]', total_size)
    local s = Status()
    lib.TF_OperationGetAttrShapeList(self.handle, attr_name, values, lengths, list_size, storage, total_size, handle(s))
    s:assert()
    local ret = {}
    for i = 1, list_size do
        ret[i] = base.unpackDims(values[i - 1], lengths[i - 1])
    end
    return ret
end
--- Sets `value` to the binary-serialized TensorShapeProto of the value of
--- `attr_name` attribute of `oper`'.
---@param attr_name string
function M:getAttrTensorShapeProto(attr_name)
    local value = require('tf.c.TFBuffer')()
    local s = Status()
    lib.TF_OperationGetAttrTensorShapeProto(self.handle, attr_name, handle(value), handle(s))
    s:assert()
    return value
end
--- Fills in `values` with binary-serialized TensorShapeProto values of the
--- attribute `attr_name` of `oper`. `values` must point to an array of length at
--- least `num_values` (ideally set to TF_AttrMetadata.list_size from
--- TF_OperationGetAttrMetadata(oper, attr_name)).
---@param attr_name string
---@return tf.TFBuffer[]
function M:getAttrTensorShapeProtoList(attr_name)
    local meta = self:getAttrMetadata(attr_name)
    assert(meta.is_list == 1)
    local value_size = meta.list_size
    local values = ffi.new('TF_Buffer*[?]', value_size)
    local s = Status()
    lib.TF_OperationGetAttrTensorShapeProtoList(self.handle, attr_name, values, value_size, handle(s))
    s:assert()
    local ret = {}
    for i = 1, value_size do
        ret[i] = require('tf.c.TFBuffer')(values[i - 1])
    end
    return ret
end
--- Gets the TF_Tensor valued attribute of `attr_name` of `oper`.
---
--- Allocates a new TF_Tensor which the caller is expected to take
--- ownership of (and can deallocate using TF_DeleteTensor).
---@param attr_name string
---@return tf.TFTensor
function M:getAttrTensor(attr_name)
    local value = ffi.new('TF_Tensor*[1]')
    local s = Status()
    lib.TF_OperationGetAttrTensor(self.handle, attr_name, value, handle(s))
    s:assert()
    return require('tf.c.TFTensor')(value[0])
end
--- Fills in `values` with the TF_Tensor values of the attribute `attr_name` of
--- `oper`. `values` must point to an array of TF_Tensor* of length at least
--- `max_values` (ideally set to TF_AttrMetadata.list_size from
--- TF_OperationGetAttrMetadata(oper, attr_name)).
---
--- The caller takes ownership of all the non-null TF_Tensor* entries in `values`
--- (which can be deleted using TF_DeleteTensor(values[i])).
---@param attr_name string
---@return tf.TFTensor[]
function M:getAttrTensorList(attr_name)
    local meta = self:getAttrMetadata(attr_name)
    assert(meta.is_list == 1)
    local value_size = meta.list_size
    local values = ffi.new('TF_Tensor*[?]', value_size)
    local s = Status()
    lib.TF_OperationGetAttrTensorList(self.handle, attr_name, values, value_size, handle(s))
    s:assert()
    local ret = {}
    for i = 1, value_size do
        ret[i] = require('tf.c.TFTensor')(values[i - 1])
    end
    return ret
end
--- Sets `output_attr_value` to the binary-serialized AttrValue proto
--- representation of the value of the `attr_name` attr of `oper`.
---@param attr_name string
function M:getAttrValueProto(attr_name)
    local value = require('tf.c.TFBuffer')()
    local s = Status()
    lib.TF_OperationGetAttrValueProto(self.handle, attr_name, handle(value), handle(s))
    s:assert()
    return value
end
--- Note: The following function may fail on very large protos in the future.
function M:toNodeDef()
    local s = Status()
    local out = require('tf.c.TFBuffer')()
    lib.TF_OperationToNodeDef(self.handle, handle(out), handle(s))
    s:assert()
    return out
end

function M:isStateful()
    return M.OpIsStateful(self:opType())
end

--

---@return tf.TFInput[]
function M:getInputs()
    local n = self:numInputs()
    local inputs = {}
    for i = 1, n do
        local input = require('tf.c.TFInput')()
        input:oper(self)
        input:index(i - 1)
        inputs[i] = input
    end
    return inputs
end

---@return tf.TFOutput[]
function M:getOutputs()
    local n = self:numOutputs()
    local outputs = {}
    for i = 1, n do
        local output = require('tf.c.TFOutput')()
        output:oper(self)
        output:index(i - 1)
        outputs[i] = output
    end
    return outputs
end

--

--- For argument number input_index, fetch the corresponding number_attr that
--- needs to be updated with the argument length of the input list.
--- Returns nullptr if there is any problem like op_name is not found, or the
--- argument does not support this attribute type.
---@param op_name string
---@param input_index number
function M.GetNumberAttrForOpListInput(op_name, input_index)
    local s = Status()
    local p = libex.TF_GetNumberAttrForOpListInput(op_name, input_index, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return ffi.string(p)
end

--- Returns 1 if the op is stateful, 0 otherwise. The return value is undefined
--- if the status is not ok.
---@param op_type string
function M.OpIsStateful(op_type)
    local s = Status()
    local ret = libex.TF_OpIsStateful(op_type, handle(s))
    s:assert()
    return ret > 0
end

return M
