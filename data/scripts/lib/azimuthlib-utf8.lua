--- UTF-8 library for Avorion to help modders and to show devs that we need native UTF-8 support in Lua.
---
--- I tried to collect and construct the best implementations of functions with a goal of achieving max performance while keeping input and output relatively close to the native Lua 5.2/5.3 functions.
---
--- These functions will assume that you will pass correct utf-8 strings and arguments (no checks made).
---
--- Thanks to:
---
--- * https://gist.github.com/Stepets/3b4dbaf5e6e6a60f3862
--- * https://stackoverflow.com/a/29217368/3768314
-- @usage local UTF8 = include("azimuthlib-utf8")
-- @module UTF8
local UTF8 = {}

local gmatch = string.gmatch
local len = string.len
local byte = string.byte
local char = string.char
local lower = string.lower
local upper = string.upper
local find = string.find
local concat = table.concat
local insert = table.insert
local sort = table.sort
local remove = table.remove
local floor = math.floor

-- data will be loaded once but only if lower/upper/compare functions were called
local lowerCase
local upperCase
local alphabetSort

local lang = getCurrentLanguage ~= nil and getCurrentLanguage() or "en" -- use english for console server

local function str_bytes(s, l)
    if not l then l = 0 end
    local r = {}
    local bytes = 1
    for chr in gmatch(s, UTF8.charpattern) do
        r[#r+1] = bytes
        if #r == l then return r end
        bytes = bytes + len(chr)
    end
    return r
end

--- Pattern that is used to find UTF-8 characters
-- @tparam[readonly] string charpattern
UTF8.charpattern = "([%z\1-\127\194-\244][\128-\191]*)"

--- Returns string as UTF-8 char table
--- @tparam string s — Input string
--- @treturn table — UTF-8 char table
function UTF8.table(s)
    local r = {}
    for chr in gmatch(s, UTF8.charpattern) do
        r[#r+1] = chr
    end
    return r
end

--- Returns numerical code of a single UTF-8 character
-- @tparam string c — Input character
-- @treturn int — Character code
function UTF8.singlebyte(c)
    local bytes = len(c)
    if bytes == 1 then return byte(c) end
    if bytes == 2 then
        local byte0, byte1 = byte(c, 1, 2)
        return (byte0 - 0xC0) * 0x40 + (byte1 - 0x80)
    end
    if bytes == 3 then
        local byte0, byte1, byte2 = byte(c, 1, 3)
        return (byte0 - 0xE0) * 0x1000 + (byte1 - 0x80) * 0x40 + (byte2 - 0x80)
    end
    local byte0, byte1, byte2, byte3 = byte(c, 1, 4)
    return (byte0 - 0xF0) * 0x40000 + (byte1 - 0x80) * 0x1000 + (byte2 - 0x80) * 0x40 + (byte3 - 0x80) 
end

--- Returns numerical codes of UTF-8 characters in a range (similarly to string.byte)
--- 
--- For getting code of a single character it's advised UTF8.singlebyte (performance-wise)
-- @tparam string s — Input string
-- @tparam int i — Starting position
-- @tparam[opt=i] int j — Ending position (default: equals i)
-- @treturn int.. — Character codes
-- @see string.byte
-- @see UTF8.singlebyte
function UTF8.byte(s, i, j)
    if not i then i = 1 end
    if not j then j = i end
    j = j - i + 1
    
    local r = {}
    for chr in gmatch(s, UTF8.charpattern) do
        if i == 1 then
            if j ~= 0 then
                r[#r+1] = UTF8.singlebyte(chr)
                j = j - 1
            else
                return unpack(r)
            end
        else
            i = i - 1
        end
    end
    return unpack(r)
end

--- Returns UTF-8 character that matches passed numerical code
-- @tparam int code — Input character code
-- @treturn string — Character
function UTF8.singlechar(code)
    if code < 0x80 then
        return char(code)
    end
    if code < 0x7FF then
        return char(floor(code / 0x40) + 0xC0, code % 0x40 + 0x80)
    end
    if code < 0xFFFF then
        local byte0 = floor(code / 0x1000) + 0xE0
        code = code % 0x1000
        return char(byte0, floor(code / 0x40) + 0x80, code % 0x40 + 0x80)
    end
    local byte0 = floor(code / 0x40000) + 0xF0
    code = code % 0x40000
    local byte1 = floor(code / 0x1000) + 0x80
    code = code % 0x1000
    return char(byte0, byte1, floor(code / 0x40) + 0x80, code % 0x40 + 0x80)
end

--- Returns UTF-8 string made of the passed numerical codes (similarly to string.char)
--- 
--- For getting char from a single character it's advised UTF8.singlechar (performance-wise)
-- @tparam int.. codes — Input character codes
-- @treturn string — UTF-8 string
-- @see string.char
-- @see UTF8.singlechar
function UTF8.char(...)
    local r = {...}
    local code
    for i = 1, #r do
        r[i] = UTF8.singlechar(r[i])
    end
    return concat(r)
end

--- Finds the first occurrence of the pattern in the string passed. If an instance of the pattern is found:
---
--- * If simple = false (default) — a pair of values representing the start and end of the string is returned
--- * If simple = true — 'true' is returned (performance-friendly option if you don't need start and end positions)
--- 
--- If the pattern cannot be found nil is returned.
-- @tparam string s — Input string
-- @tparam string pattern — Plain substring (**Patterns are currently not supported**)
-- @tparam[opt=1] int init — Start search from specified position (default: 1)
-- @tparam[opt=true] bool plain — True if patterns aren't used (**Currently always true no matter what you pass**)
-- @tparam[opt=false] bool simple — True if function shouldn't return start and end position of a found substring (default: false)
-- @treturn nil/true/int start:
--
-- * nil — nothing found
-- * true — substring found, but 'simple = true'
-- * number — start position ('simple = false')
-- @treturn nil/int end:
--
-- * nil — nothing found or 'simple = true'
-- * number — end position ('simple = false')
-- @see string.find
function UTF8.find(s, pattern, init, plain, simple)
    plain = true
    if init == nil then init = 1
    elseif init > 1 then
        local bytes = str_bytes(s, init)
        if not bytes[init] then return nil end
        init = bytes[init]
    elseif init < 0 then
        local bytes = str_bytes(s)
        init = bytes[#bytes + init + 1]
    end
    local r
    if plain then
        r = { find(s, pattern, init, true) } -- will return start and end pos in bytes
    else
        -- TODO
    end
    if #r == 0 then return end
    if simple then return true end
    -- Search for char pos and correct end pos
    local posBegin = 0
    local posEnd = 0
    local bytes = 1
    local pos = 0
    for chr in gmatch(s, UTF8.charpattern) do
        pos = pos + 1
        if posBegin == 0 and r[1] == bytes then
            posBegin = pos
        elseif posEnd == 0 then
            if r[2] == bytes then
                posEnd = pos
            elseif r[2] < bytes then -- correcting end pos
                posEnd = pos - 1
            end
        end
        if posBegin > 0 and posEnd > 0 then break end
        bytes = bytes + len(chr)
    end
    if posEnd == 0 then posEnd = pos end
    r[1] = posBegin
    r[2] = posEnd
    return unpack(r)
end

--- Returns the length of the string passed
-- @tparam string s — Input string
-- @treturn int — String length
-- @see string.len
function UTF8.len(s)
    local r = 0
    for _ in gmatch(s, UTF8.charpattern) do
        r = r + 1
    end
    return r
end

--- Converts UTF-8 uppercase characters into lower case
--- 
--- Uses 'azimuthlib-utf8-lower' file as a helper
-- @tparam string s — Input string
-- @tparam[opt=false] bool asTable — If true, will return result as a char table (default: false)
-- @treturn string/table result:
--
-- * string — if 'asTable = false'
-- * table — if 'asTable = true'
-- @see string.lower
function UTF8.lower(s, asTable)
    if not lowerCase then
        local c, b
        if lowerCase ~= false then
            lowerCase = false
            c, b = pcall(include, 'azimuthlib-utf8-lower')
        end
        if not c then
            eprint("[ERROR][AzimuthLib]: utf8 library failed to load 'upper to lower' file")
            return not asTable and lower(s) or UTF8.table(lower(s))
        end
        lowerCase = b
    end
    local r = {}
    for chr in gmatch(s, UTF8.charpattern) do
        r[#r+1] = lowerCase[chr] and lowerCase[chr] or chr
    end
    return not asTable and concat(r) or r
end

--- Reverses a string
-- @tparam string s — Input string
-- @treturn string — Reversed string
-- @see string.reverse
function UTF8.reverse(s)
    local r = {}
    for chr in gmatch(s, UTF8.charpattern) do
        r[#r+1] = chr
    end
    for i = 1, floor(#r * 0.5) do
        r[i], r[#r - i + 1] = r[#r - i + 1], r[i]
    end
    return concat(r)
end

--- Returns a substring of the string passed
-- @tparam string s — Input string
-- @tparam int i — Starting character position (**not** byte position)
-- @tparam[opt] int j — Ending character position. If not specified the substring will end at the end of the string
-- @treturn string — Substring
-- @see string.sub
function UTF8.sub(s, i, j)
    local str = {}
    for chr in gmatch(s, UTF8.charpattern) do
        str[#str+1] = chr
    end
    if j == nil or j == -1 then j = #str end
    if i < 0 then i = #str + i + 1 end
    if i < 1 then i = 1 end
    return concat({unpack(str, i, j)})
end

--- Converts UTF-8 lowercase characters into upper case
--- 
--- Uses 'azimuthlib-utf8-lower' file as a helper
-- @tparam string s — Input string
-- @tparam[opt=false] bool asTable — If true, will return result as a char table (default: false)
-- @treturn string/table result:
--
-- * string — if 'asTable = false'
-- * table — if 'asTable = true'
-- @see string.upper
function UTF8.upper(s, asTable)
    if not upperCase then
        if not lowerCase then
            local c, b
            if lowerCase ~= false then
                lowerCase = false
                c, b = pcall(include, 'azimuthlib-utf8-lower')
            end
            if not c then
                eprint("[ERROR][AzimuthLib]: utf8 library failed to load 'upper to lower' file")
                return not asTable and upper(s) or UTF8.table(upper(s))
            end
            lowerCase = b
        end
        upperCase = {}
        for k, v in pairs(lowerCase) do
            if not upperCase[v] then
                upperCase[v] = k
            end
        end
    end
    local r = {}
    for chr in gmatch(s, UTF8.charpattern) do
        r[#r+1] = upperCase[chr] and upperCase[chr] or chr
    end
    return not asTable and concat(r) or r
end

--- Returns the byte-index of the n'th UTF-8 character after the given byte position i
-- @tparam string s — Input string
-- @tparam int n — Character index
-- @tparam[opt] int i — Starting byte position:
--
-- * default: 1 — If n is positive
-- * default: -1 — If n is negative
-- @treturn int
--
-- * byte-index of the n'th UTF-8 character after the given byte position i — If n != 0
-- * byte-index of the UTF-8 character byte position i lies within — If n == 0
function UTF8.offset(s, n, i)
    local length = 0
    local pos = {}
    for k, v in UTF8.codes(s) do
        length = length + 1
        pos[#pos+1] = k
    end

    if i == nil or i < 1 then
        i = n >= 0 and 1 or length + 1
    end
    i = i + n
    if n ~= 0 then
        return pos[i] ~= nil and pos[i] or nil
    else -- special case
        for j = 0, #pos do
            if pos[j] > i then
                return j - 1
            end
        end
        return pos[#pos]
    end
end

--- Returns the numerical codes (as numbers) from all characters in the given string that start between byte position i and j
-- @tparam string s — Input string
-- @tparam int i — Starting byte position
-- @tparam[opt=i] int j — Ending byte position (default: equals i)
-- @treturn int.. — Character codes
-- @see string.byte
function UTF8.codepoint(s, i, j)
    if not i then i = 1 end
    if not j then j = i end
    local r = {}
    local bytes = 1
    for chr in gmatch(s, UTF8.charpattern) do
        if bytes > j then return unpack(r) end
        if bytes >= i then
            r[#r+1] = UTF8.singlebyte(chr)
        end
        bytes = bytes + len(chr)
    end
    return unpack(r)
end

--- Returns an iterator (like string.gmatch) which returns both the position and codepoint of each utf8 character in the string
-- @tparam string s — Input string
-- @treturn function iterator
-- @see string.gmatch
function UTF8.codes(s)
    local order = {}
    local r = {}
    local bytes = 1
    for chr in gmatch(s, UTF8.charpattern) do
        order[#order+1] = bytes
        r[bytes] = UTF8.singlebyte(chr)
        bytes = bytes + len(chr)
    end
    r = {order, r}
    local k = 0
    return function()
        k = k + 1
        local bytes = r[1][k]
        if bytes then
            return bytes, r[2][bytes]
        else
            return nil
        end
    end
end

--- Compares two strings
--- 
--- Uses 'azimuthlib-utf8-compare' file as a helper
-- @tparam string a — Input string a
-- @tparam string b — Input string b
-- @tparam[opt=false] bool sensitive — If true, function will be case-sensitive (default: false)
-- @treturn bool — 'true' if string a should be placed before b and 'false' otherwise
-- @usage table.sort(mytable, UTF8.compare)
-- @usage table.sort(mytable, function(a, b) return UTF8.compare(a, b, true) end)
-- @see UTF8.comparesensitive
function UTF8.compare(a, b, sensitive)
    if not sensitive then
        a = UTF8.lower(a, true)
        b = UTF8.lower(b, true)
    else
        a = UTF8.table(a)
        b = UTF8.table(b)
    end
    
    if not alphabetSort then
        alphabetSort = {}
        local c, b = pcall(include, 'azimuthlib-utf8-compare')
        if c then
            if b[lang] then alphabetSort = b[lang] end
        else
            eprint("[ERROR][AzimuthLib]: utf8 library failed to load 'alphabet sorting' file")
        end
    end

    local i = 1
    while i <= math.min(#a, #b) do
        local val, af, bf, _type
        val = alphabetSort[a[i]]
        if val then
            _type = type(val)
            if _type ~= 'function' then
                a[i] = val
            else
                a[i] = val(a, i)
            end
            if _type ~= 'string' then af = true end
        end
        val = alphabetSort[b[i]]
        if val then
            _type = type(val)
            if _type ~= 'function' then
                b[i] = val
            else
                b[i] = val(b, i)
            end
            if _type ~= 'string' then bf = true end
        end
        if af and not bf then b[i] = UTF8.singlebyte(b[i]) end
        if not af and bf then a[i] = UTF8.singlebyte(a[i]) end
        
        if a[i] < b[i] then
            return true
        elseif a[i] > b[i] then
            return false
        end
        
        i = i + 1
    end
    
    return #a < #b
end

--- Compares two strings case-sensitively. It's just a shortcut that passes 'sensitive = true'
--- 
--- Uses 'azimuthlib-utf8-compare' file as a helper
-- @tparam string a — Input string a
-- @tparam string b — Input string b
-- @treturn bool — 'true' if string a should be placed before b and 'false' otherwise
-- @usage table.sort(mytable, UTF8.comparesensitive)
-- @see UTF8.compare
function UTF8.comparesensitive(a, b)
    return UTF8.compare(a, b, true)
end

-- validation function
-- getString(value, default [, minLen [, maxLen [, allowedChars [, forbiddenChars]]]])
--[[ Performs checks on a potential string and returns it.
* value - Any variable for checking.
* default (string) - Default value. Will be returned if value is incorrect or too short.
* minLen (number) - Min length.
* maxLen (number) - Max length.
* allowedChars (string) - Similar to TextBox allowedCharacters.
* forbiddenChars (string) - Similar to TextBox forbiddenCharacters.
]]

--- Performs checks on a potential string and returns it
-- @tparam var value — Variable for validation
-- @tparam string default — Default value, will be returned if value is incorrect or too short
-- @tparam[opt] int minLen — If present, string length should be at least minLen characters
-- @tparam[opt] int maxLen — If present, string length should be no longer than maxLen characters, excess will be removed
-- @tparam[opt] string allowedChars — If present, string should contain only specified characters, others will be removed
-- @tparam[opt] string forbiddenChars — If present, string should not contain specified characters, they will be removed
-- @treturn string — Resulting string
-- @treturn bool isModified — If true, value was changed in some way
function UTF8.getString(value, default, minLen, maxLen, allowedChars, forbiddenChars)
    local isModified = false
    if type(value) ~= "string" then
        isModified = true
    end
    value = tostring(value)
    if not value then return default, true end
    local valueArray = UTF8.table(value)
    if allowedChars then
        allowedChars = UTF8.table(allowedChars)
        local arr = {}
        for _, v in ipairs(allowedChars) do
            arr[v] = true
        end
        local newArray = {}
        for _, v in ipairs(valueArray) do
            if arr[v] then
                newArray[#newArray+1] = v
            else
                isModified = true
            end
        end
        valueArray = newArray
    end
    if forbiddenChars then
        forbiddenChars = UTF8.table(forbiddenChars)
        local arr = {}
        for _, v in ipairs(forbiddenChars) do
            arr[v] = true
        end
        local newArray = {}
        for _, v in ipairs(valueArray) do
            if arr[v] then
                isModified = true
            else
                newArray[#newArray+1] = v
            end
        end
        valueArray = newArray
    end
    local length = #valueArray
    if minLen and length < minLen then return default, true end
    if maxLen and length > maxLen then return concat(valueArray, nil, 1, maxLen), true end
    return concat(valueArray), isModified
end

return UTF8