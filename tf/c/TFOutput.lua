---@class tf.TFOutput
--- Represents a specific output of an operation.
local M = class('tf.TFOutput')
local lib = require('tf.c._c_api')

function M:ctor(hdl)
    self.handle = hdl or ffi.new('TF_Output[1]')
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
    return lib.TF_OperationOutputType(self.handle[0])
end

function M:typeString()
    return require('tf.base').dataTypeString(self:type())
end
--- Get the number of current consumers of a specific output of an
--- operation.  Note that this number can change when new operations
--- are added to the graph.
---@return number
function M:numConsumers()
    return tonumber(lib.TF_OperationOutputNumConsumers(self.handle[0]))
end
--- Get list of all current consumers of a specific output of an
--- operation.  `consumers` must point to an array of length at least
--- `max_consumers` (ideally set to
--- TF_OperationOutputNumConsumers(oper_out)).  Beware that a concurrent
--- modification of the graph can increase the number of consumers of
--- an operation.  Returns the number of output consumers (should match
--- TF_OperationOutputNumConsumers(oper_out)).
---@return tf.TFInput[]
function M:consumers()
    local n = self:numConsumers()
    local consumers = ffi.new('TF_Input[?]', n)
    lib.TF_OperationOutputConsumers(self.handle[0], consumers, n)
    local ret = {}
    for i = 1, n do
        local hdl = ffi.new('TF_Input[1]')
        hdl[0] = consumers[i - 1]
        ret[i] = require('tf.c.TFInput')(hdl)
    end
    return ret
end

function M.pack(obj_arr)
    local n = #obj_arr
    if n == 0 then
        return nil
    end
    local ret = ffi.new('TF_Output[?]', n)
    for i = 1, n do
        local item = obj_arr[i]
        if type(item) == 'cdata' then
            ret[i - 1] = item[0]
        else
            ret[i - 1] = item.handle[0]
        end
    end
    return ret
end
---@return tf.TFOutput[]
function M.unpack(c_arr, length)
    if length == 0 then
        return {}
    end
    local ret = {}
    for i = 1, length do
        local hdl = ffi.new('TF_Output[1]')
        hdl[0] = c_arr[i - 1]
        ret[i] = M(hdl)
    end
    return ret
end

---@param oper tf.TFOperation
---@param index number
function M.Create(oper, index)
    local ret = M()
    ret:oper(oper)
    ret:index(index)
    return ret
end

return M
