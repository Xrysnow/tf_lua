---@class tf.TFApiDefMap
--- TF_ApiDefMap encapsulates a collection of API definitions for an operation.
---
--- This object maps the name of a TensorFlow operation to a description of the
--- API to generate for it, as defined by the ApiDef protocol buffer (
--- https://www.tensorflow.org/code/tensorflow/core/framework/api_def.proto)
---
--- The ApiDef messages are typically used to generate convenience wrapper
--- functions for TensorFlow operations in various language bindings.
local M = class('tf.TFApiDefMap')
local lib = require('tf.c._c_api')
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end
--- Deallocates a TF_ApiDefMap.
function M:dtor()
    lib.TF_DeleteApiDefMap(self.handle)
    self.handle = nil
end
--- Add ApiDefs to the map.
---
--- `text` corresponds to a text representation of an ApiDefs protocol message.
--- (https://www.tensorflow.org/code/tensorflow/core/framework/api_def.proto).
---
--- The provided ApiDefs will be merged with existing ones in the map, with
--- precedence given to the newly added version in case of conflicts with
--- previous calls to TF_ApiDefMapPut.
---@param text string
function M:put(text)
    local s = Status()
    lib.TF_ApiDefMapPut(self.handle, text, #text, handle(s))
    s:assert()
end
--- Returns a serialized ApiDef protocol buffer for the TensorFlow operation
--- named `name`.
---@param name string
function M:get(name)
    local s = Status()
    local p = lib.TF_ApiDefMapGet(self.handle, name, #name, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return require('tf.c.TFBuffer')(p)
end
--- Creates a new TF_ApiDefMap instance.
---
--- Params:
---  op_list_buffer - TF_Buffer instance containing serialized OpList
---    protocol buffer. (See
---    https://www.tensorflow.org/code/tensorflow/core/framework/op_def.proto
---    for the OpList proto definition).
---  status - Set to OK on success and an appropriate error on failure.
---@param op_list_buffer tf.TFBuffer
function M.NewApiDefMap(op_list_buffer)
    local s = Status()
    local p = lib.TF_NewApiDefMap(handle(op_list_buffer), handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

return M
