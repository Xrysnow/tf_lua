---@class tf.TFGraph
--- Represents a computation graph.  Graphs may be shared between sessions.
--- Graphs are thread-safe when used as directed below.
local M = class('tf.TFGraph')
local lib = require('tf.c._c_api')
local libex = require('tf.c._c_api_experimental')
local Status = require('tf.c.TFStatus')
local Buffer = require('tf.c.TFBuffer')
local base = require('tf.base')

function M:ctor()
    self.handle = lib.TF_NewGraph()
end
--- Destroy an options object.  Graph will be deleted once no more
--- TFSession's are referencing it.
function M:dtor()
    lib.TF_DeleteGraph(self.handle)
    self.handle = nil
end
--- Sets the shape of the Tensor referenced by `output` in `graph` to
--- the shape described by `dims` and `num_dims`.
---
--- If the number of dimensions is unknown, `num_dims` must be set to
--- -1 and `dims` can be null. If a dimension is unknown, the
--- corresponding entry in the `dims` array must be -1.
---
--- This does not overwrite the existing shape associated with `output`,
--- but merges the input shape with the existing shape.  For example,
--- setting a shape of [-1, 2] with an existing shape [2, -1] would set
--- a final shape of [2, 2] based on shape merging semantics.
---
--- Returns an error into `status` if:
---   * `output` is not in `graph`.
---   * An invalid shape is being set (e.g., the shape being set
---     is incompatible with the existing shape).
---@param output tf.TFOutput
---@param dims number[]
function M:setTensorShape(output, dims)
    local s = Status()
    local d, nd = base.packDims(dims)
    lib.TF_GraphSetTensorShape(self.handle, handle(output)[0], d, nd, handle(s))
    s:assert()
end
--- Returns the number of dimensions of the Tensor referenced by `output`
--- in `graph`.
---
--- If the number of dimensions in the shape is unknown, returns -1.
---
--- Returns an error into `status` if:
---   * `output` is not in `graph`.
---@param output tf.TFOutput
---@return number
function M:getTensorNumDims(output)
    local s = Status()
    local ret = lib.TF_GraphGetTensorNumDims(self.handle, handle(output)[0], handle(s))
    s:assert()
    return tonumber(ret)
end
--- Returns the shape of the Tensor referenced by `output` in `graph`
--- into `dims`. `dims` must be an array large enough to hold `num_dims`
--- entries (e.g., the return value of TF_GraphGetTensorNumDims).
---
--- If the number of dimensions in the shape is unknown or the shape is
--- a scalar, `dims` will remain untouched. Otherwise, each element of
--- `dims` will be set corresponding to the size of the dimension. An
--- unknown dimension is represented by `-1`.
---
--- Returns an error into `status` if:
---   * `output` is not in `graph`.
---   * `num_dims` does not match the actual number of dimensions.
---@param output tf.TFOutput
---@return number[]
function M:getTensorShape(output)
    local ndim = self:getTensorNumDims(output)
    if ndim == 0 then
        -- scalar
        return {}
    end
    local dims = ffi.new('int64_t[?]', ndim)
    local s = Status()
    lib.TF_GraphGetTensorShape(self.handle, handle(output)[0], dims, ndim, handle(s))
    s:assert()
    return base.unpackDims(dims, ndim)
end
--- Operation will only be added to *graph when TF_FinishOperation() is
--- called (assuming TF_FinishOperation() does not return an error).
--- *graph must not be deleted until after TF_FinishOperation() is
--- called.
---@param op_type string
---@param oper_name string
---@return tf.TFOperationDescription
function M:newOperation(op_type, oper_name)
    return require('tf.c.TFOperationDescription').NewOperation(self, op_type, oper_name)
end
--- Returns the operation in the graph with `oper_name`. Returns nullptr if
--- no operation found.
---@param oper_name string
function M:operationByName(oper_name)
    local p = lib.TF_GraphOperationByName(self.handle, oper_name)
    if ffi.isnullptr(p) then
        return nil
    end
    return require('tf.c.TFOperation')(p)
end

