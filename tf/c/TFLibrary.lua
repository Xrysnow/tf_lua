---@class tf.TFLibrary
--- TF_Library holds information about dynamically loaded TensorFlow plugins.
local M = class('tf.TFLibrary')
local lib = require('tf.c._c_api')
local Status = require('tf.c.TFStatus')

function M:ctor(hdl)
    assert(hdl and not ffi.isnullptr(hdl))
    self.handle = hdl
end
--- Frees the memory associated with the library handle.
--- Does NOT unload the library.
function M:dtor()
    lib.TF_DeleteLibraryHandle(self.handle)
    self.handle = nil
end
--- Get the OpList of OpDefs defined in the library pointed by lib_handle.
---
--- Returns a TF_Buffer. The memory pointed to by the result is owned by
--- lib_handle. The data in the buffer will be the serialized OpList proto for
--- ops defined in the library.
function M:getOpList()
    -- data_deallocator is NULL
    local ret = require('tf.c.TFBuffer')()
    ret.handle[0] = lib.TF_GetOpList(self.handle)
    return ret
end
--- Load the library specified by library_filename and register the ops and
--- kernels present in that library.
---
--- Pass "library_filename" to a platform-specific mechanism for dynamically
--- loading a library. The rules for determining the exact location of the
--- library are platform-specific and are not documented here.
---
--- On success, place OK in status and return the newly created library handle.
--- The caller owns the library handle.
---
--- On failure, place an error status in status and return NULL.
---@param library_filename string
function M.LoadLibrary(library_filename)
    local s = Status()
    local p = lib.TF_LoadLibrary(library_filename, handle(s))
    s:assert()
    if ffi.isnullptr(p) then
        return nil
    end
    return M(p)
end

return M
