---@class tfe.TFEContext
--- "Context" under which operations/functions are executed. It encapsulates
--- things like the available devices, resource manager etc.
--- TFE_Context must outlive all tensor handles created using it. In other
--- words, TFE_DeleteContext() must be called after all tensor handles have
--- been deleted (with TFE_DeleteTensorHandle).
local M = class('tfe.TFEContext')
local base = require('tf.base')
local lib = base._libeager
local libex = base._libex
local libeex = base._libeagerex
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end

function M:dtor()
    lib.TFE_DeleteContext(self.handle)
    self.handle = nil
end

--- Clears the internal caches in the TFE context. Useful when reseeding random
--- ops.
function M:clearCaches()
    lib.TFE_ContextClearCaches(self.handle)
end

--- Sets a thread-local device placement policy. After this call, other calls to
--- TFE_Execute in the same thread will use the device policy specified here
--- instead of the device policy used to construct the context. This has no
--- effect on the device policy used by other program threads.
function M:setThreadLocalDevicePlacementPolicy(policy)
    lib.TFE_ContextSetThreadLocalDevicePlacementPolicy(
            self.handle, policy)
end

--- Returns the device placement policy to be used by this context in the current
--- thread.
function M:getDevicePlacementPolicy()
    return lib.TFE_ContextGetDevicePlacementPolicy(
            self.handle)
end

