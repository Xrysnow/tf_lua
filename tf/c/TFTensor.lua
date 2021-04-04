---@class tf.TFTensor
local M = class('tf.TFTensor')
local lib = require('tf.c._c_api')
local base = require('tf.base')
local packDims = base.packDims
local TF_DataType = require('tf._enum').TF_DataType

function M:ctor(hdl)
    assert(not ffi.isnullptr(hdl))
    self.handle = hdl
end

function M:dtor()
    lib.TF_DeleteTensor(self.handle)
    self.handle = nil
    self['.data'] = nil
end

function M:maybeMove()
    local hdl = lib.TF_TensorMaybeMove(self.handle)
    if ffi.isnullptr(hdl) then
        return nil
    end
    self.handle = nil
    self['.data'] = nil
    return M(hdl)
end

function M:type()
    return lib.TF_TensorType(self.handle)
end

function M:dtype()
    return self:type()
end

function M:typeString()
    return base.dataTypeString(self:type())
end

function M:numDims()
    return tonumber(lib.TF_NumDims(self.handle))
end

function M:dim(dim_index)
    return lib.TF_Dim(self.handle, dim_index)
end

function M:byteSize()
    return lib.TF_TensorByteSize(self.handle)
end

function M:data()
    return lib.TF_TensorData(self.handle)
end

function M:elementCount()
    return lib.TF_TensorElementCount(self.handle)
end

function M:bitcastFrom(from, type, new_dims)
    from = handle(from)
    local dims, num_dims = packDims(new_dims)
    local s = require('tf.c.TFStatus')()
    lib.TF_TensorBitcastFrom(from, type, self.handle, dims, num_dims, handle(s))
    s:assert()
end

function M:isAligned()
    return lib.TF_TensorIsAligned(self.handle)
end

function M.AllocateTensor(type_, dims, len)
    local num_dims = 0
    -- dims can be NULL
    if dims then
        dims, num_dims = packDims(dims)
    end
    local handle = lib.TF_AllocateTensor(type_, dims, num_dims, len)
    if ffi.isnullptr(handle) then
        return nil
    end
    return M(handle)
end

local function _def_deallocator()
end

function M.NewTensor(type_, dims, data, len, deallocator)
    local num_dims = 0
    -- dims can be NULL
    if dims then
        dims, num_dims = packDims(dims)
    end
    deallocator = deallocator or _def_deallocator
    local handle = lib.TF_NewTensor(type_, dims, num_dims, data, len, deallocator, nil)
    if ffi.isnullptr(handle) then
        return nil
    end
    return M(handle)
end

--

function M.Create(type_, dims, len)
    if dims then
        if #dims == 0 then
            dims = nil
        else
            assert(type(dims) == 'table')
        end
    end
    type_ = base.dataType(type_)
    local type_size = base.DataTypeSize(type_)
    local expect_len = dims and table.prod(dims) * type_size or len
    if len then
        assert(len == expect_len)
    else
        len = expect_len
    end
    local ret = M.AllocateTensor(type_, dims, len)
    return ret
end

function M.CreateFromCdata(type_, dims, data, len)
    assert(type(data) == 'cdata')
    if dims then
        assert(type(dims) == 'table' and #dims > 0)
    end
    type_ = base.dataType(type_)
    local type_size = base.DataTypeSize(type_)
    local expect_len = dims and table.prod(dims) * type_size or len
    if len then
        assert(len == expect_len)
    else
        len = expect_len
    end
    local hold_data = true
    local function deallocator()
        hold_data = false
    end
    local ret = M.NewTensor(type_, dims, data, len, deallocator)
    if hold_data then
        ret['.data'] = data
    end
    return ret
end

function M.CreateScalarString(s)
    local tstring = require('tf.c.TFTString').Create(s)
    local ret = M.NewTensor(TF_DataType.STRING, nil, tstring, 1)
    ret['.data'] = tstring
    return ret
end
---@return tf.TFTensor
function M.Scalar(value, dtype)
    local ty = type(value)
    local tensor
    if ty == 'string' then
        tensor = require('tf.c.TFTensor').CreateScalarString(value)
    elseif ty == 'number' or ty == 'boolean' or ty == 'cdata' then
        if ty == 'boolean' then
            dtype = 'bool'
            value = value and 1 or 0
        else
            dtype = dtype or 'float'
        end
        dtype = base.dataType(dtype)
        assert(dtype, 'invalid data type')
        local len = base.DataTypeSize(dtype)
        assert(len, 'invalid data type')
        local is_cdata_value = ty == 'cdata' and tonumber(value)
        if ty == 'number' or ty == 'boolean' or is_cdata_value then
            local ctype = base.ctypeFromDataType(dtype)
            assert(ctype, ("invalid data type: %s"):format(dtype))
            local cdata = ffi.new(ctype .. '[1]')
            cdata[0] = value
            value = cdata
        end
        tensor = require('tf.c.TFTensor').CreateFromCdata(dtype, nil, value, len)
    else
        error('invalid parameter')
    end
    return tensor
end

function M.ScalarString(value)
    assert(type(value) == 'string')
    return M.CreateScalarString(value)
end
---@return tf.TFTensor
function M.ScalarBool(value)
    return M.Scalar(value, 'bool')
end
---@return tf.TFTensor
function M.ScalarFloat(value)
    return M.Scalar(value, 'float')
end
---@return tf.TFTensor
function M.ScalarDouble(value)
    return M.Scalar(value, 'double')
end
---@return tf.TFTensor
function M.ScalarInt8(value)
    return M.Scalar(value, 'int8')
end
---@return tf.TFTensor
function M.ScalarUint8(value)
    return M.Scalar(value, 'uint8')
end
---@return tf.TFTensor
function M.ScalarInt16(value)
    return M.Scalar(value, 'int16')
end
---@return tf.TFTensor
function M.ScalarUint16(value)
    return M.Scalar(value, 'uint16')
end
---@return tf.TFTensor
function M.ScalarInt32(value)
    return M.Scalar(value, 'int32')
end
---@return tf.TFTensor
function M.ScalarUint32(value)
    return M.Scalar(value, 'uint32')
end
---@return tf.TFTensor
function M.ScalarInt64(value)
    return M.Scalar(value, 'int64')
end
---@return tf.TFTensor
function M.ScalarUint64(value)
    return M.Scalar(value, 'uint64')
end

return M
