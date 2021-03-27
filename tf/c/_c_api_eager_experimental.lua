--

local M = {}
local _TYPEDEF = require('tf.c.ctypes').typedef
local _ENUMDEF = require('tf.c.ctypes').enumdef
local _CALL = require('tf.c.ctypes').caller(require('tf.c._lib'))
local _FUNCDEF = require('tf.c.ctypes').addDef
-- header/c_api_eager_experimental.h

--

--- Resets `op_to_reset` with `op_or_function_name` and `raw_device_name`. This
--- is for performance optimization by reusing an exiting unused op rather than
--- creating a new op every time. If `raw_device_name` is `NULL` or empty, it
--- does not set the device name. If it's not `NULL`, then it attempts to parse
--- and set the device name. It's effectively `TFE_OpSetDevice`, but it is faster
--- than separately calling it because if the existing op has the same
--- `raw_device_name`, it skips parsing and just leave as it is.
--- 
---@param op_to_reset ffi.cdata @(TFE_Op *)
---@param op_or_function_name string @(const char *)
---@param raw_device_name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_OpReset(op_to_reset, op_or_function_name, raw_device_name, status)
    return _CALL("TFE_OpReset", op_to_reset, op_or_function_name, raw_device_name, status)
end
_FUNCDEF("TFE_OpReset", { "TFE_Op *", "const char *", "const char *", "TF_Status *" }, "void")

--

--- Enables only graph collection in RunMetadata on the functions executed from
--- this context.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
function M.TFE_ContextEnableGraphCollection(ctx)
    return _CALL("TFE_ContextEnableGraphCollection", ctx)
end
_FUNCDEF("TFE_ContextEnableGraphCollection", { "TFE_Context *" }, "void")

--

--- Disables only graph collection in RunMetadata on the functions executed from
--- this context.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
function M.TFE_ContextDisableGraphCollection(ctx)
    return _CALL("TFE_ContextDisableGraphCollection", ctx)
end
_FUNCDEF("TFE_ContextDisableGraphCollection", { "TFE_Context *" }, "void")

--

--- TODO(fishx): Move these monitoring APIs into a separate file.
--- -----------------------------------------------------------------------------
--- Monitoring Counter APIs.
--- These APIs de-templated monitoring Counter for swig.
--- 

_TYPEDEF("TFE_MonitoringCounterCell", "struct TFE_MonitoringCounterCell")

--

--- Atomically increments the value of the cell. The value must be non-negative.
--- 
---@param cell ffi.cdata @(TFE_MonitoringCounterCell *)
---@param value number @(int64_t)
function M.TFE_MonitoringCounterCellIncrementBy(cell, value)
    return _CALL("TFE_MonitoringCounterCellIncrementBy", cell, value)
end
_FUNCDEF("TFE_MonitoringCounterCellIncrementBy", { "TFE_MonitoringCounterCell *", "int64_t" }, "void")

--

--- Retrieves the current value of the cell.
--- 
---@param cell ffi.cdata @(TFE_MonitoringCounterCell *)
---@return number @(int64_t)
function M.TFE_MonitoringCounterCellValue(cell)
    return _CALL("TFE_MonitoringCounterCellValue", cell)
end
_FUNCDEF("TFE_MonitoringCounterCellValue", { "TFE_MonitoringCounterCell *" }, "int64_t")

--

--- APIs for Counter without label.
--- 

_TYPEDEF("TFE_MonitoringCounter0", "struct TFE_MonitoringCounter0")

--

--- Returns a new Counter metric object. The caller should manage lifetime of
--- the object. Using duplicate metric name will crash the program with fatal
--- error.
--- 
---@param name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@return ffi.cdata @(TFE_MonitoringCounter0 *)
function M.TFE_MonitoringNewCounter0(name, status, description)
    return _CALL("TFE_MonitoringNewCounter0", name, status, description)
end
_FUNCDEF("TFE_MonitoringNewCounter0", { "const char *", "TF_Status *", "const char *" }, "TFE_MonitoringCounter0 *")

--

--- Deletes the Counter object.
--- 
---@param counter ffi.cdata @(TFE_MonitoringCounter0 *)
function M.TFE_MonitoringDeleteCounter0(counter)
    return _CALL("TFE_MonitoringDeleteCounter0", counter)
end
_FUNCDEF("TFE_MonitoringDeleteCounter0", { "TFE_MonitoringCounter0 *" }, "void")

--

--- Retrieves the cell from the Counter object. The Counter object will manage
--- lifetime of the cell.
--- 
---@param counter ffi.cdata @(TFE_MonitoringCounter0 *)
---@return ffi.cdata @(TFE_MonitoringCounterCell *)
function M.TFE_MonitoringGetCellCounter0(counter)
    return _CALL("TFE_MonitoringGetCellCounter0", counter)
end
_FUNCDEF("TFE_MonitoringGetCellCounter0", { "TFE_MonitoringCounter0 *" }, "TFE_MonitoringCounterCell *")

--

--- APIs for Counter with 1 label.
--- 

_TYPEDEF("TFE_MonitoringCounter1", "struct TFE_MonitoringCounter1")

--

---@param name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@param label1 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringCounter1 *)
function M.TFE_MonitoringNewCounter1(name, status, description, label1)
    return _CALL("TFE_MonitoringNewCounter1", name, status, description, label1)
end
_FUNCDEF("TFE_MonitoringNewCounter1", { "const char *", "TF_Status *", "const char *", "const char *" }, "TFE_MonitoringCounter1 *")

--

---@param counter ffi.cdata @(TFE_MonitoringCounter1 *)
function M.TFE_MonitoringDeleteCounter1(counter)
    return _CALL("TFE_MonitoringDeleteCounter1", counter)
end
_FUNCDEF("TFE_MonitoringDeleteCounter1", { "TFE_MonitoringCounter1 *" }, "void")

--

---@param counter ffi.cdata @(TFE_MonitoringCounter1 *)
---@param label1 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringCounterCell *)
function M.TFE_MonitoringGetCellCounter1(counter, label1)
    return _CALL("TFE_MonitoringGetCellCounter1", counter, label1)
end
_FUNCDEF("TFE_MonitoringGetCellCounter1", { "TFE_MonitoringCounter1 *", "const char *" }, "TFE_MonitoringCounterCell *")

--

--- APIs for Counter with 2 labels.
--- 

_TYPEDEF("TFE_MonitoringCounter2", "struct TFE_MonitoringCounter2")

--

---@param name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@param label1 string @(const char *)
---@param label2 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringCounter2 *)
function M.TFE_MonitoringNewCounter2(name, status, description, label1, label2)
    return _CALL("TFE_MonitoringNewCounter2", name, status, description, label1, label2)
end
_FUNCDEF("TFE_MonitoringNewCounter2", { "const char *", "TF_Status *", "const char *", "const char *", "const char *" }, "TFE_MonitoringCounter2 *")

