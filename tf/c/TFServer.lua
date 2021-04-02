---@class tf.TFServer
--- In-process TensorFlow server functionality, for use in distributed training.
--- A Server instance encapsulates a set of devices and a Session target that
--- can participate in distributed training. A server belongs to a cluster
--- (specified by a ClusterSpec), and corresponds to a particular task in a
--- named job. The server can communicate with any other server in the same
--- cluster.
local M = class('tf.TFServer')
local lib = require('tf.c._c_api')
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end
--- Destroy an in-process TensorFlow server, frees memory. If server is running
--- it will be stopped and joined.
function M:dtor()
    lib.TF_DeleteServer(self.handle)
    self.handle = nil
end
--- Starts an in-process TensorFlow server.
function M:start()
    local s = Status()
    lib.TF_ServerStart(self.handle, handle(s))
    s:assert()
end
--- Stops an in-process TensorFlow server.
function M:stop()
    local s = Status()
    lib.TF_ServerStop(self.handle, handle(s))
    s:assert()
end
--- Blocks until the server has been successfully stopped (via TF_ServerStop or
--- TF_ServerClose).
function M:join()
    local s = Status()
    lib.TF_ServerJoin(self.handle, handle(s))
    s:assert()
end
--- Returns the target string that can be provided to TF_SetTarget() to connect
--- a TF_Session to `server`.
---
--- The returned string is valid only until TF_DeleteServer is invoked.
function M:target()
    local ret = lib.TF_ServerTarget(self.handle)
    return ffi.string(ret)
end
--- Creates a new in-process TensorFlow server configured using a serialized
--- ServerDef protocol buffer provided via `proto` and `proto_len`.
---
--- The server will not serve any requests until TF_ServerStart is invoked.
--- The server will stop serving requests once TF_ServerStop or
--- TF_DeleteServer is invoked.
function M.NewServer(proto, proto_len)
    local s = require('tf.c.TFStatus')()
    local p = lib.TF_NewServer(proto, proto_len, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

return M
