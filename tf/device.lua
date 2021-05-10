--
local M = {}
local DEVICE_DEFAULT = "DEFAULT"
local DEVICE_CPU = "CPU"
local DEVICE_GPU = "GPU"
local DEVICE_TPU_SYSTEM = "TPU_SYSTEM"

local _device_infos

function M.listDeviceInfos()
    if _device_infos then
        return _device_infos
    end
    local graph = require('tf.c.TFGraph')()
    local opts = require('tf.c.TFSessionOptions')()
    local session = require('tf.c.TFSession').Create(graph, opts)
    opts:dtor()
    local list = session:listDevices()
    local n = list:count()
    _device_infos = {}
    for i = 1, n do
        _device_infos[i] = {
            name        = list:name(i - 1),
            type        = list:type(i - 1),
            memoryBytes = list:memoryBytes(i - 1),
            incarnation = list:incarnation(i - 1),
        }
    end
    list:dtor()
    session:dtor()
    graph:dtor()
    return _device_infos
end

function M.getCPUInfo()
    local info = M.listDeviceInfos()
    for i, v in ipairs(info) do
        if v.type == DEVICE_CPU then
            return v
        end
    end
end

function M.getGPUInfo()
    local info = M.listDeviceInfos()
    for i, v in ipairs(info) do
        if v.type == DEVICE_GPU then
            return v
        end
    end
end

function M.cpu()
    return "/cpu:0"
end

function M.gpu(i)
    return ("/device:GPU:%d"):format(i or 0)
end

return M
