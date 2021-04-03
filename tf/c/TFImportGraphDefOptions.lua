---@class tf.TFImportGraphDefOptions
--- TF_ImportGraphDefOptions holds options that can be passed to
--- TF_GraphImportGraphDef.
local M = class('tf.TFImportGraphDefOptions')
local lib = require('tf.c._c_api')

function M:ctor(hdl)
    if hdl then
        assert(hdl and not ffi.isnullptr(hdl))
        self.handle = hdl
    else
        self.handle = lib.TF_NewImportGraphDefOptions()
    end
end

function M:dtor()
    lib.TF_DeleteImportGraphDefOptions(self.handle)
    self.handle = nil
end
--- Set the prefix to be prepended to the names of nodes in `graph_def` that will
--- be imported into `graph`. `prefix` is copied and has no lifetime
--- requirements.
---@param prefix string
function M:setPrefix(prefix)
    lib.TF_ImportGraphDefOptionsSetPrefix(self.handle, prefix)
end
--- Set the execution device for nodes in `graph_def`.
--- Only applies to nodes where a device was not already explicitly specified.
--- `device` is copied and has no lifetime requirements.
---@param device string
function M:setDefaultDevice(device)
    lib.TF_ImportGraphDefOptionsSetDefaultDevice(self.handle, device)
end
--- Set whether to uniquify imported operation names. If true, imported operation
--- names will be modified if their name already exists in the graph. If false,
--- conflicting names will be treated as an error. Note that this option has no
--- effect if a prefix is set, since the prefix will guarantee all names are
--- unique. Defaults to false.
---@param uniquify_names boolean
function M:setUniquifyNames(uniquify_names)
    lib.TF_ImportGraphDefOptionsSetUniquifyNames(self.handle, uniquify_names and 1 or 0)
end
--- If true, the specified prefix will be modified if it already exists as an
--- operation name or prefix in the graph. If false, a conflicting prefix will be
--- treated as an error. This option has no effect if no prefix is specified.
---@param uniquify_prefix boolean
function M:setUniquifyPrefix(uniquify_prefix)
    lib.TF_ImportGraphDefOptionsSetUniquifyPrefix(self.handle, uniquify_prefix and 1 or 0)
end
--- Set any imported nodes with input `src_name:src_index` to have that input
--- replaced with `dst`. `src_name` refers to a node in the graph to be imported,
--- `dst` references a node already existing in the graph being imported into.
--- `src_name` is copied and has no lifetime requirements.
---@param src_name string
---@param src_index number
---@param dst tf.TFOutput
function M:addInputMapping(src_name, src_index, dst)
    lib.TF_ImportGraphDefOptionsAddInputMapping(self.handle, src_name, src_index, handle(dst)[0])
end
--- Set any imported nodes with control input `src_name` to have that input
--- replaced with `dst`. `src_name` refers to a node in the graph to be imported,
--- `dst` references an operation already existing in the graph being imported
--- into. `src_name` is copied and has no lifetime requirements.
---@param src_name string
---@param dst tf.TFOperation
function M:remapControlDependency(src_name, dst)
    lib.TF_ImportGraphDefOptionsRemapControlDependency(self.handle, src_name, handle(dst))
end
--- Cause the imported graph to have a control dependency on `oper`. `oper`
--- should exist in the graph being imported into.
---@param oper tf.TFOperation
function M:addControlDependency(oper)
    lib.TF_ImportGraphDefOptionsAddControlDependency(self.handle, handle(oper))
end
--- Add an output in `graph_def` to be returned via the `return_outputs` output
--- parameter of TF_GraphImportGraphDef(). If the output is remapped via an input
--- mapping, the corresponding existing tensor in `graph` will be returned.
--- `oper_name` is copied and has no lifetime requirements.
---@param oper_name string
---@param index number
function M:addReturnOutput(oper_name, index)
    lib.TF_ImportGraphDefOptionsAddReturnOutput(self.handle, oper_name, index)
end
--- Returns the number of return outputs added via
--- TF_ImportGraphDefOptionsAddReturnOutput().
---@return number
function M:numReturnOutputs()
    return tonumber(lib.TF_ImportGraphDefOptionsNumReturnOutputs(self.handle))
end
--- Add an operation in `graph_def` to be returned via the `return_opers` output
--- parameter of TF_GraphImportGraphDef(). `oper_name` is copied and has no
--- lifetime requirements.
---@param oper_name string
function M:addReturnOperation(oper_name)
    lib.TF_ImportGraphDefOptionsAddReturnOperation(self.handle, oper_name)
end
--- Returns the number of return operations added via
--- TF_ImportGraphDefOptionsAddReturnOperation().
---@return number
function M:numReturnOperations()
    return tonumber(lib.TF_ImportGraphDefOptionsNumReturnOperations(self.handle))
end

--

---@param enable boolean
function M:setValidateColocationConstraints(enable)
    require('tf.c._c_api_experimental').TF_ImportGraphDefOptionsSetValidateColocationConstraints(
            self.handle, require('tf.base').tfBool(enable))
end

return M