---@return tf.TFOperation[]
function M:operations()
    local pos = ffi.new('size_t[1]', 0)
    local ret = {}
    while true do
        local p = lib.TF_GraphNextOperation(self.handle, pos)
        if ffi.isnullptr(p) then
            break
        end
        table.insert(ret, require('tf.c.TFOperation')(p))
    end
    return ret
end
--- Write out a serialized representation of `graph` (as a GraphDef protocol
--- message) to `output_graph_def` (allocated by TF_NewBuffer()).
--- `output_graph_def`'s underlying buffer will be freed when TF_DeleteBuffer()
--- is called.
---
--- May fail on very large graphs in the future.
function M:toGraphDef()
    local s = Status()
    local out = Buffer()
    lib.TF_GraphToGraphDef(self.handle, handle(out), handle(s))
    return out
end
--- Returns the serialized OpDef proto with name `op_name`, or a bad status if no
--- such op exists. This can return OpDefs of functions copied into the graph.
function M:getOpDef()
    local s = Status()
    local out = Buffer()
    lib.TF_GraphGetOpDef(self.handle, handle(out), handle(s))
    return out
end
--- Returns the serialized VersionDef proto for this graph.
function M:versions()
    local s = Status()
    local out = Buffer()
    lib.TF_GraphVersions(self.handle, handle(out), handle(s))
    return out