--

---@param counter ffi.cdata @(TFE_MonitoringCounter2 *)
function M.TFE_MonitoringDeleteCounter2(counter)
    return _CALL("TFE_MonitoringDeleteCounter2", counter)
end
_FUNCDEF("TFE_MonitoringDeleteCounter2", { "TFE_MonitoringCounter2 *" }, "void")

--

---@param counter ffi.cdata @(TFE_MonitoringCounter2 *)
---@param label1 string @(const char *)
---@param label2 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringCounterCell *)
function M.TFE_MonitoringGetCellCounter2(counter, label1, label2)
    return _CALL("TFE_MonitoringGetCellCounter2", counter, label1, label2)
end
_FUNCDEF("TFE_MonitoringGetCellCounter2", { "TFE_MonitoringCounter2 *", "const char *", "const char *" }, "TFE_MonitoringCounterCell *")

--

--- -----------------------------------------------------------------------------
--- Monitoring Gauge APIs.
--- These APIs de-templated monitoring Gauge for swig.
--- 

_TYPEDEF("TFE_MonitoringIntGaugeCell", "struct TFE_MonitoringIntGaugeCell")

--

--- Atomically set the value of the cell.
--- 
---@param cell ffi.cdata @(TFE_MonitoringIntGaugeCell *)
---@param value number @(int64_t)
function M.TFE_MonitoringIntGaugeCellSet(cell, value)
    return _CALL("TFE_MonitoringIntGaugeCellSet", cell, value)
end
_FUNCDEF("TFE_MonitoringIntGaugeCellSet", { "TFE_MonitoringIntGaugeCell *", "int64_t" }, "void")

--

--- Retrieves the current value of the cell.
--- 
---@param cell ffi.cdata @(TFE_MonitoringIntGaugeCell *)
---@return number @(int64_t)
function M.TFE_MonitoringIntGaugeCellValue(cell)
    return _CALL("TFE_MonitoringIntGaugeCellValue", cell)
end
_FUNCDEF("TFE_MonitoringIntGaugeCellValue", { "TFE_MonitoringIntGaugeCell *" }, "int64_t")

--

--- APIs for Int Gauge without label.
--- 

_TYPEDEF("TFE_MonitoringIntGauge0", "struct TFE_MonitoringIntGauge0")

--

---@param name string @(const char *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@return ffi.cdata @(TFE_MonitoringIntGauge0 *)
function M.TFE_MonitoringNewIntGauge0(name, out_status, description)
    return _CALL("TFE_MonitoringNewIntGauge0", name, out_status, description)
end
_FUNCDEF("TFE_MonitoringNewIntGauge0", { "const char *", "TF_Status *", "const char *" }, "TFE_MonitoringIntGauge0 *")

--

---@param gauge ffi.cdata @(TFE_MonitoringIntGauge0 *)
function M.TFE_MonitoringDeleteIntGauge0(gauge)
    return _CALL("TFE_MonitoringDeleteIntGauge0", gauge)
end
_FUNCDEF("TFE_MonitoringDeleteIntGauge0", { "TFE_MonitoringIntGauge0 *" }, "void")

--

---@param gauge ffi.cdata @(TFE_MonitoringIntGauge0 *)
---@return ffi.cdata @(TFE_MonitoringIntGaugeCell *)
function M.TFE_MonitoringGetCellIntGauge0(gauge)
    return _CALL("TFE_MonitoringGetCellIntGauge0", gauge)
end
_FUNCDEF("TFE_MonitoringGetCellIntGauge0", { "TFE_MonitoringIntGauge0 *" }, "TFE_MonitoringIntGaugeCell *")

--

--- APIs for Int Gauge with 1 label.
--- 

_TYPEDEF("TFE_MonitoringIntGauge1", "struct TFE_MonitoringIntGauge1")

--

---@param name string @(const char *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@param label1 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringIntGauge1 *)
function M.TFE_MonitoringNewIntGauge1(name, out_status, description, label1)
    return _CALL("TFE_MonitoringNewIntGauge1", name, out_status, description, label1)
end
_FUNCDEF("TFE_MonitoringNewIntGauge1", { "const char *", "TF_Status *", "const char *", "const char *" }, "TFE_MonitoringIntGauge1 *")

--

---@param gauge ffi.cdata @(TFE_MonitoringIntGauge1 *)
function M.TFE_MonitoringDeleteIntGauge1(gauge)
    return _CALL("TFE_MonitoringDeleteIntGauge1", gauge)
end
_FUNCDEF("TFE_MonitoringDeleteIntGauge1", { "TFE_MonitoringIntGauge1 *" }, "void")

--

---@param gauge ffi.cdata @(TFE_MonitoringIntGauge1 *)
---@param label1 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringIntGaugeCell *)
function M.TFE_MonitoringGetCellIntGauge1(gauge, label1)
    return _CALL("TFE_MonitoringGetCellIntGauge1", gauge, label1)
end
_FUNCDEF("TFE_MonitoringGetCellIntGauge1", { "TFE_MonitoringIntGauge1 *", "const char *" }, "TFE_MonitoringIntGaugeCell *")

--

--- APIs for Int Gauge with 2 label.
--- 

_TYPEDEF("TFE_MonitoringIntGauge2", "struct TFE_MonitoringIntGauge2")

--

---@param name string @(const char *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@param label1 string @(const char *)
---@param label2 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringIntGauge2 *)
function M.TFE_MonitoringNewIntGauge2(name, out_status, description, label1, label2)
    return _CALL("TFE_MonitoringNewIntGauge2", name, out_status, description, label1, label2)
end
_FUNCDEF("TFE_MonitoringNewIntGauge2", { "const char *", "TF_Status *", "const char *", "const char *", "const char *" }, "TFE_MonitoringIntGauge2 *")

--

---@param gauge ffi.cdata @(TFE_MonitoringIntGauge2 *)
function M.TFE_MonitoringDeleteIntGauge2(gauge)
    return _CALL("TFE_MonitoringDeleteIntGauge2", gauge)
end
_FUNCDEF("TFE_MonitoringDeleteIntGauge2", { "TFE_MonitoringIntGauge2 *" }, "void")

--

---@param gauge ffi.cdata @(TFE_MonitoringIntGauge2 *)
---@param label1 string @(const char *)
---@param label2 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringIntGaugeCell *)
function M.TFE_MonitoringGetCellIntGauge2(gauge, label1, label2)
    return _CALL("TFE_MonitoringGetCellIntGauge2", gauge, label1, label2)
end
_FUNCDEF("TFE_MonitoringGetCellIntGauge2", { "TFE_MonitoringIntGauge2 *", "const char *", "const char *" }, "TFE_MonitoringIntGaugeCell *")

--

_TYPEDEF("TFE_MonitoringStringGaugeCell", "struct TFE_MonitoringStringGaugeCell")

