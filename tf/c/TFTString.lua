---@class tf.TFTString
local M = class('tf.TFTString')
local ffi = require('ffi')
local bit = require('bit')
local free = require('tf_util.cstd').free
local memcpy = require('tf_util.cstd').memcpy
local realloc = require('tf_util.cstd').realloc
local malloc = require('tf_util.cstd').malloc

local TF_TSTR_SMALL = 0x00
local TF_TSTR_LARGE = 0x01
local TF_TSTR_OFFSET = 0x02
local TF_TSTR_VIEW = 0x03
local TF_TSTR_TYPE_MASK = 0x03

ffi.cdef [[
typedef enum TF_TString_Type {  // NOLINT
  TF_TSTR_SMALL = 0x00,
  TF_TSTR_LARGE = 0x01,
  TF_TSTR_OFFSET = 0x02,
  TF_TSTR_VIEW = 0x03,
  TF_TSTR_TYPE_MASK = 0x03
} TF_TString_Type;

typedef struct TF_TString_Large {  // NOLINT
  size_t size;
  size_t cap;
  char *ptr;
} TF_TString_Large;

typedef struct TF_TString_Offset {  // NOLINT
  uint32_t size;
  uint32_t offset;
  uint32_t count;
} TF_TString_Offset;

typedef struct TF_TString_View {  // NOLINT
  size_t size;
  const char *ptr;
} TF_TString_View;

typedef struct TF_TString_Raw {  // NOLINT
  uint8_t raw[24];
} TF_TString_Raw;

typedef union TF_TString_Union {  // NOLINT
  TF_TString_Large large;
  TF_TString_Offset offset;
  TF_TString_View view;
  TF_TString_Raw raw;
} TF_TString_Union;
]]

local TF_TString_SmallCapacity = ffi.sizeof('TF_TString_Union') - ffi.sizeof('char') - ffi.sizeof('uint8_t')

local TF_TString_Small = ([[
typedef struct TF_TString_Small {  // NOLINT
  uint8_t size;
  char str[%d];
} TF_TString_Small;
]]):format(TF_TString_SmallCapacity + ffi.sizeof('char'))
ffi.cdef(TF_TString_Small)

ffi.cdef [[
typedef struct TF_TString {  // NOLINT
  union {
    // small conflicts with '#define small char' in RpcNdr.h for MSVC, so we use
    // smll instead.
    TF_TString_Small smll;
    TF_TString_Large large;
    TF_TString_Offset offset;
    TF_TString_View view;
    TF_TString_Raw raw;
  } u;
} TF_TString;
]]

function M.TF_swap32(host_int)
    local i1 = bit.lshift(bit.band(host_int, 0xFF), 24)
    local i2 = bit.lshift(bit.band(host_int, 0xFF00), 8)
    local i3 = bit.rshift(bit.band(host_int, 0xFF0000), 8)
    local i4 = bit.rshift(bit.band(host_int, 0xFF000000), 24)
    return bit.bor(i1, i2, i3, i4)
end

local _is_le = ffi.abi('le')
local function TF_le32toh(x)
    if _is_le then
        return M.TF_swap32(x)
    else
        return x
    end
end

local function TF_align16(i)
    local ii = ffi.abi('64bit') and ffi.new('size_t', i) or tonumber(i)
    return bit.band((ii + 0xF), bit.bnot(0xF))
end

function M.TF_TString_GetType(str)
    return bit.band(str[0].u.raw.raw[0], TF_TSTR_TYPE_MASK);
end

function M.TF_TString_ToActualSizeT(size)
    if _is_le then
        return bit.rshift(size, 2)
    else
        local mask = ffi.abi('64bit') and 0xFF00000000000000ULL or 0xFF000000
        return bit.bor(bit.rshift(bit.band(bit.lshift(mask, 2), size), 2), bit.band(bit.bnot(mask), size))
    end
end

function M.TF_TString_ToInternalSizeT(size, type)
    if _is_le then
        return bit.bor(bit.rshift(size, 2), type)
    else
        local mask = ffi.abi('64bit') and 0xFF00000000000000ULL or 0xFF000000
        -- do not pass cdata for 32bit
        local type_ = ffi.abi('64bit') and ffi.new('size_t', type) or type
        return bit.bor(
                bit.band(mask, bit.lshift(size, 2)),
                bit.band(bit.bnot(mask), size),
                bit.lshift(type_, (ffi.sizeof('size_t') - 1) * 8))
    end
end

function M.TF_TString_Init(str)
    for i = 1, ffi.sizeof('TF_TString_Raw') do
        str[0].u.raw.raw[i - 1] = 0
    end
end

