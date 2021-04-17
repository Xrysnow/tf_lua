---@class tf.TFWhileParams
local M = class('tf.TFWhileParams')
local lib = require('tf.c._c_api')
local Status = require('tf.c.TFStatus')
local Output = require('tf.c.TFOutput')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end

function M:dtor()
    self:abort()
end
--- The number of inputs to the while loop, i.e. the number of loop variables.
--- This is the size of cond_inputs, body_inputs, and body_outputs.
function M:ninputs()
    return tonumber(self.handle[0].ninputs)
end
--- The while condition graph. The inputs are the current values of the loop
--- variables. The output should be a scalar boolean.
function M:cond_graph()
    return require('tf.c.TFGraph')(self.handle[0].cond_graph)
end
--- The loop body graph. The inputs are the current values of the loop
--- variables. The outputs are the updated values of the loop variables.
function M:body_graph()
    return require('tf.c.TFGraph')(self.handle[0].body_graph)
end
--- Unique null-terminated name for this while loop. This is used as a prefix
--- for created operations.
function M:name()
    return ffi.string(self.handle[0].name)
end
--- Builds the while loop specified by `params` and returns the output tensors of
--- the while loop in `outputs`. `outputs` should be allocated to size
--- `params.ninputs`.
---
--- `params` is no longer valid once this returns.
---
--- Either this or TF_AbortWhile() must be called after a successful
--- TF_NewWhile() call.
function M:finish()
    local n = self:ninputs()
    local outputs = ffi.new('TF_Output[?]', n)
    local s = Status()
    lib.TF_FinishWhile(self.handle, handle(s), outputs)
    local ret = Output.unpack(outputs, n)
    self.handle = nil
    return ret
end
--- Frees `params`s resources without building a while loop. `params` is no
--- longer valid after this returns. Either this or TF_FinishWhile() must be
--- called after a successful TF_NewWhile() call.
function M:abort()
    lib.TF_AbortWhile(self.handle)
    self.handle = nil
end
--- Creates a TF_WhileParams for creating a while loop in `g`. `inputs` are
--- outputs that already exist in `g` used as initial values for the loop
--- variables.
---
--- The returned TF_WhileParams will have all fields initialized except
--- `cond_output`, `body_outputs`, and `name`. The `body_outputs` buffer will be
--- allocated to size `ninputs`. The caller should build `cond_graph` and
--- `body_graph` starting from the inputs, and store the final outputs in
--- `cond_output` and `body_outputs`.
---
--- If `status` is OK, the caller must call either TF_FinishWhile or
--- TF_AbortWhile on the returned TF_WhileParams. If `status` isn't OK, the
--- returned TF_WhileParams is not valid, and the caller should not call
--- TF_FinishWhile() or TF_AbortWhile().
---
--- Missing functionality (TODO):
--- - Gradients
--- - Reference-type inputs
--- - Directly referencing external tensors from the cond/body graphs (this is
---   possible in the Python API)
---@param graph tf.TFGraph
---@param inputs tf.TFOutput[]
function M.NewWhile(graph, inputs)
    local hdl = ffi.new('TF_WhileParams[1]')
    local inputs_ = Output.pack(inputs)
    local s = Status()
    hdl[0] = lib.TF_NewWhile(handle(graph), inputs_, #inputs, handle(s))
    s:assert()
    return M(hdl)
end

return M