--- A tensorflow.ServerDef specifies remote workers (in addition to the current
--- workers name). Operations created on this context can then be executed on
--- any of these remote workers by setting an appropriate device.
---
--- If the following is set, all servers identified by the
--- ServerDef must be up when the context is created.
---@param keep_alive_secs number
---@param proto ffi.cdata
---@param proto_len number
function M:setServerDef(keep_alive_secs, proto, proto_len)
    local s = Status()
    lib.TFE_ContextSetServerDef(
            self.handle, keep_alive_secs, proto, proto_len or #proto, handle(s))
    s:assert()
end

--- Get an attribute type given an op name; a fusion of TFE_NewOp and
--- TFE_OpGetAttrType for use from Python without the overhead of the individual
--- calls and memory management of TFE_Op.
---@param op_or_function_name string
---@param attr_name string
function M:getAttrType(op_or_function_name, attr_name)
    local is_list = ffi.new('unsigned char[1]')
    local s = Status()
    local ret = lib.TFE_OpNameGetAttrType(
            self.handle, op_or_function_name, attr_name, is_list, handle(s))
    s:assert()
    return ret, is_list[0] > 0
end

--- Add a function (serialized FunctionDef protocol buffer) to ctx so
--- that it can be invoked using TFE_Execute.
---@param serialized_function_def string
---@param size number
function M:addFunctionDef(serialized_function_def, size)
    size = size or #serialized_function_def
    local s = Status()
    lib.TFE_ContextAddFunctionDef(
            self.handle, serialized_function_def, size, handle(s))
    s:assert()
end

--- Adds a function (created from TF_GraphToFunction or
--- TF_FunctionImportFunctionDef) to the context, allowing it to be executed with
--- TFE_Execute by creating an op with the same name as the function.
---@param function_ tf.TFFunction
function M:addFunction(function_)
    local s = Status()
    lib.TFE_ContextAddFunction(
            self.handle, handle(function_), handle(s))
    s:assert()
end

--- Removes a function from the context. Once removed, you can no longer
--- TFE_Execute it or TFE_Execute any TFE_Op which has it as an attribute or any
--- other function which calls it as an attribute.
---@param name string
function M:removeFunction(name)
    local s = Status()
    lib.TFE_ContextRemoveFunction(
            self.handle, name, handle(s))
    s:assert()
end

--- Checks whether a function is registered under `name`.
---@param name string
function M:hasFunction(name)
    local ret = lib.TFE_ContextHasFunction(self.handle, name)
    return ret > 0
end

--- Enables tracing of RunMetadata on the ops executed from this context.
function M:enableRunMetadata()
    lib.TFE_ContextEnableRunMetadata(self.handle)
end

--- Disables tracing of RunMetadata on the ops executed from this context.
function M:disableRunMetadata()
    lib.TFE_ContextDisableRunMetadata(self.handle)
end

--- Populates the passed-in buffer with a serialized RunMetadata protocol buffer
--- containing any run metadata information accumulated so far and clears this
--- information.
--- If async mode is enabled, this call blocks till all currently pending ops are
--- done.
function M:exportRunMetadata()
    local buf = require('tf.c.TFBuffer')()
    local s = Status()
    lib.TFE_ContextExportRunMetadata(
            self.handle, handle(buf), handle(s))
    s:assert()
    return buf
end

--- Some TF ops need a step container to be set to limit the lifetime of some
--- resources (mostly TensorArray and Stack, used in while loop gradients in
--- graph mode). Calling this on a context tells it to start a step.
function M:startStep()
    lib.TFE_ContextStartStep(self.handle)
end

--- Ends a step. When there is no active step (that is, every started step has
--- been ended) step containers will be cleared. Note: it is not safe to call
--- TFE_ContextEndStep while ops which rely on the step container may be running.
function M:endStep()
    lib.TFE_ContextEndStep(self.handle)
end

--

--- Specify the server_def that enables collective ops.
--- This is different to the above function in that it doesn't create remote
--- contexts, and remotely executing ops is not possible. It just enables
--- communication for collective ops.
function M:enableCollectiveOps(proto, proto_len)
    local s = Status()
    libex.TFE_EnableCollectiveOps(
            self.handle, proto, proto_len or #proto, handle(s))
    s:assert()
end

--- Aborts all ongoing collectives with the specified status. After abortion,
--- subsequent collectives will error with this status immediately. To reset the
--- collectives, create a new EagerContext.
---
--- This is intended to be used when a peer failure is detected.
function M:abortCollectiveOps()
    local s = Status()
    libex.TFE_AbortCollectiveOps(self.handle, handle(s))
    s:assert()
end

--- Checks the health of collective ops peers. Explicit health check is needed in
--- multi worker collective ops to detect failures in the cluster.  If a peer is
--- down, collective ops may hang.
---@param task string
---@param timeout_in_ms number
function M:collectiveOpsCheckPeerHealth(task, timeout_in_ms)
    local s = Status()
    libex.TFE_CollectiveOpsCheckPeerHealth(
            self.handle, task, timeout_in_ms, handle(s))
    s:assert()
end

--

--- Enables only graph collection in RunMetadata on the functions executed from
--- this context.
function M:enableGraphCollection()
    libeex.TFE_ContextEnableGraphCollection(self.handle)
end

--- Disables only graph collection in RunMetadata on the functions executed from
--- this context.
function M:disableGraphCollection()
    libeex.TFE_ContextDisableGraphCollection(self.handle)
end

--- Returns the context_id from the EagerContext which is used by the
--- EagerService to maintain consistency between client and worker. The
--- context_id is initialized with a dummy value and is later set when the worker
--- is initialized (either locally or remotely). The context_id can change during
--- the process lifetime although this should cause the worker to be
--- reinitialized (e.g. cleared caches) as well.
function M:getId()
    return libeex.TFE_GetContextId(self.handle)
end

--- Sets a custom Executor for current thread. All nodes created by this thread
--- will be added to this Executor. It will override current executor.
function M:setExecutorForThread(executor)
    libeex.TFE_ContextSetExecutorForThread(self.handle, handle(executor))
end

--- Returns the Executor for current thread.
function M:getExecutorForThread()
    local p = libeex.TFE_ContextGetExecutorForThread(self.handle)
    if ffi.isnullptr(p) then
        return nil
    end
    return require('tf.c.TFEExecutor')(p)
end

--- Update an existing context with a new set of servers defined in a ServerDef
--- proto. Servers can be added to and removed from the list of remote workers
--- in the context. New set of servers identified by the ServerDef must be up
--- when the context is updated.
---
--- This API is for experimental usage and may be subject to change.
function M:updateServerDef(keep_alive_secs, proto, proto_len)
    local s = Status()
    libeex.TFE_ContextUpdateServerDef(
            self.handle, keep_alive_secs, proto, proto_len or #proto, handle(s))
    s:assert()
end

--- Checks whether a remote worker is alive or not. This will return true even if
--- the context doesn't exist on the remote worker.
---@param worker_name string
function M:checkAlive(worker_name)
    local s = Status()
    local ret = libeex.TFE_ContextCheckAlive(
            self.handle, worker_name, handle(s))
    s:assert()
    return ret
end

--- Sync pending nodes in local executors (including the context default executor
--- and thread executors) and streaming requests to remote executors, and get the
--- combined status.
function M:asyncWait()
    local s = Status()
    libeex.TFE_ContextAsyncWait(self.handle, handle(s))
    s:assert()
end

--- Retrieves the address space (i.e. job, replia, task) of the local host and
--- saves it in the buffer.
function M:hostAddressSpace()
    local buf = require('tf.c.TFBuffer')()
    libeex.TFE_HostAddressSpace(self.handle, handle(buf))
    return buf
end

function M:getFunctionDef(function_name)
    local buf = require('tf.c.TFBuffer')()
    local s = Status()
    libeex.TFE_ContextGetFunctionDef(self.handle, function_name, handle(buf), handle(s))
    s:assert()
    return buf
end

--- Configure soft device placement policy for the eager executor. Note this
--- policy is applied to any subsequent op executions.
function M:setSoftDevicePlacement(enable)
    local s = Status()
    libeex.TFE_ContextSetSoftDevicePlacement(self.handle, base.tfBool(enable), handle(s))
    s:assert()
end

--- Configure device placement policy logging for the eager executor. Note this
--- policy is applied to any subsequent op executions.
function M:setLogDevicePlacement(enable)
    local s = Status()
    libeex.TFE_ContextSetLogDevicePlacement(self.handle, base.tfBool(enable), handle(s))
    s:assert()
end

--

---@return tfe.TFEOp
function M:newOp(op_or_function_name)
    return require('tf.c.TFEOp').NewOp(self, op_or_function_name)
end

--

---@param opts tfe.TFEContextOptions
function M.NewContext(opts)
    local s = Status()
    local p = lib.TFE_NewContext(handle(opts), handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

return M
