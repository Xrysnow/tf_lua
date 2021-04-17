---@class tf.TFSession
local M = class('tf.TFSession')
local base = require('tf.base')
local lib = base._lib
local libex = base._libex
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end

--- Destroy a session object.
---
--- Even if error information is recorded in *status, this call discards all
--- local resources associated with the session.  The session may not be used
--- during or after this call (and the session drops its reference to the
--- corresponding graph).
function M:dtor()
    if not self.handle then
        return
    end
    local s = Status()
    if not self._closed then
        lib.TF_CloseSession(self.handle, handle(s))
        s:assert()
    end
    lib.TF_DeleteSession(self.handle, handle(s))
    self.handle = nil
    s:assert()
end

--- Close a session.
---
--- Contacts any other processes associated with the session, if applicable.
--- May not be called after TF_DeleteSession().
function M:close()
    local s = Status()
    lib.TF_CloseSession(self.handle, handle(s))
    s:assert()
    self._closed = true
end

--- Run the graph associated with the session starting with the supplied inputs
--- (inputs[0,ninputs-1] with corresponding values in input_values[0,ninputs-1]).
---
--- Any NULL and non-NULL value combinations for (`run_options`,
--- `run_metadata`) are valid.
---
---    - `run_options` may be NULL, in which case it will be ignored; or
---      non-NULL, in which case it must point to a `TF_Buffer` containing the
---      serialized representation of a `RunOptions` protocol buffer.
---    - `run_metadata` may be NULL, in which case it will be ignored; or
---      non-NULL, in which case it must point to an empty, freshly allocated
---      `TF_Buffer` that may be updated to contain the serialized representation
---      of a `RunMetadata` protocol buffer.
---
--- The caller retains ownership of `input_values` (which can be deleted using
--- TF_DeleteTensor). The caller also retains ownership of `run_options` and/or
--- `run_metadata` (when not NULL) and should manually call TF_DeleteBuffer on
--- them.
---
--- On success, the tensors corresponding to outputs[0,noutputs-1] are placed in
--- output_values[]. Ownership of the elements of output_values[] is transferred
--- to the caller, which must eventually call TF_DeleteTensor on them.
---
--- On failure, output_values[] contains NULLs.
---@param run_options tf.TFBuffer|nil
---@param inputs tf.TFOutput[]
---@param input_values tf.TFTensor[]
---@param outputs tf.TFOutput[]|nil
---@param target_opers tf.TFOperation[]|nil
---@return tf.TFTensor[], tf.TFBuffer
function M:run(run_options, inputs, input_values, outputs, target_opers, need_metadata)
    assert(#input_values == #inputs)
    local Output = require('tf.c.TFOutput')
    local inputs_ = Output.pack(inputs)
    local input_values_ = base.packHandles('TF_Tensor*', input_values)
    local ninputs = #inputs
    --
    if outputs and #outputs == 0 then
        outputs = nil
    end
    local outputs_ = outputs and Output.pack(outputs) or nil
    local noutputs = outputs and #outputs or 0
    local output_values = outputs and ffi.new('TF_Tensor*[?]', noutputs) or nil
    --
    if target_opers and #target_opers == 0 then
        target_opers = nil
    end
    local target_opers_ = target_opers and base.packHandles('TF_Operation*', target_opers) or nil
    local ntarget_opers = target_opers and #target_opers or 0
    --
    local run_metadata = need_metadata and require('tf.c.TFBuffer')() or nil
    local s = Status()
    lib.TF_SessionRun(
            self.handle, handle(run_options),
            inputs_, input_values_, ninputs,
            outputs_, output_values, noutputs,
            target_opers_, ntarget_opers,
            handle(run_metadata), handle(s))
    s:assert()
    local out = {}
    for i = 1, noutputs do
        out[i] = require('tf.c.TFTensor')(output_values[i - 1])
    end
    return out, run_metadata
end

--- Set up the graph with the intended feeds (inputs) and fetches (outputs) for a
--- sequence of partial run calls.
---
--- On success, returns a handle that is used for subsequent PRun calls. The
--- handle should be deleted with TF_DeletePRunHandle when it is no longer
--- needed.
---
--- On failure, out_status contains a tensorflow::Status with an error
--- message. *handle is set to nullptr.
---@param inputs tf.TFOutput[]
---@param outputs tf.TFOutput[]
---@param target_opers tf.TFOperation[]
---@return ffi.cdata
function M:prunSetup(inputs, outputs, target_opers)
    local Output = require('tf.c.TFOutput')
    local inputs_ = Output.pack(inputs)
    local ninputs = #inputs
    --
    if outputs and #outputs == 0 then
        outputs = nil
    end
    local outputs_ = outputs and Output.pack(outputs) or nil
    local noutputs = outputs and #outputs or 0
    --
    if target_opers and #target_opers == 0 then
        target_opers = nil
    end
    local target_opers_ = target_opers and base.packHandles('TF_Operation*', target_opers) or nil
    local ntarget_opers = target_opers and #target_opers or 0
    --
    local hdl = ffi.new('const char*[1]')
    local s = Status()
    lib.TF_SessionPRunSetup(
            self.handle,
            inputs_, ninputs,
            outputs_, noutputs,
            target_opers_, ntarget_opers,
            hdl, handle(s))
    s:assert()
    hdl = ffi.gc(hdl[0], lib.TF_DeletePRunHandle)
    return hdl
end

--- Continue to run the graph with additional feeds and fetches. The
--- execution state is uniquely identified by the handle.
---@param hdl ffi.cdata
---@param inputs tf.TFOutput[]
---@param input_values tf.TFTensor[]
---@param outputs tf.TFOutput[]
---@param target_opers tf.TFOperation[]
---@return tf.TFTensor[]
function M:prun(hdl, inputs, input_values, outputs, target_opers)
    assert(#input_values == #inputs)
    local Output = require('tf.c.TFOutput')
    local inputs_ = Output.pack(inputs)
    local input_values_ = base.packHandles('TF_Tensor*', input_values)
    local ninputs = #inputs
    --
    if outputs and #outputs == 0 then
        outputs = nil
    end
    local outputs_ = outputs and Output.pack(outputs) or nil
    local noutputs = outputs and #outputs or 0
    local output_values = outputs and ffi.new('TF_Tensor*[?]', noutputs) or nil
    --
    --
    if target_opers and #target_opers == 0 then
        target_opers = nil
    end
    local target_opers_ = target_opers and base.packHandles('TF_Operation*', target_opers) or nil
    local ntarget_opers = target_opers and #target_opers or 0
    --
    local s = Status()
    lib.TF_SessionPRun(
            self.handle, assert(hdl),
            inputs_, input_values_, ninputs,
            outputs_, output_values, noutputs,
            target_opers_, ntarget_opers,
            handle(s))
    s:assert()
    local out = {}
    for i = 1, noutputs do
        out[i] = require('tf.c.TFTensor')(output_values[i - 1])
    end
    return out
end

--- Lists all devices in a TF_Session.
---
--- Caller takes ownership of the returned TF_DeviceList* which must eventually
--- be freed with a call to TF_DeleteDeviceList.
function M:listDevices()
    local s = Status()
    local p = lib.TF_SessionListDevices(self.handle, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return require('tf.c.TFDeviceList')(p)
end

--- On success, dequeues a tensor from a TF-managed FifoQueue given by
--- `tensor_id`, associated with `session`. There must be a graph node named
--- "fifo_queue_dequeue_<tensor_id>", to be executed by this API call.

--- Caller must call TF_DeleteTensor() over the returned tensor. If the queue is
--- empty, this call is blocked.
---
--- Tensors are enqueued via the corresponding TF enqueue op.
--- TODO(hongm): Add support for `timeout_ms`.
---@param tensor_id number
function M:dequeueNamedTensor(tensor_id)
    local s = Status()
    local p = libex.TF_DequeueNamedTensor(self.handle, tensor_id, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return require('tf.c.TFTensor')(p)
end

--- On success, enqueues `tensor` into a TF-managed FifoQueue given by
--- `tensor_id`, associated with `session`. There must be a graph node named
--- "fifo_queue_enqueue_<tensor_id>", to be executed by this API call. It reads
--- from a placeholder node "arg_tensor_enqueue_<tensor_id>".
---
--- `tensor` is still owned by the caller. This call will be blocked if the queue
--- has reached its capacity, and will be unblocked when the queued tensors again
--- drop below the capacity due to dequeuing.
---
--- Tensors are dequeued via the corresponding TF dequeue op.
--- TODO(hongm): Add support for `timeout_ms`.
---@param tensor_id number
---@param tensor tf.TFTensor
function M:enqueueNamedTensor(tensor_id, tensor)
    local s = Status()
    libex.TF_EnqueueNamedTensor(self.handle, tensor_id, handle(tensor), handle(s))
    s:assert()
end

--- Return a new execution session with the associated graph, or NULL on
--- error. Does not take ownership of any input parameters.
---
--- *`graph` must be a valid graph (not deleted or nullptr). `graph` will be be
--- kept alive for the lifetime of the returned TF_Session. New nodes can still
--- be added to `graph` after this call.
---@param graph tf.TFGraph
---@param opts tf.TFSessionOptions
function M.NewSession(graph, opts)
    local s = Status()
    local p = lib.TF_NewSession(handle(graph), handle(opts), handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

--- This function creates a new TF_Session (which is created on success) using
--- `session_options`, and then initializes state (restoring tensors and other
--- assets) using `run_options`.
---
--- Any NULL and non-NULL value combinations for (`run_options, `meta_graph_def`)
--- are valid.
---
--- - `export_dir` must be set to the path of the exported SavedModel.
--- - `tags` must include the set of tags used to identify one MetaGraphDef in
---    the SavedModel.
--- - `graph` must be a graph newly allocated with TF_NewGraph().
---
--- If successful, populates `graph` with the contents of the Graph and
--- `meta_graph_def` with the MetaGraphDef of the loaded model.
---@param session_options tf.TFSessionOptions
---@param run_options tf.TFBuffer|nil
---@param export_dir string
---@param tags string[]
---@param graph tf.TFGraph
---@param meta_graph_def tf.TFBuffer|nil
function M.LoadSessionFromSavedModel(
        session_options, run_options, export_dir, tags, graph, meta_graph_def)
    assert(session_options and export_dir and tags and graph)
    local tags_ = base.packValues('const char*', tags)
    local s = Status()
    local p = lib.TF_LoadSessionFromSavedModel(
            handle(session_options), handle(run_options), export_dir, tags_, #tags,
            handle(graph), handle(meta_graph_def), handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

---@param graph tf.TFGraph
---@param opts tf.TFSessionOptions|nil
function M.Create(graph, opts)
    opts = opts or require('tf.c.TFSessionOptions')()
    return M.NewSession(graph, opts)
end

return M
