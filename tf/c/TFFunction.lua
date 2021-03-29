---@class tf.TFFunction
--- TF_Function is a grouping of operations with defined inputs and outputs.
--- Once created and added to graphs, functions can be invoked by creating an
--- operation whose operation type matches the function name.
local M = class('tf.TFFunction')
local lib = require('tf.c._c_api')
local libex = require('tf.c._c_api_experimental')
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end
--- Frees the memory used by the `func` struct.
--- TF_DeleteFunction is a noop if `func` is null.
--- Deleting a function does not remove it from any graphs it was copied to.
function M:dtor()
    lib.TF_DeleteFunction(self.handle)
end
--- Returns the name of the graph function.
--- The return value points to memory that is only usable until the next
--- mutation to *func.
---@return string
function M:name()
    return ffi.string(lib.TF_FunctionName(self.handle))
end
--- Write out a serialized representation of `func` (as a FunctionDef protocol
--- message) to `output_func_def` (allocated by TF_NewBuffer()).
--- `output_func_def`'s underlying buffer will be freed when TF_DeleteBuffer()
--- is called.
---
--- May fail on very large graphs in the future.
function M:toFunctionDef()
    local out = require('tf.c.TFBuffer')()
    local s = Status()
    lib.TF_FunctionToFunctionDef(self.handle, handle(out), handle(s))
    s:assert()
    return out
end
--- Sets function attribute named `attr_name` to value stored in `proto`.
--- If this attribute is already set to another value, it is overridden.
--- `proto` should point to a sequence of bytes of length `proto_len`
--- representing a binary serialization of an AttrValue protocol
--- buffer.
function M:setAttrValueProto(attr_name, proto, proto_len)
    local s = Status()
    lib.TF_FunctionSetAttrValueProto(self.handle, attr_name, proto, proto_len, handle(s))
    s:assert()
end
--- Sets `output_attr_value` to the binary-serialized AttrValue proto
--- representation of the value of the `attr_name` attr of `func`.
--- If `attr_name` attribute is not present, status is set to an error.
function M:getAttrValueProto(attr_name)
    local out = require('tf.c.TFBuffer')()
    local s = Status()
    lib.TF_FunctionGetAttrValueProto(self.handle, attr_name, handle(out), handle(s))
    s:assert()
    return out
end
--- Construct and return the function whose FunctionDef representation is
--- serialized in `proto`. `proto_len` must equal the number of bytes
--- pointed to by `proto`.
--- Returns:
---  On success, a newly created TF_Function instance. It must be deleted by
---  calling TF_DeleteFunction.
---
---  On failure, null.
function M.ImportFunctionDef(proto, proto_len)
    local s = Status()
    local p = lib.TF_FunctionImportFunctionDef(proto, proto_len, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

function M:debugString()
    local len = ffi.new('size_t[1]')
    local p = libex.TF_FunctionDebugString(self.handle, len)
    local s = ffi.string(p, len[0])
    ffi.C.free(p)
    return s
end

return M
