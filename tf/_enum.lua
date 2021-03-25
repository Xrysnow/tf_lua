--
local M = {}

---@class TF_DataType
--- TF_DataType holds the type for a scalar value.  E.g., one slot in a tensor.
--- The enum values here are identical to corresponding values in types.proto.
local TF_DataType = {}
M.TF_DataType = TF_DataType
TF_DataType.FLOAT = 1
TF_DataType.DOUBLE = 2
TF_DataType.INT32 = 3  --- Int32 tensors are always in 'host' memory.
TF_DataType.UINT8 = 4
TF_DataType.INT16 = 5
TF_DataType.INT8 = 6
TF_DataType.STRING = 7
TF_DataType.COMPLEX64 = 8  --- Single-precision complex
TF_DataType.COMPLEX = 8    --- Old identifier kept for API backwards compatibility
TF_DataType.INT64 = 9
TF_DataType.BOOL = 10
TF_DataType.QINT8 = 11     --- Quantized int8
TF_DataType.QUINT8 = 12    --- Quantized uint8
TF_DataType.QINT32 = 13    --- Quantized int32
TF_DataType.BFLOAT16 = 14  --- Float32 truncated to 16 bits.  Only for cast ops.
TF_DataType.QINT16 = 15    --- Quantized int16
TF_DataType.QUINT16 = 16   --- Quantized uint16
TF_DataType.UINT16 = 17
TF_DataType.COMPLEX128 = 18  --- Double-precision complex
TF_DataType.HALF = 19
TF_DataType.RESOURCE = 20
TF_DataType.VARIANT = 21
TF_DataType.UINT32 = 22
TF_DataType.UINT64 = 23

---@class TF_AttrType
--- TF_AttrType describes the type of the value of an attribute on an operation.
local TF_AttrType = {}
M.TF_AttrType = TF_AttrType
TF_AttrType.STRING = 0
TF_AttrType.INT = 1
TF_AttrType.FLOAT = 2
TF_AttrType.BOOL = 3
TF_AttrType.TYPE = 4
TF_AttrType.SHAPE = 5
TF_AttrType.TENSOR = 6
TF_AttrType.PLACEHOLDER = 7
TF_AttrType.FUNC = 8

---@class TF_Code
--- TF_Code holds an error code.  The enum values here are identical to
--- corresponding values in error_codes.proto.
local TF_Code = {}
M.TF_Code = TF_Code
TF_Code.OK = 0
TF_Code.CANCELLED = 1
TF_Code.UNKNOWN = 2
TF_Code.INVALID_ARGUMENT = 3
TF_Code.DEADLINE_EXCEEDED = 4
TF_Code.NOT_FOUND = 5
TF_Code.ALREADY_EXISTS = 6
TF_Code.PERMISSION_DENIED = 7
TF_Code.UNAUTHENTICATED = 16
TF_Code.RESOURCE_EXHAUSTED = 8
TF_Code.FAILED_PRECONDITION = 9
TF_Code.ABORTED = 10
TF_Code.OUT_OF_RANGE = 11
TF_Code.UNIMPLEMENTED = 12
TF_Code.INTERNAL = 13
TF_Code.UNAVAILABLE = 14
TF_Code.DATA_LOSS = 15

---@class TFE_ContextDevicePlacementPolicy
--- Controls how to act when we try to run an operation on a given device but
--- some input tensors are not on that device.
local TFE_ContextDevicePlacementPolicy = {}
M.TFE_ContextDevicePlacementPolicy = TFE_ContextDevicePlacementPolicy
--- Running operations with input tensors on the wrong device will fail.
TFE_ContextDevicePlacementPolicy.EXPLICIT = 0
--- Copy the tensor to the right device but log a warning.
TFE_ContextDevicePlacementPolicy.WARN = 1
--- Silently copy the tensor, which has a performance cost since the operation
--- will be blocked till the copy completes. This is the default placement
--- policy.
TFE_ContextDevicePlacementPolicy.SILENT = 2
--- Placement policy which silently copies int32 tensors but not other dtypes.
TFE_ContextDevicePlacementPolicy.SILENT_FOR_INT32 = 3

return M