--

---@param cell ffi.cdata @(TFE_MonitoringStringGaugeCell *)
---@param value string @(const char *)
function M.TFE_MonitoringStringGaugeCellSet(cell, value)
    return _CALL("TFE_MonitoringStringGaugeCellSet", cell, value)
end
_FUNCDEF("TFE_MonitoringStringGaugeCellSet", { "TFE_MonitoringStringGaugeCell *", "const char *" }, "void")

--

--- Retrieves the string value and saves it in buffer.
--- 
---@param cell ffi.cdata @(TFE_MonitoringStringGaugeCell *)
---@param buf ffi.cdata @(TF_Buffer *)
---@return const void @(const void)
function M.TFE_MonitoringStringGaugeCellValue(cell, buf)
    return _CALL("TFE_MonitoringStringGaugeCellValue", cell, buf)
end
_FUNCDEF("TFE_MonitoringStringGaugeCellValue", { "TFE_MonitoringStringGaugeCell *", "TF_Buffer *" }, "const void")

--

--- APIs for String Gauge without label.
--- 

_TYPEDEF("TFE_MonitoringStringGauge0", "struct TFE_MonitoringStringGauge0")

--

---@param name string @(const char *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@return ffi.cdata @(TFE_MonitoringStringGauge0 *)
function M.TFE_MonitoringNewStringGauge0(name, out_status, description)
    return _CALL("TFE_MonitoringNewStringGauge0", name, out_status, description)
end
_FUNCDEF("TFE_MonitoringNewStringGauge0", { "const char *", "TF_Status *", "const char *" }, "TFE_MonitoringStringGauge0 *")

--

---@param gauge ffi.cdata @(TFE_MonitoringStringGauge0 *)
function M.TFE_MonitoringDeleteStringGauge0(gauge)
    return _CALL("TFE_MonitoringDeleteStringGauge0", gauge)
end
_FUNCDEF("TFE_MonitoringDeleteStringGauge0", { "TFE_MonitoringStringGauge0 *" }, "void")

--

---@param gauge ffi.cdata @(TFE_MonitoringStringGauge0 *)
---@return ffi.cdata @(TFE_MonitoringStringGaugeCell *)
function M.TFE_MonitoringGetCellStringGauge0(gauge)
    return _CALL("TFE_MonitoringGetCellStringGauge0", gauge)
end
_FUNCDEF("TFE_MonitoringGetCellStringGauge0", { "TFE_MonitoringStringGauge0 *" }, "TFE_MonitoringStringGaugeCell *")

--

--- APIs for String Gauge with 1 label.
--- 

_TYPEDEF("TFE_MonitoringStringGauge1", "struct TFE_MonitoringStringGauge1")

--

---@param name string @(const char *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@param label1 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringStringGauge1 *)
function M.TFE_MonitoringNewStringGauge1(name, out_status, description, label1)
    return _CALL("TFE_MonitoringNewStringGauge1", name, out_status, description, label1)
end
_FUNCDEF("TFE_MonitoringNewStringGauge1", { "const char *", "TF_Status *", "const char *", "const char *" }, "TFE_MonitoringStringGauge1 *")

--

---@param gauge ffi.cdata @(TFE_MonitoringStringGauge1 *)
function M.TFE_MonitoringDeleteStringGauge1(gauge)
    return _CALL("TFE_MonitoringDeleteStringGauge1", gauge)
end
_FUNCDEF("TFE_MonitoringDeleteStringGauge1", { "TFE_MonitoringStringGauge1 *" }, "void")

--

---@param gauge ffi.cdata @(TFE_MonitoringStringGauge1 *)
---@param label1 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringStringGaugeCell *)
function M.TFE_MonitoringGetCellStringGauge1(gauge, label1)
    return _CALL("TFE_MonitoringGetCellStringGauge1", gauge, label1)
end
_FUNCDEF("TFE_MonitoringGetCellStringGauge1", { "TFE_MonitoringStringGauge1 *", "const char *" }, "TFE_MonitoringStringGaugeCell *")

--

--- APIs for String Gauge with 2 label.
--- 

_TYPEDEF("TFE_MonitoringStringGauge2", "struct TFE_MonitoringStringGauge2")

--

---@param name string @(const char *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@param label1 string @(const char *)
---@param label2 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringStringGauge2 *)
function M.TFE_MonitoringNewStringGauge2(name, out_status, description, label1, label2)
    return _CALL("TFE_MonitoringNewStringGauge2", name, out_status, description, label1, label2)
end
_FUNCDEF("TFE_MonitoringNewStringGauge2", { "const char *", "TF_Status *", "const char *", "const char *", "const char *" }, "TFE_MonitoringStringGauge2 *")

--

---@param gauge ffi.cdata @(TFE_MonitoringStringGauge2 *)
function M.TFE_MonitoringDeleteStringGauge2(gauge)
    return _CALL("TFE_MonitoringDeleteStringGauge2", gauge)
end
_FUNCDEF("TFE_MonitoringDeleteStringGauge2", { "TFE_MonitoringStringGauge2 *" }, "void")

--

---@param gauge ffi.cdata @(TFE_MonitoringStringGauge2 *)
---@param label1 string @(const char *)
---@param label2 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringStringGaugeCell *)
function M.TFE_MonitoringGetCellStringGauge2(gauge, label1, label2)
    return _CALL("TFE_MonitoringGetCellStringGauge2", gauge, label1, label2)
end
_FUNCDEF("TFE_MonitoringGetCellStringGauge2", { "TFE_MonitoringStringGauge2 *", "const char *", "const char *" }, "TFE_MonitoringStringGaugeCell *")

--

_TYPEDEF("TFE_MonitoringBoolGaugeCell", "struct TFE_MonitoringBoolGaugeCell")

--

---@param cell ffi.cdata @(TFE_MonitoringBoolGaugeCell *)
---@param value boolean @(bool)
function M.TFE_MonitoringBoolGaugeCellSet(cell, value)
    return _CALL("TFE_MonitoringBoolGaugeCellSet", cell, value)
end
_FUNCDEF("TFE_MonitoringBoolGaugeCellSet", { "TFE_MonitoringBoolGaugeCell *", "bool" }, "void")

--

---@param cell ffi.cdata @(TFE_MonitoringBoolGaugeCell *)
---@return boolean @(bool)
function M.TFE_MonitoringBoolGaugeCellValue(cell)
    return _CALL("TFE_MonitoringBoolGaugeCellValue", cell)
end
_FUNCDEF("TFE_MonitoringBoolGaugeCellValue", { "TFE_MonitoringBoolGaugeCell *" }, "bool")

--

--- APIs for Bool Gauge without label.
--- 

_TYPEDEF("TFE_MonitoringBoolGauge0", "struct TFE_MonitoringBoolGauge0")

--

