---@class tf.TFInput
--- Represents a specific input of an operation.
local M = class('tf.TFInput')
local lib = require('tf.c._c_api')

function M:ctor(hdl)
    self.handle = hdl or ffi.new('TF_Input[1]')
end

function M:oper(value)
    if value then
        self.handle[0].oper = handle(value)
    else
        if ffi.isnullptr(self.handle[0].oper) then
            return nil
        else
            return require('tf.c.TFOperation')(self.handle[0].oper)
        end
    end
end

function M:index(value)
    if value then
        self.handle[0].index = value
    else
        return self.handle[0].index
    end
end

function M:type()
    return lib.TF_OperationInputType(self.handle[0])
end

function M:typeString()
    return require('tf.base').dataTypeString(self:type())
end
--- In this code:
---
---   TF_Output producer = TF_OperationInput(consumer);
---
--- There is an edge from producer.oper's output (given by
--- producer.index) to consumer.oper's input (given by consumer.index).
function M:input()
    local hdl = ffi.new('TF_Output[1]')
    hdl[0] = lib.TF_OperationInput(self.handle[0])
    return require('tf.c.TFOutput')(hdl)
end

return M
