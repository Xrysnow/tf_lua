local ffi = require('ffi')
local helper = require('tf_util.helper')

ffi.cdef(helper.loadFileString('tf_headers/tf_attrtype.h'))
ffi.cdef(helper.loadFileString('tf_headers/tf_datatype.h'))
ffi.cdef(helper.loadFileString('tf_headers/tf_status.h'))
ffi.cdef(helper.loadFileString('tf_headers/tf_tensor.h'))
ffi.cdef(helper.loadFileString('tf_headers/c_api.h'))
ffi.cdef(helper.loadFileString('tf_headers/c_api_eager.h'))

local is_win = ffi.os == 'Windows'

print('start load libtensorflow')

local lib
if is_win then
    lib = ffi.load('tensorflow.dll')
else
    lib = ffi.load('libtensorflow.so')
end

print('finish load libtensorflow')

---@class TF_Buffer
local TF_Buffer = {}
---@type ffi.cdata
--- const void*
TF_Buffer.data = nil
---@type number
--- size_t
TF_Buffer.length = nil
---@type function
--- void (*) (void* data, size_t length)
TF_Buffer.data_deallocator = nil

---@class TF_Input
local TF_Input = {}
---@type ffi.cdata
--- TF_Operation*
TF_Input.oper = nil
---@type number
--- int
TF_Input.index = nil

---@class TF_Output
local TF_Output = {}
---@type ffi.cdata
--- TF_Operation*
TF_Output.oper = nil
---@type number
--- int
TF_Output.index = nil

---@class TF_AttrMetadata
--- TF_AttrMetadata describes the value of an attribute on an operation.
local TF_AttrMetadata = {}
---@type number
--- unsigned char
---
--- A boolean: 1 if the attribute value is a list, 0 otherwise.
TF_AttrMetadata.is_list = nil
---@type number
--- int64_t
---
--- Length of the list if is_list is true. Undefined otherwise.
TF_AttrMetadata.list_size = nil
---@type number
--- TF_AttrType
---
--- Type of elements of the list if is_list != 0.
--- Type of the single value stored in the attribute if is_list == 0.
TF_AttrMetadata.type = nil
---@type number
--- int64_t
---
--- Total size the attribute value.
--- The units of total_size depend on is_list and type.
--- - (1) If type == TF_ATTR_STRING and is_list == 0
---     then total_size is the byte size of the string
---     valued attribute.
--- - (2) If type == TF_ATTR_STRING and is_list == 1
---     then total_size is the cumulative byte size
---     of all the strings in the list.
--- - (3) If type == TF_ATTR_SHAPE and is_list == 0
---     then total_size is the number of dimensions
---     of the shape valued attribute, or -1
---     if its rank is unknown.
--- - (4) If type == TF_ATTR_SHAPE and is_list == 1
---     then total_size is the cumulative number
---     of dimensions of all shapes in the list.
--- - (5) Otherwise, total_size is undefined.
TF_AttrMetadata.total_size = nil

---@class TF_WhileParams
local TF_WhileParams = {}
---@type number
--- const int
TF_WhileParams.ninputs = nil
---@type ffi.cdata
--- TF_Graph* const
---
--- The while condition graph. The inputs are the current values of the loop
--- variables. The output should be a scalar boolean.
TF_WhileParams.cond_graph = nil
---@type ffi.cdata
--- const TF_Output* const
TF_WhileParams.cond_inputs = nil
---@type ffi.cdata
--- TF_Output
TF_WhileParams.cond_output = nil
---@type ffi.cdata
--- TF_Graph* const
---
--- The loop body graph. The inputs are the current values of the loop
--- variables. The outputs are the updated values of the loop variables.
TF_WhileParams.body_graph = nil
---@type ffi.cdata
--- const TF_Output* const
TF_WhileParams.body_inputs = nil
---@type ffi.cdata
--- TF_Output* const
TF_WhileParams.body_outputs = nil
---@type string
--- const char*
---
--- Unique null-terminated name for this while loop. This is used as a prefix
--- for created operations.
TF_WhileParams.name = nil

return lib