---@param name string @(const char *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@return ffi.cdata @(TFE_MonitoringBoolGauge0 *)
function M.TFE_MonitoringNewBoolGauge0(name, out_status, description)
    return _CALL("TFE_MonitoringNewBoolGauge0", name, out_status, description)
end
_FUNCDEF("TFE_MonitoringNewBoolGauge0", { "const char *", "TF_Status *", "const char *" }, "TFE_MonitoringBoolGauge0 *")

--

---@param gauge ffi.cdata @(TFE_MonitoringBoolGauge0 *)
function M.TFE_MonitoringDeleteBoolGauge0(gauge)
    return _CALL("TFE_MonitoringDeleteBoolGauge0", gauge)
end
_FUNCDEF("TFE_MonitoringDeleteBoolGauge0", { "TFE_MonitoringBoolGauge0 *" }, "void")

--

---@param gauge ffi.cdata @(TFE_MonitoringBoolGauge0 *)
---@return ffi.cdata @(TFE_MonitoringBoolGaugeCell *)
function M.TFE_MonitoringGetCellBoolGauge0(gauge)
    return _CALL("TFE_MonitoringGetCellBoolGauge0", gauge)
end
_FUNCDEF("TFE_MonitoringGetCellBoolGauge0", { "TFE_MonitoringBoolGauge0 *" }, "TFE_MonitoringBoolGaugeCell *")

--

--- APIs for Bool Gauge with 1 label.
--- 

_TYPEDEF("TFE_MonitoringBoolGauge1", "struct TFE_MonitoringBoolGauge1")

--

---@param name string @(const char *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@param label1 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringBoolGauge1 *)
function M.TFE_MonitoringNewBoolGauge1(name, out_status, description, label1)
    return _CALL("TFE_MonitoringNewBoolGauge1", name, out_status, description, label1)
end
_FUNCDEF("TFE_MonitoringNewBoolGauge1", { "const char *", "TF_Status *", "const char *", "const char *" }, "TFE_MonitoringBoolGauge1 *")

--

---@param gauge ffi.cdata @(TFE_MonitoringBoolGauge1 *)
function M.TFE_MonitoringDeleteBoolGauge1(gauge)
    return _CALL("TFE_MonitoringDeleteBoolGauge1", gauge)
end
_FUNCDEF("TFE_MonitoringDeleteBoolGauge1", { "TFE_MonitoringBoolGauge1 *" }, "void")

--

---@param gauge ffi.cdata @(TFE_MonitoringBoolGauge1 *)
---@param label1 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringBoolGaugeCell *)
function M.TFE_MonitoringGetCellBoolGauge1(gauge, label1)
    return _CALL("TFE_MonitoringGetCellBoolGauge1", gauge, label1)
end
_FUNCDEF("TFE_MonitoringGetCellBoolGauge1", { "TFE_MonitoringBoolGauge1 *", "const char *" }, "TFE_MonitoringBoolGaugeCell *")

--

--- APIs for Bool Gauge with 2 label.
--- 

_TYPEDEF("TFE_MonitoringBoolGauge2", "struct TFE_MonitoringBoolGauge2")

--

---@param name string @(const char *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@param label1 string @(const char *)
---@param label2 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringBoolGauge2 *)
function M.TFE_MonitoringNewBoolGauge2(name, out_status, description, label1, label2)
    return _CALL("TFE_MonitoringNewBoolGauge2", name, out_status, description, label1, label2)
end
_FUNCDEF("TFE_MonitoringNewBoolGauge2", { "const char *", "TF_Status *", "const char *", "const char *", "const char *" }, "TFE_MonitoringBoolGauge2 *")

--

---@param gauge ffi.cdata @(TFE_MonitoringBoolGauge2 *)
function M.TFE_MonitoringDeleteBoolGauge2(gauge)
    return _CALL("TFE_MonitoringDeleteBoolGauge2", gauge)
end
_FUNCDEF("TFE_MonitoringDeleteBoolGauge2", { "TFE_MonitoringBoolGauge2 *" }, "void")

--

---@param gauge ffi.cdata @(TFE_MonitoringBoolGauge2 *)
---@param label1 string @(const char *)
---@param label2 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringBoolGaugeCell *)
function M.TFE_MonitoringGetCellBoolGauge2(gauge, label1, label2)
    return _CALL("TFE_MonitoringGetCellBoolGauge2", gauge, label1, label2)
end
_FUNCDEF("TFE_MonitoringGetCellBoolGauge2", { "TFE_MonitoringBoolGauge2 *", "const char *", "const char *" }, "TFE_MonitoringBoolGaugeCell *")

--

--- -----------------------------------------------------------------------------
--- Monitoring Sampler APIs.
--- These APIs de-templated monitoring Sampler for swig.
--- 

_TYPEDEF("TFE_MonitoringSamplerCell", "struct TFE_MonitoringSamplerCell")

--

--- Atomically add the value of the cell.
--- 
---@param cell ffi.cdata @(TFE_MonitoringSamplerCell *)
---@param value number @(double)
function M.TFE_MonitoringSamplerCellAdd(cell, value)
    return _CALL("TFE_MonitoringSamplerCellAdd", cell, value)
end
_FUNCDEF("TFE_MonitoringSamplerCellAdd", { "TFE_MonitoringSamplerCell *", "double" }, "void")

--

--- Retrieves the current value of the cell. The return value is a HistogramProto
--- saved in buffer.
--- 
---@param cell ffi.cdata @(TFE_MonitoringSamplerCell *)
---@param buf ffi.cdata @(TF_Buffer *)
function M.TFE_MonitoringSamplerCellValue(cell, buf)
    return _CALL("TFE_MonitoringSamplerCellValue", cell, buf)
end
_FUNCDEF("TFE_MonitoringSamplerCellValue", { "TFE_MonitoringSamplerCell *", "TF_Buffer *" }, "void")

--

--- APIs for sampler buckets
--- 

_TYPEDEF("TFE_MonitoringBuckets", "struct TFE_MonitoringBuckets")

--

---@param scale number @(double)
---@param growth_factor number @(double)
---@param bucket_count number @(int)
---@return ffi.cdata @(TFE_MonitoringBuckets *)
function M.TFE_MonitoringNewExponentialBuckets(scale, growth_factor, bucket_count)
    return _CALL("TFE_MonitoringNewExponentialBuckets", scale, growth_factor, bucket_count)
end
_FUNCDEF("TFE_MonitoringNewExponentialBuckets", { "double", "double", "int" }, "TFE_MonitoringBuckets *")

--

---@param buckets ffi.cdata @(TFE_MonitoringBuckets *)
function M.TFE_MonitoringDeleteBuckets(buckets)
    return _CALL("TFE_MonitoringDeleteBuckets", buckets)
end
_FUNCDEF("TFE_MonitoringDeleteBuckets", { "TFE_MonitoringBuckets *" }, "void")

