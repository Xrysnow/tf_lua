---@class tfe.TFEContextOptions
local M = class('tfe.TFEContextOptions')
local base = require('tf.base')
local lib = base._libeager
local libeex = base._libeagerex
local Status = require('tf.c.TFStatus')

function M:ctor()
    self.handle = lib.TFE_NewContextOptions()
end
--- Destroy an options object.
function M:dtor()
    lib.TFE_DeleteContextOptions(self.handle)
    self.handle = nil
end
--- Set the config in TF_ContextOptions.options.
--- config should be a serialized tensorflow.ConfigProto proto.
--- If config was not parsed successfully as a ConfigProto, record the
--- error information in *status.
function M:setConfig(proto, proto_len)
    local s = Status()
    lib.TFE_ContextOptionsSetConfig(self.handle, proto, proto_len or #proto, handle(s))
    s:assert()
end
--- Sets the default execution mode (sync/async). Note that this can be
--- overridden per thread using TFE_ContextSetExecutorForThread.
function M:setAsync(enable)
    lib.TFE_ContextOptionsSetAsync(self.handle, base.tfBool(enable))
end

function M:setDevicePlacementPolicy(policy)
    lib.TFE_ContextOptionsSetDevicePlacementPolicy(self.handle, policy)
end

--

--- Sets whether to copy the remote inputs of a function lazily.
---@param lazy_copy boolean
function M:setLazyRemoteInputsCopy(lazy_copy)
    libeex.TFE_ContextOptionsSetLazyRemoteInputsCopy(self.handle, lazy_copy)
end

--- Sets whether to use TFRT
---@param use_tfrt boolean
function M:setTfrt(use_tfrt)
    libeex.TFE_ContextOptionsSetTfrt(self.handle, use_tfrt)
end

return M
