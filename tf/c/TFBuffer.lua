---@class tf.TFBuffer
--- TF_Buffer holds a pointer to a block of data and its associated length.
--- Typically, the data consists of a serialized protocol buffer, but other data
--- may also be held in a buffer.
---
--- By default, TF_Buffer itself does not do any memory management of the
--- pointed-to block.  If need be, users of this struct should specify how to
--- deallocate the block by setting the `data_deallocator` function pointer.
local M = class('tf.TFBuffer')
local lib = require('tf.c._c_api')
local libex = require('tf.c._c_api_experimental')
local base = require('tf.base')

function M:ctor(hdl)
    if hdl then
        assert(hdl and not ffi.isnullptr(hdl))
        ---@type TF_Buffer
        self.handle = hdl
    else
        self.handle = lib.TF_NewBuffer()
    end
end

function M:dtor()
    lib.TF_DeleteBuffer(self.handle)
    self.handle = nil
    self['.data'] = nil
end

function M:data()
    return self.handle.data
end

function M:length()
    return self.handle.length
end

--- Makes a copy of the input and sets an appropriate deallocator.  Useful for
--- passing in read-only, input protobufs.
function M.NewBufferFromString(proto, proto_len)
    local p = lib.TF_NewBufferFromString(proto, proto_len)
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

--- Create a serialized tensorflow.ConfigProto proto, where:
---
--- a) ConfigProto.optimizer_options.global_jit_level is set to to ON_1 if
--- `enable_xla_compilation` is non-zero, and OFF otherwise.
--- b) ConfigProto.gpu_options.allow_growth is set to `gpu_memory_allow_growth`.
--- c) ConfigProto.device_count is set to `num_cpu_devices`.
---@param enable_xla_compilation boolean
---@param gpu_memory_allow_growth boolean
---@param num_cpu_devices number
function M.CreateConfig(
        enable_xla_compilation,
        gpu_memory_allow_growth,
        num_cpu_devices)
    local p = libex.TF_CreateConfig(
            base.tfBool(enable_xla_compilation),
            base.tfBool(gpu_memory_allow_growth),
            num_cpu_devices)
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

--- Create a serialized tensorflow.RunOptions proto, where RunOptions.trace_level
--- is set to FULL_TRACE if `enable_full_trace` is non-zero, and NO_TRACE
--- otherwise.
---@param enable_full_trace boolean
function M.CreateRunOptions(enable_full_trace)
    local p = libex.TF_CreateRunOptions(
            base.tfBool(enable_full_trace))
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

--- Create a serialized tensorflow.ServerDef proto.
---@param text_proto string
function M.CreateServerDef(text_proto)
    local s = require('tf.c.TFStatus')()
    local p = libex.TFE_GetServerDef(text_proto, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

--

---@param str string
function M.CreateFromString(str)
    assert(type(str) == 'string')
    local s = str
    local ret = M()
    ret.handle.data = ffi.cast('void*', s)
    ret.handle.length = #s
    ret['.data'] = s
    return ret
end

---@param path string
function M.CreateFromFile(path)
    if #path == 0 then
        error("invalid empty path")
    end
    local s = io.readfile(path, 'rb')
    if not s then
        error(("can't load file from %q"):format(path))
    end
    local ret = M()
    ret.handle.data = ffi.cast('void*', s)
    ret.handle.length = #s
    ret['.data'] = s
    return ret
end

return M