--

--- APIs for Sampler without label.
--- 

_TYPEDEF("TFE_MonitoringSampler0", "struct TFE_MonitoringSampler0")

--

---@param name string @(const char *)
---@param buckets ffi.cdata @(TFE_MonitoringBuckets *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@return ffi.cdata @(TFE_MonitoringSampler0 *)
function M.TFE_MonitoringNewSampler0(name, buckets, out_status, description)
    return _CALL("TFE_MonitoringNewSampler0", name, buckets, out_status, description)
end
_FUNCDEF("TFE_MonitoringNewSampler0", { "const char *", "TFE_MonitoringBuckets *", "TF_Status *", "const char *" }, "TFE_MonitoringSampler0 *")

--

---@param sampler ffi.cdata @(TFE_MonitoringSampler0 *)
function M.TFE_MonitoringDeleteSampler0(sampler)
    return _CALL("TFE_MonitoringDeleteSampler0", sampler)
end
_FUNCDEF("TFE_MonitoringDeleteSampler0", { "TFE_MonitoringSampler0 *" }, "void")

--

---@param sampler ffi.cdata @(TFE_MonitoringSampler0 *)
---@return ffi.cdata @(TFE_MonitoringSamplerCell *)
function M.TFE_MonitoringGetCellSampler0(sampler)
    return _CALL("TFE_MonitoringGetCellSampler0", sampler)
end
_FUNCDEF("TFE_MonitoringGetCellSampler0", { "TFE_MonitoringSampler0 *" }, "TFE_MonitoringSamplerCell *")

--

--- APIs for Sampler with 1 label.
--- 

_TYPEDEF("TFE_MonitoringSampler1", "struct TFE_MonitoringSampler1")

--

---@param name string @(const char *)
---@param buckets ffi.cdata @(TFE_MonitoringBuckets *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@param label1 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringSampler1 *)
function M.TFE_MonitoringNewSampler1(name, buckets, out_status, description, label1)
    return _CALL("TFE_MonitoringNewSampler1", name, buckets, out_status, description, label1)
end
_FUNCDEF("TFE_MonitoringNewSampler1", { "const char *", "TFE_MonitoringBuckets *", "TF_Status *", "const char *", "const char *" }, "TFE_MonitoringSampler1 *")

--

---@param sampler ffi.cdata @(TFE_MonitoringSampler1 *)
function M.TFE_MonitoringDeleteSampler1(sampler)
    return _CALL("TFE_MonitoringDeleteSampler1", sampler)
end
_FUNCDEF("TFE_MonitoringDeleteSampler1", { "TFE_MonitoringSampler1 *" }, "void")

--

---@param sampler ffi.cdata @(TFE_MonitoringSampler1 *)
---@param label1 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringSamplerCell *)
function M.TFE_MonitoringGetCellSampler1(sampler, label1)
    return _CALL("TFE_MonitoringGetCellSampler1", sampler, label1)
end
_FUNCDEF("TFE_MonitoringGetCellSampler1", { "TFE_MonitoringSampler1 *", "const char *" }, "TFE_MonitoringSamplerCell *")

--

--- APIs for Sampler with 2 label.
--- 

_TYPEDEF("TFE_MonitoringSampler2", "struct TFE_MonitoringSampler2")

--

---@param name string @(const char *)
---@param buckets ffi.cdata @(TFE_MonitoringBuckets *)
---@param out_status ffi.cdata @(TF_Status *)
---@param description string @(const char *)
---@param label1 string @(const char *)
---@param label2 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringSampler2 *)
function M.TFE_MonitoringNewSampler2(name, buckets, out_status, description, label1, label2)
    return _CALL("TFE_MonitoringNewSampler2", name, buckets, out_status, description, label1, label2)
end
_FUNCDEF("TFE_MonitoringNewSampler2", { "const char *", "TFE_MonitoringBuckets *", "TF_Status *", "const char *", "const char *", "const char *" }, "TFE_MonitoringSampler2 *")

--

---@param sampler ffi.cdata @(TFE_MonitoringSampler2 *)
function M.TFE_MonitoringDeleteSampler2(sampler)
    return _CALL("TFE_MonitoringDeleteSampler2", sampler)
end
_FUNCDEF("TFE_MonitoringDeleteSampler2", { "TFE_MonitoringSampler2 *" }, "void")

--

---@param sampler ffi.cdata @(TFE_MonitoringSampler2 *)
---@param label1 string @(const char *)
---@param label2 string @(const char *)
---@return ffi.cdata @(TFE_MonitoringSamplerCell *)
function M.TFE_MonitoringGetCellSampler2(sampler, label1, label2)
    return _CALL("TFE_MonitoringGetCellSampler2", sampler, label1, label2)
end
_FUNCDEF("TFE_MonitoringGetCellSampler2", { "TFE_MonitoringSampler2 *", "const char *", "const char *" }, "TFE_MonitoringSamplerCell *")

--

--- Sets whether to copy the remote inputs of a function lazily.
--- 
---@param opts ffi.cdata @(TFE_ContextOptions *)
---@param lazy_copy boolean @(bool)
function M.TFE_ContextOptionsSetLazyRemoteInputsCopy(opts, lazy_copy)
    return _CALL("TFE_ContextOptionsSetLazyRemoteInputsCopy", opts, lazy_copy)
end
_FUNCDEF("TFE_ContextOptionsSetLazyRemoteInputsCopy", { "TFE_ContextOptions *", "bool" }, "void")

--

--- Sets whether to use TFRT
--- 
---@param opts ffi.cdata @(TFE_ContextOptions *)
---@param use_tfrt boolean @(bool)
function M.TFE_ContextOptionsSetTfrt(opts, use_tfrt)
    return _CALL("TFE_ContextOptionsSetTfrt", opts, use_tfrt)
end
_FUNCDEF("TFE_ContextOptionsSetTfrt", { "TFE_ContextOptions *", "bool" }, "void")

--

--- Returns the context_id from the EagerContext which is used by the
--- EagerService to maintain consistency between client and worker. The
--- context_id is initialized with a dummy value and is later set when the worker
--- is initialized (either locally or remotely). The context_id can change during
--- the process lifetime although this should cause the worker to be
--- reinitialized (e.g. cleared caches) as well.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@return number @(uint64_t)
function M.TFE_GetContextId(ctx)
    return _CALL("TFE_GetContextId", ctx)
end
_FUNCDEF("TFE_GetContextId", { "TFE_Context *" }, "uint64_t")

--

--- -----------------------------------------------------------------------------
--- Cancellation APIs.
--- 

_TYPEDEF("TFE_CancellationManager", "struct TFE_CancellationManager")

--

---@return ffi.cdata @(TFE_CancellationManager *)
function M.TFE_NewCancellationManager()
    return _CALL("TFE_NewCancellationManager")
