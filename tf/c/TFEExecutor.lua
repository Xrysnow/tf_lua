---@class tf.TFEExecutor
--- Eager Executor APIs.
local M = class('tf.TFEExecutor')
local base = require('tf.base')
local lib = base._libeagerex
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end

--- Deletes the eager Executor without waiting for enqueued nodes. Please call
--- TFE_ExecutorWaitForAllPendingNodes before calling this API if you want to
--- make sure all nodes are finished.
function M:dtor()
    lib.TFE_DeleteExecutor(self.handle)
    self.handle = nil
end

--- Returns true if the executor is in async mode.
function M:isAsync()
    return lib.TFE_ExecutorIsAsync(self.handle)
end

--- Causes the calling thread to block till all ops dispatched in this executor
--- have been executed. Note that "execution" here refers to kernel execution /
--- scheduling of copies, etc. Similar to sync execution, it doesn't guarantee
--- that lower level device queues (like GPU streams) have been flushed.
---
--- This call may not block for execution of ops enqueued concurrently with this
--- call.
function M:waitForAllPendingNodes()
    local s = Status()
    lib.TFE_ExecutorIsAsync(self.handle, handle(s))
    s:assert()
end

--- When an error happens, any pending operations are discarded and newly issued
--- ops return an error. This call clears the error state and re-enables
--- execution of newly issued ops.
---
--- Note that outputs of discarded ops remain in a corrupt state and should not
--- be used for future calls.
--- TODO(agarwal): mark the affected handles and raise errors if they are used.
function M:clearError()
    return lib.TFE_ExecutorClearError(self.handle)
end

--- Creates a new eager Executor. Nodes in one executor are guaranteed to be
--- executed in sequence. Assigning nodes to different executors allows executing
--- nodes in parallel.
---@param is_async boolean
function M.Create(is_async)
    local p = lib.TFE_NewExecutor(is_async)
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

return M