end
--- Import the graph serialized in `graph_def` into `graph`.  Returns nullptr and
--- a bad status on error. Otherwise, returns a populated
--- TF_ImportGraphDefResults instance. The returned instance must be deleted via
--- TF_DeleteImportGraphDefResults().
---@param graph_def tf.TFBuffer
---@param options tf.TFImportGraphDefOptions
function M:importGraphDefWithResults(graph_def, options)
    local s = Status()
    local p = lib.TF_GraphImportGraphDefWithResults(
            self.handle, handle(graph_def), handle(options), handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return require('tf.c.TFImportGraphDefResults')(p)
end
--- Import the graph serialized in `graph_def` into `graph`.
--- Convenience function for when only return outputs are needed.
---
--- `num_return_outputs` must be the number of return outputs added (i.e. the
--- result of TF_ImportGraphDefOptionsNumReturnOutputs()).  If
--- `num_return_outputs` is non-zero, `return_outputs` must be of length
--- `num_return_outputs`. Otherwise it can be null.
---@param graph_def tf.TFBuffer
---@param options tf.TFImportGraphDefOptions
---@return tf.TFOutput[]
function M:importGraphDefWithReturnOutputs(graph_def, options)
    local n = options:numReturnOutputs()
    if n == 0 then
        return {}
    end
    local s = Status()
    local out = ffi.new('TF_Output[?]', n)
    lib.TF_GraphImportGraphDefWithReturnOutputs(
            self.handle, handle(graph_def), handle(options), out, n, handle(s))
    s:assert()
    local ret = {}
    for i = 1, n do
        local hdl = ffi.new('TF_Output[1]')
        hdl[0] = out[i - 1]
        ret[i] = require('tf.c.TFOutput')(hdl)
    end
    return ret
end
--- Import the graph serialized in `graph_def` into `graph`.
--- Convenience function for when no results are needed.
---@param graph_def tf.TFBuffer
---@param options tf.TFImportGraphDefOptions
function M:importGraphDef(graph_def, options)
    local s = Status()
    lib.TF_GraphImportGraphDef(
            self.handle, handle(graph_def), handle(options), handle(s))
    s:assert()
end
--- Adds a copy of function `func` and optionally its gradient function `grad`
--- to `g`. Once `func`/`grad` is added to `g`, it can be called by creating
--- an operation using the function's name.
--- Any changes to `func`/`grad` (including deleting it) done after this method
--- returns, won't affect the copy of `func`/`grad` in `g`.
--- If `func` or `grad` are already in `g`, TF_GraphCopyFunction has no
--- effect on them, but can establish the function->gradient relationship
--- between them if `func` does not already have a gradient. If `func` already
--- has a gradient different from `grad`, an error is returned.
---
--- `func` must not be null.
--- If `grad` is null and `func` is not in `g`, `func` is added without a
--- gradient.
--- If `grad` is null and `func` is in `g`, TF_GraphCopyFunction is a noop.
--- `grad` must have appropriate signature as described in the doc of
--- GradientDef in tensorflow/core/framework/function.proto.
---
--- If successful, status is set to OK and `func` and `grad` are added to `g`.
--- Otherwise, status is set to the encountered error and `g` is unmodified.
---@param func tf.TFFunction
---@param grad tf.TFFunction
function M:copyFunction(func, grad)
    assert(func)
    local s = Status()
    lib.TF_GraphCopyFunction(
            self.handle, handle(func), handle(grad), handle(s))
    s:assert()
end
--- Returns the number of TF_Functions registered in `g`.
---@return number
function M:numFunctions()
    return tonumber(lib.TF_GraphNumFunctions(self.handle))
end
--- Fills in `funcs` with the TF_Function* registered in `g`.
--- `funcs` must point to an array of TF_Function* of length at least
--- `max_func`. In usual usage, max_func should be set to the result of
--- TF_GraphNumFunctions(g). In this case, all the functions registered in
--- `g` will be returned. Else, an unspecified subset.
---
--- If successful, returns the number of TF_Function* successfully set in
--- `funcs` and sets status to OK. The caller takes ownership of
--- all the returned TF_Functions. They must be deleted with TF_DeleteFunction.
--- On error, returns 0, sets status to the encountered error, and the contents
--- of funcs will be undefined.
---@return tf.TFFunction[]
function M:getFunctions()
    local n = self:numFunctions()
    if n == 0 then
        return {}
    end
    local s = Status()
    local funcs = ffi.new('TF_Function*[?]', n)
    lib.TF_GraphGetFunctions(self.handle, funcs, n, handle(s))
    s:assert()
    local ret = {}
    for i = 1, n do
        ret[i] = require('tf.c.TFFunction')(funcs[i - 1])
    end
    return ret
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
---@param inputs tf.TFOutput[]
function M:newWhile(inputs)
    return require('tf.c.TFWhileParams').NewWhile(self, inputs)
end
--- Adds operations to compute the partial derivatives of sum of `y`s w.r.t `x`s,
--- i.e., d(y_1 + y_2 + ...)/dx_1, d(y_1 + y_2 + ...)/dx_2...
---
--- `dx` are used as initial gradients (which represent the symbolic partial
--- derivatives of some loss function `L` w.r.t. `y`).
--- `dx` must be nullptr or have size `ny`.
--- If `dx` is nullptr, the implementation will use dx of `OnesLike` for all
--- shapes in `y`.
--- The partial derivatives are returned in `dy`. `dy` should be allocated to
--- size `nx`.
---
--- Gradient nodes are automatically named under the "gradients/" prefix. To
--- guarantee name uniqueness, subsequent calls to the same graph will
--- append an incremental tag to the prefix: "gradients_1/", "gradients_2/", ...
--- See TF_AddGradientsWithPrefix, which provides a means to specify a custom
--- name prefix for operations added to a graph to compute the gradients.
---
--- WARNING: This function does not yet support all the gradients that python
--- supports. See
--- https://www.tensorflow.org/code/tensorflow/cc/gradients/README.md
--- for instructions on how to add C++ more gradients.
---@param y tf.TFOutput[]
---@param x tf.TFOutput[]
---@param dx tf.TFOutput[]
function M:addGradients(y, x, dx)
    local Output = require('tf.c.TFOutput')
    local s = Status()
    local nx = #x
    local ny = #y
    if dx then
        assert(#dx == ny)
        dx = Output.pack(dx)
    end
    local yy = Output.pack(y)
    local xx = Output.pack(x)
    local dy = ffi.new('TF_Output[?]', nx)
    lib.TF_AddGradients(self.handle, yy, ny, xx, nx, dx, handle(s), dy)
    s:assert()
    return Output.unpack(dy, nx)
end
--- Adds operations to compute the partial derivatives of sum of `y`s w.r.t `x`s,
--- i.e., d(y_1 + y_2 + ...)/dx_1, d(y_1 + y_2 + ...)/dx_2...
--- This is a variant of TF_AddGradients that allows to caller to pass a custom
--- name prefix to the operations added to a graph to compute the gradients.
---
--- `dx` are used as initial gradients (which represent the symbolic partial
--- derivatives of some loss function `L` w.r.t. `y`).
--- `dx` must be nullptr or have size `ny`.
--- If `dx` is nullptr, the implementation will use dx of `OnesLike` for all
--- shapes in `y`.
--- The partial derivatives are returned in `dy`. `dy` should be allocated to
--- size `nx`.
--- `prefix` names the scope into which all gradients operations are being added.
--- `prefix` must be unique within the provided graph otherwise this operation
--- will fail. If `prefix` is nullptr, the default prefixing behaviour takes
--- place, see TF_AddGradients for more details.
---
--- WARNING: This function does not yet support all the gradients that python
--- supports. See
--- https://www.tensorflow.org/code/tensorflow/cc/gradients/README.md
--- for instructions on how to add C++ more gradients.
---@param y tf.TFOutput[]
---@param x tf.TFOutput[]
---@param dx tf.TFOutput[]
function M:addGradientsWithPrefix(prefix, y, x, dx)
    local Output = require('tf.c.TFOutput')
    local nx = #x
    local ny = #y
    if dx then
        assert(#dx == ny)
        dx = Output.pack(dx)
    end
    local yy = Output.pack(y)
    local xx = Output.pack(x)
    local dy = ffi.new('TF_Output[?]', nx)
    local s = Status()
    lib.TF_AddGradientsWithPrefix(self.handle, prefix, yy, ny, xx, nx, dx, handle(s), dy)
    s:assert()
    return Output.unpack(dy, nx)
end
--- Create a TF_Function from a TF_Graph
---
--- Params:
--- - fn_body - the graph whose operations (or subset of whose operations) will be
---            converted to TF_Function.
--- - fn_name - the name of the new TF_Function. Should match the operation
---            name (OpDef.name) regexp [A-Z][A-Za-z0-9_.\\-/]*.
---            If `append_hash_to_fn_name` is false, `fn_name` must be distinct
---            from other function and operation names (at least those
---            registered in graphs where this function will be used).
--- - append_hash_to_fn_name - Must be 0 or 1. If set to 1, the actual name
---                           of the function will be `fn_name` appended with
---                           '_<hash_of_this_function's_definition>'.
---                           If set to 0, the function's name will be `fn_name`.
--- - num_opers - `num_opers` contains the number of elements in the `opers` array
---              or a special value of -1 meaning that no array is given.
---              The distinction between an empty array of operations and no
---              array of operations is necessary to distinguish the case of
---              creating a function with no body (e.g. identity or permutation)
---              and the case of creating a function whose body contains all
---              the nodes in the graph (except for the automatic skipping, see
---              below).
--- - opers - Array of operations to become the body of the function or null.
---          - If no array is given (`num_opers`  = -1), all the
---          operations in `fn_body` will become part of the function
---          except operations referenced in `inputs`. These operations
---          must have a single output (these operations are typically
---          placeholders created for the sole purpose of representing
---          an input. We can relax this constraint if there are
---          compelling use cases).
---          - If an array is given (`num_opers` >= 0), all operations
---          in it will become part of the function. In particular, no
---          automatic skipping of dummy input operations is performed.
--- - ninputs - number of elements in `inputs` array
--- - inputs - array of TF_Outputs that specify the inputs to the function.
---           If `ninputs` is zero (the function takes no inputs), `inputs`
---           can be null. The names used for function inputs are normalized
---           names of the operations (usually placeholders) pointed to by
---           `inputs`. These operation names should start with a letter.
---           Normalization will convert all letters to lowercase and
---           non-alphanumeric characters to '_' to make resulting names match
---           the "[a-z][a-z0-9_]*" pattern for operation argument names.
---           `inputs` cannot contain the same tensor twice.
--- - noutputs - number of elements in `outputs` array
--- - outputs - array of TF_Outputs that specify the outputs of the function.
---            If `noutputs` is zero (the function returns no outputs), `outputs`
---            can be null. `outputs` can contain the same tensor more than once.
--- - output_names - The names of the function's outputs. `output_names` array
---                 must either have the same length as `outputs`
---                 (i.e. `noutputs`) or be null. In the former case,
---                 the names should match the regular expression for ArgDef
---                 names - "[a-z][a-z0-9_]*". In the latter case,
---                 names for outputs will be generated automatically.
---  opts - various options for the function, e.g. XLA's inlining control.
---  description - optional human-readable description of this function.
---  status - Set to OK on success and an appropriate error on failure.
---
--- Note that when the same TF_Output is listed as both an input and an output,
--- the corresponding function's output will equal to this input,
--- instead of the original node's output.
---
--- Callers must also satisfy the following constraints:
--- - `inputs` cannot refer to TF_Outputs within a control flow context. For
---   example, one cannot use the output of "switch" node as input.
--- - `inputs` and `outputs` cannot have reference types. Reference types are
---   not exposed through C API and are being replaced with Resources. We support
---   reference types inside function's body to support legacy code. Do not
---   use them in new code.
--- - Every node in the function's body must have all of its inputs (including
---   control inputs). In other words, for every node in the body, each input
---   must be either listed in `inputs` or must come from another node in
---   the body. In particular, it is an error to have a control edge going from
---   a node outside of the body into a node in the body. This applies to control
---   edges going from nodes referenced in `inputs` to nodes in the body when
---   the former nodes are not in the body (automatically skipped or not
---   included in explicitly specified body).
---
--- Returns:
---  On success, a newly created TF_Function instance. It must be deleted by
---  calling TF_DeleteFunction.
---
---  On failure, null.
---@param fn_name string
---@param append_hash_to_fn_name boolean
---@param opers tf.TFOperation[]
---@param inputs tf.TFOutput[]
---@param outputs tf.TFOutput[]
---@param output_names string[]|nil
---@param opts any @TF_FunctionOptions
---@param description string|nil
function M:toFunction(fn_name, append_hash_to_fn_name, opers, inputs, outputs, output_names, opts, description)
    local Output = require('tf.c.TFOutput')
    append_hash_to_fn_name = base.tfBool(append_hash_to_fn_name)
    local num_opers = opers and #opers or -1
    local opers_
    if opers then
        opers_ = base.packHandles('TF_Operation*', opers)
    --else
    --    opers_ = ffi.new('TF_Operation**')
    end
    local ninputs = #inputs
    local inputs_ = Output.pack(inputs)
    local noutputs = #outputs
    local outputs_ = Output.pack(outputs)
    local output_names_
    if output_names then
        output_names_ = base.packValues('const char*', output_names)
    --else
    --    output_names_ = ffi.new('const char**')
    end
    local s = Status()
    local p = lib.TF_GraphToFunction(
            self.handle, fn_name, append_hash_to_fn_name, num_opers, opers_,
            ninputs, inputs_, noutputs, outputs_, output_names_,
            handle(opts), description, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return require('tf.c.TFFunction')(p)
end
--- Similar to TF_GraphToFunction but allows specifying control outputs of the
--- function.
---
---  The arguments of TF_GraphToFunction have the same meaning, but the new
---  arguments are as follows:
---
--- -   ncontrol_outputs: Number of control outputs of the function.
--- -   control_outputs: vector of TF_Operation objects to be marked as control
---      outputs of the function. Operations marked as control outputs are
---      guaranteed to execute.
--- -   control_output_names: Optional. If not nullptr, vector of strings, one
---      per control output, with their names to be added to the function's
---      OpDef.
---@param fn_name string
---@param append_hash_to_fn_name boolean
---@param opers tf.TFOperation[]
---@param inputs tf.TFOutput[]
---@param outputs tf.TFOutput[]
---@param output_names string[]|nil
---@param control_outputs tf.TFOutput[]
---@param control_output_names string[]|nil
---@param opts any @TF_FunctionOptions
---@param description string|nil
function M:toFunctionWithControlOutputs(
        fn_name, append_hash_to_fn_name, opers,
        inputs, outputs, output_names, control_outputs, control_output_names, opts, description)
    local Output = require('tf.c.TFOutput')
    append_hash_to_fn_name = base.tfBool(append_hash_to_fn_name)
    local num_opers = opers and #opers or -1
    local opers_
    if opers then
        opers_ = base.packHandles('TF_Operation*', opers)
    else
        opers_ = ffi.new('TF_Operation**')
    end
    local ninputs = #inputs
    local inputs_ = Output.pack(inputs)
    local noutputs = #outputs
    local outputs_ = Output.pack(outputs)
    local output_names_
    if output_names then
        output_names_ = base.packValues('const char*', output_names)
    else
        output_names_ = ffi.new('const char**')
    end
    local ncontrol_outputs = #control_outputs
    local control_outputs_ = base.packHandles('TF_Operation*', control_outputs)
    local control_output_names_
    if control_output_names then
        control_output_names_ = base.packValues('const char*', control_output_names)
    else
        control_output_names_ = ffi.new('const char**')
    end
    local s = Status()
    local p = lib.TF_GraphToFunctionWithControlOutputs(
            self.handle, fn_name, append_hash_to_fn_name, num_opers, opers_,
            ninputs, inputs_, noutputs, outputs_, output_names_,
            ncontrol_outputs, control_outputs_, control_output_names_,
            handle(opts), description, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return require('tf.c.TFFunction')(p)
end
--- Attempts to evaluate `output`. This will only be possible if `output` doesn't
--- depend on any graph inputs (this function is safe to call if this isn't the
--- case though).
---
--- If the evaluation is successful, this function returns true and `output`s
--- value is returned in `result`. Otherwise returns false. An error status is
--- returned if something is wrong with the graph or input. Note that this may
--- return false even if no error status is set.
---@param output tf.TFOutput
function M:tryEvaluateConstant(output)
    local s = Status()
    local result = ffi.new('TF_Tensor*[1]')
    local ret = lib.TF_TryEvaluateConstant(self.handle, handle(output)[0], result, handle(s))
    s:assert()
    local ok = ret > 0
    local tensor
    if ok then
        tensor = require('tf.c.TFTensor')(result[0])
    end
    return ok, tensor
end
--- Update edge, switch input/ output in a node
---@param new_src tf.TFOutput
---@param dst tf.TFInput
function M:updateEdge(new_src, dst)
    local s = Status()
    lib.TF_UpdateEdge(self.handle, handle(new_src)[0], handle(dst)[0], handle(s))
    s:assert()
end

function M:debugString()
    local len = ffi.new('size_t[1]')
    local p = libex.TF_GraphDebugString(self.handle, len)
    local s = ffi.string(p, len[0])
    ffi.C.free(ffi.cast('void*', p))
    return s
end

--

---@param oper string|tf.TFOperation
function M:getOpOutputTensorShapes(oper)
    if type(oper) == 'string' then
        oper = self:operationByName(oper)
    end
    if not oper then
        return
    end
    local outputs = oper:getOutputs()
    local ret = {}
    for _, v in ipairs(outputs) do
        table.insert(ret, self:getTensorShape(v))
    end
    return ret
end

function M:importGraphDefFile(path, opts)
    local buf = require('tf.c.TFBuffer').CreateFromFile(path)
    assert(buf)
    opts = opts or require('tf.c.TFImportGraphDefOptions')()
    self:importGraphDef(buf, opts)
end

---@return tf.TFGraph
function M.CreateFromFile(path, opts)
    ret:importGraphDefFile(path, opts)
    return ret
end

---@return tf.TFGraph
function M.CreateFromFileWithCheckpoint(path, checkpoint_prefix, opts)
    assert(type(checkpoint_prefix) == 'string')
    local graph = M.CreateFromFile(path, opts)
    local checkpoint_tensor = require('tf.c.TFTensor').CreateScalarString(checkpoint_prefix)
    local input = require('tf.c.TFInput')()
    input:oper(graph:operationByName('save/Const'))
    local restore_op = graph:operationByName('save/restore_all')
    local session = require('tf.c.TFSession').Create(graph)
    session:run(nil, { input }, { checkpoint_tensor }, nil, { restore_op })
    return graph
end

return M