end
_FUNCDEF("TFE_NewCancellationManager", {  }, "TFE_CancellationManager *")

--

---@param cancellation_manager ffi.cdata @(TFE_CancellationManager *)
---@return boolean @(bool)
function M.TFE_CancellationManagerIsCancelled(cancellation_manager)
    return _CALL("TFE_CancellationManagerIsCancelled", cancellation_manager)
end
_FUNCDEF("TFE_CancellationManagerIsCancelled", { "TFE_CancellationManager *" }, "bool")

--

---@param cancellation_manager ffi.cdata @(TFE_CancellationManager *)
function M.TFE_CancellationManagerStartCancel(cancellation_manager)
    return _CALL("TFE_CancellationManagerStartCancel", cancellation_manager)
end
_FUNCDEF("TFE_CancellationManagerStartCancel", { "TFE_CancellationManager *" }, "void")

--

---@param cancellation_manager ffi.cdata @(TFE_CancellationManager *)
function M.TFE_DeleteCancellationManager(cancellation_manager)
    return _CALL("TFE_DeleteCancellationManager", cancellation_manager)
end
_FUNCDEF("TFE_DeleteCancellationManager", { "TFE_CancellationManager *" }, "void")

--

--- Associates the given `cancellation_manager` with `op`, so that invoking
--- `TFE_CancellationManagerStartCancel(cancellation_manager)` will cancel the
--- execution of `op`.
--- 

_TYPEDEF("TFE_CancellationManager", "struct TFE_CancellationManager")

--

