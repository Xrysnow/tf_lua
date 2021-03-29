---@class tf.TFSessionOptions
--- TF_SessionOptions holds options that can be passed during session creation.
local M = class('tf.TFSessionOptions')
local lib = require('tf.c._c_api')
local libex = require('tf.c._c_api_experimental')
local Status = require('tf.c.TFStatus')
local base = require('tf.base')

function M:ctor()
    self.handle = lib.TF_NewSessionOptions()
end
--- Destroy an options object.
function M:dtor()
    lib.TF_DeleteSessionOptions(self.handle)
    self.handle = nil
end
--- Set the target in TF_SessionOptions.options.
--- target can be empty, a single entry, or a comma separated list of entries.
--- Each entry is in one of the following formats :
--- "local"
--- ip:port
--- host:port
---@param target string
function M:setTarget(target)
    lib.TF_SetTarget(self.handle, target)
end
--- Set the config in TF_SessionOptions.options.
--- config should be a serialized tensorflow.ConfigProto proto.
--- If config was not parsed successfully as a ConfigProto, record the
--- error information in *status.
function M:setConfig(proto, proto_len)
    local s = Status()
    lib.TF_SetConfig(self.handle, proto, proto_len, handle(s))
    s:assert()
end

-- experimental

--- When `enable` is true, set
--- tensorflow.ConfigProto.OptimizerOptions.global_jit_level to ON_1, and also
--- set XLA flag values to prepare for XLA compilation. Otherwise set
--- global_jit_level to OFF.
---
--- This and the next API are syntax sugar over TF_SetConfig(), and is used by
--- clients that cannot read/write the tensorflow.ConfigProto proto.
--- TODO: Migrate to TF_CreateConfig() below.
function M:enableXLACompilation(enable)
    libex.TF_EnableXLACompilation(self.handle, base.tfBool(enable))
end

-- external

---@param gpu_memory_fraction number
function M:setGpuMemoryFraction(gpu_memory_fraction)
    assert(0 <= gpu_memory_fraction and gpu_memory_fraction <= 1)
    local value = ffi.new('double[1]', gpu_memory_fraction)
    local bytes = ffi.cast('char*', value)
    local cfg = { 0x32, 0xb, 0x9, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x20, 0x1, 0x38, 0x1 }
    local n = 15
    local config = ffi.new('char[?]', n)
    for i = 1, n do
        config[i - 1] = cfg[i]
    end
    for i = 1, ffi.sizeof('double') do
        config[i - 1 + 3] = bytes[i - 1]
    end
    self:setConfig(config, n)
end

---@param intra_op_threads number
---@param inter_op_threads number
function M:setOpParallelismThreads(intra_op_threads, inter_op_threads)
    local cfg = { 0x10, intra_op_threads, 0x28, inter_op_threads }
    local n = #cfg
    local config = ffi.new('char[?]', n)
    for i = 1, n do
        config[i - 1] = cfg[i]
    end
    self:setConfig(config, n)
end

return M
