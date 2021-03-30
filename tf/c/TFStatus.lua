---@class tf.TFStatus
local M = class('tf.Status')
local lib = require('tf.base')._lib
local Code = require('tf._enum').TF_Code

function M:ctor()
    self.handle = lib.TF_NewStatus()
end

function M:dtor()
    lib.TF_DeleteStatus(self.handle)
    self.handle = nil
end

function M:set(code, msg)
    assert(msg)
    if type(code) == 'string' then
        code = assert(Code[code:upper()])
    end
    lib.TF_SetStatus(self.handle, code, msg)
end

function M:clear()
    self:set(Code.OK, '')
end

function M:setFromIOError(error_code, context)
    lib.TF_SetStatusFromIOError(self.handle, error_code, context)
end

function M:getCode()
    return lib.TF_GetCode(self.handle)
end

function M:message()
    return ffi.string(lib.TF_Message(self.handle))
end

local function codeToString(code)
    for k, v in pairs(Code) do
        if code == v then
            return k
        end
    end
    return 'UNKNOWN'
end

function M:assert()
    local tf_code = self:getCode()
    if tf_code ~= Code.OK then
        local msg = self:message()
        error(("ERROR %s: %s"):format(codeToString(tf_code), msg))
    end
    return tf_code == Code.OK
end

function M:makeInternalError(errMsg)
    require('tf.c._c_api_experimental').TF_MakeInternalErrorStatus(self.handle, errMsg)
end

return M