---@param op ffi.cdata @(TFE_Op *)
---@param cancellation_manager ffi.cdata @(TFE_CancellationManager *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_OpSetCancellationManager(op, cancellation_manager, status)
    return _CALL("TFE_OpSetCancellationManager", op, cancellation_manager, status)
end
_FUNCDEF("TFE_OpSetCancellationManager", { "TFE_Op *", "TFE_CancellationManager *", "TF_Status *" }, "void")

--

--- -----------------------------------------------------------------------------
--- Eager Executor APIs.
--- 

_TYPEDEF("TFE_Executor", "struct TFE_Executor")

--

--- Creates a new eager Executor. Nodes in one executor are guaranteed to be
--- executed in sequence. Assigning nodes to different executors allows executing
--- nodes in parallel.
--- 
---@param is_async boolean @(bool)
---@return ffi.cdata @(TFE_Executor *)
function M.TFE_NewExecutor(is_async)
    return _CALL("TFE_NewExecutor", is_async)
end
_FUNCDEF("TFE_NewExecutor", { "bool" }, "TFE_Executor *")

--

--- Deletes the eager Executor without waiting for enqueued nodes. Please call
--- TFE_ExecutorWaitForAllPendingNodes before calling this API if you want to
--- make sure all nodes are finished.
--- 
---@param executor ffi.cdata @(TFE_Executor *)
function M.TFE_DeleteExecutor(executor)
    return _CALL("TFE_DeleteExecutor", executor)
end
_FUNCDEF("TFE_DeleteExecutor", { "TFE_Executor *" }, "void")

--

--- Returns true if the executor is in async mode.
--- 
---@param executor ffi.cdata @(TFE_Executor *)
---@return boolean @(bool)
function M.TFE_ExecutorIsAsync(executor)
    return _CALL("TFE_ExecutorIsAsync", executor)
end
_FUNCDEF("TFE_ExecutorIsAsync", { "TFE_Executor *" }, "bool")

--

--- Causes the calling thread to block till all ops dispatched in this executor
--- have been executed. Note that "execution" here refers to kernel execution /
--- scheduling of copies, etc. Similar to sync execution, it doesn't guarantee
--- that lower level device queues (like GPU streams) have been flushed.
--- This call may not block for execution of ops enqueued concurrently with this
--- call.
--- 
---@param executor ffi.cdata @(TFE_Executor *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ExecutorWaitForAllPendingNodes(executor, status)
    return _CALL("TFE_ExecutorWaitForAllPendingNodes", executor, status)
end
_FUNCDEF("TFE_ExecutorWaitForAllPendingNodes", { "TFE_Executor *", "TF_Status *" }, "void")

--

--- When an error happens, any pending operations are discarded and newly issued
--- ops return an error. This call clears the error state and re-enables
--- execution of newly issued ops.
--- Note that outputs of discarded ops remain in a corrupt state and should not
--- be used for future calls.
--- TODO(agarwal): mark the affected handles and raise errors if they are used.
--- 
---@param executor ffi.cdata @(TFE_Executor *)
function M.TFE_ExecutorClearError(executor)
    return _CALL("TFE_ExecutorClearError", executor)
end
_FUNCDEF("TFE_ExecutorClearError", { "TFE_Executor *" }, "void")

--

--- Sets a custom Executor for current thread. All nodes created by this thread
--- will be added to this Executor. It will override current executor.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param executor ffi.cdata @(TFE_Executor *)
function M.TFE_ContextSetExecutorForThread(ctx, executor)
    return _CALL("TFE_ContextSetExecutorForThread", ctx, executor)
end
_FUNCDEF("TFE_ContextSetExecutorForThread", { "TFE_Context *", "TFE_Executor *" }, "void")

--

--- Returns the Executor for current thread.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@return ffi.cdata @(TFE_Executor *)
function M.TFE_ContextGetExecutorForThread(ctx)
    return _CALL("TFE_ContextGetExecutorForThread", ctx)
end
_FUNCDEF("TFE_ContextGetExecutorForThread", { "TFE_Context *" }, "TFE_Executor *")

--

--- -----------------------------------------------------------------------------
--- Dynamic cluster API.
--- Update an existing context with a new set of servers defined in a ServerDef
--- proto. Servers can be added to and removed from the list of remote workers
--- in the context. New set of servers identified by the ServerDef must be up
--- when the context is updated.
--- This API is for experimental usage and may be subject to change.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param keep_alive_secs number @(int)
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextUpdateServerDef(ctx, keep_alive_secs, proto, proto_len, status)
    return _CALL("TFE_ContextUpdateServerDef", ctx, keep_alive_secs, proto, proto_len, status)
end
_FUNCDEF("TFE_ContextUpdateServerDef", { "TFE_Context *", "int", "const void *", "size_t", "TF_Status *" }, "void")

--

--- Checks whether a remote worker is alive or not. This will return true even if
--- the context doesn't exist on the remote worker.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param worker_name string @(const char *)
---@param status ffi.cdata @(TF_Status *)
---@return boolean @(bool)
function M.TFE_ContextCheckAlive(ctx, worker_name, status)
    return _CALL("TFE_ContextCheckAlive", ctx, worker_name, status)
end
_FUNCDEF("TFE_ContextCheckAlive", { "TFE_Context *", "const char *", "TF_Status *" }, "bool")

--

--- Sync pending nodes in local executors (including the context default executor
--- and thread executors) and streaming requests to remote executors, and get the
--- combined status.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextAsyncWait(ctx, status)
    return _CALL("TFE_ContextAsyncWait", ctx, status)
end
_FUNCDEF("TFE_ContextAsyncWait", { "TFE_Context *", "TF_Status *" }, "void")

--

--- This function will block till the operation that produces `h` has
--- completed. This is only valid on local TFE_TensorHandles. The pointer
--- returned will be on the device in which the TFE_TensorHandle resides (so e.g.
--- for a GPU tensor this will return a pointer to GPU memory). The pointer is
--- only guaranteed to be valid until TFE_DeleteTensorHandle is called on this
--- TensorHandle. Only supports POD data types.
--- 
---@param tensor_handle ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(void *)
function M.TFE_TensorHandleDevicePointer(tensor_handle, status)
    return _CALL("TFE_TensorHandleDevicePointer", tensor_handle, status)
end
_FUNCDEF("TFE_TensorHandleDevicePointer", { "TFE_TensorHandle *", "TF_Status *" }, "void *")

--

--- This function will block till the operation that produces `h` has
--- completed. This is only valid on local TFE_TensorHandles. Returns the size in
--- bytes of the memory pointed to by the device pointer returned above.
--- 
---@param tensor_handle ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(size_t)
function M.TFE_TensorHandleDeviceMemorySize(tensor_handle, status)
    return _CALL("TFE_TensorHandleDeviceMemorySize", tensor_handle, status)
end
_FUNCDEF("TFE_TensorHandleDeviceMemorySize", { "TFE_TensorHandle *", "TF_Status *" }, "size_t")

--

--- Creates a new TensorHandle from memory residing in device_name. Takes
--- ownership of the memory, and will call deleter to release it after TF
--- no longer needs it or in case of error.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param device_name string @(const char *)
---@param dtype TF_DataType @(TF_DataType)
---@param dims ffi.cdata @(const int64_t *)
---@param num_dims number @(int)
---@param data ffi.cdata @(void *)
---@param len number @(size_t)
---@param deallocator ffi.cdata @(void *)
---@param deallocator_arg ffi.cdata @(void *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_TensorHandle *)
function M.TFE_NewTensorHandleFromDeviceMemory(ctx, device_name, dtype, dims, num_dims, data, len, deallocator, deallocator_arg, status)
    return _CALL("TFE_NewTensorHandleFromDeviceMemory", ctx, device_name, dtype, dims, num_dims, data, len, deallocator, deallocator_arg, status)
end
_FUNCDEF("TFE_NewTensorHandleFromDeviceMemory", { "TFE_Context *", "const char *", "TF_DataType", "const int64_t *", "int", "void *", "size_t", "void *", "void *", "TF_Status *" }, "TFE_TensorHandle *")

--

--- void (*deallocator)(void* data, size_t len, void* arg),
--- Retrieves the address space (i.e. job, replia, task) of the local host and
--- saves it in the buffer.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param buf ffi.cdata @(TF_Buffer *)
function M.TFE_HostAddressSpace(ctx, buf)
    return _CALL("TFE_HostAddressSpace", ctx, buf)
end
_FUNCDEF("TFE_HostAddressSpace", { "TFE_Context *", "TF_Buffer *" }, "void")

--

--- APIs for generically dealing with op attributes (e.g. when forwarding them
--- through custom device implementations).
--- TODO(allenl): Currently these are black boxes, but we should have some way to
--- inspect values. This would let people e.g. copy over most attributes and then
--- modify some based on their values.
--- A reference to an op's name -> attribute mapping
--- 

_TYPEDEF("TFE_OpAttrs", "struct TFE_OpAttrs")

--

--- Fetch a reference to `op`'s attributes. The returned reference is only valid
--- while `op` is alive.
--- 
---@param op ffi.cdata @(const TFE_Op *)
---@return ffi.cdata @(const TFE_OpAttrs *)
function M.TFE_OpGetAttrs(op)
    return _CALL("TFE_OpGetAttrs", op)
end
_FUNCDEF("TFE_OpGetAttrs", { "const TFE_Op *" }, "const TFE_OpAttrs *")

--

--- Add attributes in `attrs` to `op`.
--- Does not overwrite or update existing attributes, but adds new ones.
--- 
---@param op ffi.cdata @(TFE_Op *)
---@param attrs ffi.cdata @(const TFE_OpAttrs *)
function M.TFE_OpAddAttrs(op, attrs)
    return _CALL("TFE_OpAddAttrs", op, attrs)
end
_FUNCDEF("TFE_OpAddAttrs", { "TFE_Op *", "const TFE_OpAttrs *" }, "void")

--

--- Serialize `attrs` as a tensorflow::NameAttrList protocol buffer (into `buf`),
--- containing the op name and a map of its attributes.
--- 
---@param attrs ffi.cdata @(const TFE_OpAttrs *)
---@param buf ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_OpAttrsSerialize(attrs, buf, status)
    return _CALL("TFE_OpAttrsSerialize", attrs, buf, status)
end
_FUNCDEF("TFE_OpAttrsSerialize", { "const TFE_OpAttrs *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- Set an op's attribute from a serialized AttrValue protocol buffer.
--- Analogous to TF_SetAttrValueProto for building graph operations.
--- 
---@param op ffi.cdata @(const TFE_Op *)
---@param attr_name string @(const char *)
---@param proto ffi.cdata @(const void *)
---@param proto_len number @(size_t)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_OpSetAttrValueProto(op, attr_name, proto, proto_len, status)
    return _CALL("TFE_OpSetAttrValueProto", op, attr_name, proto, proto_len, status)
end
_FUNCDEF("TFE_OpSetAttrValueProto", { "const TFE_Op *", "const char *", "const void *", "size_t", "TF_Status *" }, "void")

--

--- TODO(b/166642410): It would be nice, for custom devices and for other users,
--- to have a non-string representation of devices (TF_Device) extracted from
--- tensors/ops/etc. and usable in APIs like OpSetDevice/ResetOp/etc.
--- Struct to be filled in
--- int version = TFE_CUSTOM_DEVICE_VERSION;
--- Method to copy a tensor to the custom device.
--- Method to copy a tensor from the custom device to a target device.
--- Method to execute an operation.
--- Arguments provide enough information to reconstruct the original `TFE_Op`,
--- or construct a transformed version, by inspecting the passed `op`.
--- TFE_OpGetDevice(op) records the original placement of the operation. It may
--- be an empty string if no device was explicitly requested, but will
--- otherwise be the name of this custom device. Ops are placed onto a custom
--- device if any of their inputs are on that custom device, but custom devices
--- are free to set a bad status in order to require explicit placement.
--- Method to delete a device.
--- 

_TYPEDEF("TFE_CustomDevice", "struct TFE_CustomDevice { int version ; TFE_TensorHandle * ( * copy_tensor_to_device ) ( TFE_Context * context , TFE_TensorHandle * tensor , TF_Status * status , void * device_info ) ; TFE_TensorHandle * ( * copy_tensor_from_device ) ( TFE_Context * context , TFE_TensorHandle * tensor , const char * target_device_name , TF_Status * status , void * device_info ) ; void ( * execute ) ( const TFE_Op * op , int * num_outputs , TFE_TensorHandle * * outputs , TF_Status * s , void * device_info ) ; void ( * delete_device ) ( void * device_info ) ; }")

--

--- Registers a custom device for use with eager execution.
--- Eager operations may be placed on this device, e.g.  `with
--- tf.device("CUSTOM"):` from Python if `device_name` for this call is
--- "/job:localhost/replica:0/task:0/device:CUSTOM:0".
--- The custom device defines copy operations for moving TensorHandles on and
--- off, and an an execution operation for named operations. Often execution will
--- simply wrap op execution on one or more physical devices.
--- device_info is an opaque caller-defined type stored with the custom device
--- which is passed to the functions referenced in the TFE_CustomDevice struct
--- `device` (execute, delete_device, etc.). It can for example contain the
--- names of wrapped devices.
--- There are currently no graph semantics implemented for registered custom
--- devices, so executing tf.functions which contain operations placed on custom
--- devices will fail.
--- `device_name` must not name an existing physical or custom device. It must
--- follow the format:
--- /job:<name>/replica:<replica>/task:<task>/device:<type>:<device_num>
--- If the device is successfully registered, `status` is set to TF_OK. Otherwise
--- the device is not usable. In case of a bad status, `device.delete_device` is
--- still called on `device_info` (i.e. the caller does not retain ownership).
--- This API is highly experimental, and in particular is expected to change when
--- it starts supporting operations with attributes and when tf.function support
--- is added.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param device TFE_CustomDevice @(TFE_CustomDevice)
---@param device_name string @(const char *)
---@param device_info ffi.cdata @(void *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_RegisterCustomDevice(ctx, device, device_name, device_info, status)
    return _CALL("TFE_RegisterCustomDevice", ctx, device, device_name, device_info, status)
end
_FUNCDEF("TFE_RegisterCustomDevice", { "TFE_Context *", "TFE_CustomDevice", "const char *", "void *", "TF_Status *" }, "void")

--

---@param ctx ffi.cdata @(TFE_Context *)
---@param function_name string @(const char *)
---@param buf ffi.cdata @(TF_Buffer *)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextGetFunctionDef(ctx, function_name, buf, status)
    return _CALL("TFE_ContextGetFunctionDef", ctx, function_name, buf, status)
end
_FUNCDEF("TFE_ContextGetFunctionDef", { "TFE_Context *", "const char *", "TF_Buffer *", "TF_Status *" }, "void")

--

--- Allocate and return a new Tensor on the host.
--- The caller must set the Tensor values by writing them to the pointer returned
--- by TF_TensorData with length TF_TensorByteSize.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param dtype TF_DataType @(TF_DataType)
---@param dims ffi.cdata @(const int64_t *)
---@param num_dims number @(int)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TF_Tensor *)
function M.TFE_AllocateHostTensor(ctx, dtype, dims, num_dims, status)
    return _CALL("TFE_AllocateHostTensor", ctx, dtype, dims, num_dims, status)
end
_FUNCDEF("TFE_AllocateHostTensor", { "TFE_Context *", "TF_DataType", "const int64_t *", "int", "TF_Status *" }, "TF_Tensor *")

--

--- Given a Tensor, wrap it with a TensorHandle
--- Similar to TFE_NewTensorHandle, but includes a pointer to the TFE_Context.
--- The context should be identical to that of the Tensor.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param t ffi.cdata @(TF_Tensor *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_TensorHandle *)
function M.TFE_NewTensorHandleFromTensor(ctx, t, status)
    return _CALL("TFE_NewTensorHandleFromTensor", ctx, t, status)
end
_FUNCDEF("TFE_NewTensorHandleFromTensor", { "TFE_Context *", "TF_Tensor *", "TF_Status *" }, "TFE_TensorHandle *")

--

--- Create a packed TensorHandle with the given list of TensorHandles.
--- If `handles` are on the same device, assign the same device to the packed
--- handle; if `handles` are on different deivces, assign a CompositeDevice to
--- it.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param handles ffi.cdata @(TFE_TensorHandle * *)
---@param num_handles ffi.cdata @(int *)
---@param status ffi.cdata @(TF_Status *)
---@return ffi.cdata @(TFE_TensorHandle *)
function M.TFE_CreatePackedTensorHandle(ctx, handles, num_handles, status)
    return _CALL("TFE_CreatePackedTensorHandle", ctx, handles, num_handles, status)
end
_FUNCDEF("TFE_CreatePackedTensorHandle", { "TFE_Context *", "TFE_TensorHandle * *", "int *", "TF_Status *" }, "TFE_TensorHandle *")

--

--- Configure soft device placement policy for the eager executor. Note this
--- policy is applied to any subsequent op executions.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param enable number @(unsigned char)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextSetSoftDevicePlacement(ctx, enable, status)
    return _CALL("TFE_ContextSetSoftDevicePlacement", ctx, enable, status)
end
_FUNCDEF("TFE_ContextSetSoftDevicePlacement", { "TFE_Context *", "unsigned char", "TF_Status *" }, "void")

--

--- Configure device placement policy logging for the eager executor. Note this
--- policy is applied to any subsequent op executions.
--- 
---@param ctx ffi.cdata @(TFE_Context *)
---@param enable number @(unsigned char)
---@param status ffi.cdata @(TF_Status *)
function M.TFE_ContextSetLogDevicePlacement(ctx, enable, status)
    return _CALL("TFE_ContextSetLogDevicePlacement", ctx, enable, status)
end
_FUNCDEF("TFE_ContextSetLogDevicePlacement", { "TFE_Context *", "unsigned char", "TF_Status *" }, "void")

--

--- Returns the device type of the operation that produced `h`.
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return string @(const char *)
function M.TFE_TensorHandleDeviceType(h, status)
    return _CALL("TFE_TensorHandleDeviceType", h, status)
end
_FUNCDEF("TFE_TensorHandleDeviceType", { "TFE_TensorHandle *", "TF_Status *" }, "const char *")

--

--- Returns the device ID of the operation that produced `h`.
--- 
---@param h ffi.cdata @(TFE_TensorHandle *)
---@param status ffi.cdata @(TF_Status *)
---@return number @(int)
function M.TFE_TensorHandleDeviceID(h, status)
    return _CALL("TFE_TensorHandleDeviceID", h, status)
end
_FUNCDEF("TFE_TensorHandleDeviceID", { "TFE_TensorHandle *", "TF_Status *" }, "int")

--


return M