function M.TF_TString_Dealloc(str)
    if M.TF_TString_GetType(str) == TF_TSTR_LARGE and not ffi.isnullptr(str[0].u.large.ptr) then
        free(str[0].u.large.ptr)
        M.TF_TString_Init(str)
    end
end

function M.TF_TString_GetSize(str)
    local ty = M.TF_TString_GetType(str)
    if ty == TF_TSTR_SMALL then
        return bit.rshift(str[0].u.smll.size, 2)
    elseif ty == TF_TSTR_LARGE then
        return M.TF_TString_ToActualSizeT(str[0].u.large.size)
    elseif ty == TF_TSTR_OFFSET then
        return bit.rshift(TF_le32toh(str[0].u.offset.size), 2)
    elseif ty == TF_TSTR_VIEW then
        return M.TF_TString_ToActualSizeT(str[0].u.view.size)
    else
        return 0
    end
end

function M.TF_TString_GetCapacity(str)
    local ty = M.TF_TString_GetType(str)
    if ty == TF_TSTR_SMALL then
        return TF_TString_SmallCapacity
    elseif ty == TF_TSTR_LARGE then
        return str[0].u.large.cap
    else
        return 0
    end
end

function M.TF_TString_GetDataPointer(str)
    local ty = M.TF_TString_GetType(str)
    if ty == TF_TSTR_SMALL then
        return str[0].u.smll.str
    elseif ty == TF_TSTR_LARGE then
        return str[0].u.large.ptr
    elseif ty == TF_TSTR_OFFSET then
        return ffi.cast('const char*', str) + str[0].u.offset.offset
    elseif ty == TF_TSTR_VIEW then
        return str[0].u.view.str
    else
        return nil
    end
end

function M.TF_TString_ResizeUninitialized(str, new_size)
    local curr_size = M.TF_TString_GetSize(str)
    local copy_size = curr_size < new_size and curr_size or new_size
    local curr_type = M.TF_TString_GetType(str)
    local curr_ptr = M.TF_TString_GetDataPointer(str)
    -- -> SMALL
    if new_size <= TF_TString_SmallCapacity then
        str[0].u.smll.size = bit.bor(bit.lshift(new_size, 2), TF_TSTR_SMALL)
        str[0].u.smll.str[new_size] = 0
        if curr_type ~= TF_TSTR_SMALL and copy_size > 0 then
            memcpy(str[0].u.smll.str, curr_ptr, copy_size)
        end
        if curr_type == TF_TSTR_LARGE then
            free(curr_ptr)
        end
        return str[0].u.smll.str
    end
    -- -> LARGE
    local new_cap
    local curr_cap = M.TF_TString_GetCapacity(str)
    local SIZE_MAX = ffi.new('size_t', -1)
    local curr_cap_x2 = curr_cap >= SIZE_MAX / 2 and SIZE_MAX - 1 or curr_cap * 2
    if new_size < curr_size and new_size < curr_cap / 2 then
        new_cap = TF_align16(curr_cap / 2 + 1) - 1
    elseif new_size > curr_cap_x2 then
        new_cap = TF_align16(new_size + 1) - 1
    elseif new_size > curr_cap then
        new_cap = TF_align16(curr_cap_x2 + 1) - 1
    else
        new_cap = curr_cap
    end
    local new_ptr
    if new_cap == curr_cap then
        new_ptr = str[0].u.large.ptr
    elseif curr_type == TF_TSTR_LARGE then
        new_ptr = ffi.cast('char*', realloc(str[0].u.large.ptr, new_cap + 1))
    else
        new_ptr = ffi.cast('char*', malloc(new_cap + 1))
        if copy_size > 0 then
            memcpy(new_ptr, curr_ptr, copy_size)
        end
    end
    str[0].u.large.size = M.TF_TString_ToInternalSizeT(new_size, TF_TSTR_LARGE)
    str[0].u.large.ptr = new_ptr
    str[0].u.large.ptr[new_size] = 0
    str[0].u.large.cap = new_cap
    return str[0].u.large.ptr
end

function M.TF_TString_Copy(dst, src, size)
    local dst_c = M.TF_TString_ResizeUninitialized(dst, size)
    if size > 0 then
        memcpy(dst_c, src, size)
    end
end

function M.Create(lua_string)
    assert(type(lua_string) == 'string')
    local ret = ffi.new('TF_TString[1]')
    ffi.gc(ret, M.TF_TString_Dealloc)
    M.TF_TString_Init(ret)
    M.TF_TString_Copy(ret, lua_string, #lua_string)
    return ret
end

function M.Extract(tstring)
    local size = M.TF_TString_GetSize(tstring)
    local ptr = M.TF_TString_GetDataPointer(tstring)
    if size == 0 then
        return ''
    end
    if ffi.isnullptr(ptr) then
        error('invalid tf string')
    end
    return ffi.string(ptr, size)
end

return M
