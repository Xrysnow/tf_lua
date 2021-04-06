--
local M = {}
local libex = require('tf.c._c_api_experimental')
local base = require('tf.base')

--- Set XLA's internal BuildXlaOpsPassFlags.tf_xla_enable_lazy_compilation to the
--- value of 'enabled'. Also returns the original value of that flag.
---
--- Use in tests to allow XLA to fallback to TF classic. This has global effect.
function M.setXlaEnableLazyCompilation(enable)
    libex.TF_SetXlaEnableLazyCompilation(base.tfBool(enable))
end

function M.setTfXlaCpuGlobalJit(enable)
    libex.TF_SetTfXlaCpuGlobalJit(base.tfBool(enable))
end

--- Sets XLA's auto jit mode according to the specified string, which is parsed
--- as if passed in XLA_FLAGS. This has global effect.
---@param mode string
function M.setXlaAutoJitMode(mode)
    libex.TF_SetXlaAutoJitMode(mode)
end

--- Sets XLA's minimum cluster size. This has global effect.
---@param size number
function M.setXlaMinClusterSize(size)
    libex.TF_SetXlaMinClusterSize(size)
end
--- Gets/Sets TF/XLA flag for whether(true) or not(false) to disable constant
--- folding. This is for testing to ensure that XLA is being tested rather than
--- Tensorflow's CPU implementation through constant folding.
function M.getXlaConstantFoldingDisabled()
    return libex.TF_GetXlaConstantFoldingDisabled() > 0
end

function M.setXlaConstantFoldingDisabled(should_enable)
    libex.TF_SetXlaConstantFoldingDisabled(base.tfBool(should_enable))
end

return M
