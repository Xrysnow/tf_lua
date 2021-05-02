---@class tf.AbstractOperation
local M = class('tf.AbstractOperation')

function M:kind()
    return self._kind
end

local function unimplemented()
    error('unimplemented abstract method')
end

function M:reset(op_or_function_name, raw_device_name)
    unimplemented()
end

function M:name()
    unimplemented()
end

function M:setDevice(device_name)
    unimplemented()
end

function M:getDevice()
    unimplemented()
end

function M:addInput(input)
    unimplemented()
end

function M:addInputList(inputs)
    unimplemented()
end

function M:execute()
    unimplemented()
end

function M:setAttrString(attr_name, value, length)
    unimplemented()
end

function M:setAttrInt(attr_name, value)
    unimplemented()
end

function M:setAttrFloat(attr_name, value)
    unimplemented()
end

function M:setAttrBool(attr_name, value)
    unimplemented()
end

function M:setAttrType(attr_name, value)
    unimplemented()
end

function M:setAttrShape(attr_name, dims)
    unimplemented()
end

function M:setAttrFunction(attr_name, value)
    unimplemented()
end

function M:setAttrFunctionName(attr_name, value)
    unimplemented()
end

function M:setAttrTensor(attr_name, tensor)
    unimplemented()
end

function M:setAttrStringList(attr_name, values, lengths, num_values)
    unimplemented()
end

function M:setAttrIntList(attr_name, values)
    unimplemented()
end

function M:setAttrFloatList(attr_name, values)
    unimplemented()
end

function M:setAttrBoolList(attr_name, values)
    unimplemented()
end

function M:setAttrTypeList(attr_name, values)
    unimplemented()
end

function M:setAttrShapeList(attr_name, dims)
    unimplemented()
end

function M:setAttrFunctionList(attr_name, values)
    unimplemented()
end

return M
