--[[ $Id: kconv.lua,v 1.5 2010/08/18 10:25:46 hirose Exp $
kconv library, (C) 2010, Yamaha Corporation

Usage:
  kconv_opt = "fast"  -- fast conversion from Unicode to JIS codes
                      -- to save memory, let 'kconv_opt' as nil
  require("kconv")
  euc_string = kconv.kconvert(sjis_string, "sjis", "euc")

API:

ret = kconv.kconvert(str, icode, ocode[, opt])

  ret: converted string
  str: string to convert
  icode: kanji code of str
  ocode: kanji code of ret
  opt: option to convert
    "x0213" ... using X0213 conversion table for Unicode<->SJIS/EUC/JIS
    "cp932" ... using MS/CP932 conversion table for Unicode<->SJIS/EUC/JIS
    default ... "cp932"

  supporting kanji code is:

  "sjis"  ... Shift JIS
  "euc"   ... EUC
  "jis"   ... alias of "iso-2022-jp-2004-compatible"
  "iso-2022-jp-2004" ... ISO-2022-JP with X0213-2004
  "iso-2022-jp-2004-compatible"
                     ... ISO-2022-JP with X0213-2004, but use JIS X0208
                         ESC sequence for JIS X0208 comaptibility character
  "iso-2022-jp-3"    ... ISO-2022-JP with X0213-2000
  "iso-2022-jp-3-compatible"
                     ... ISO-2022-JP with X0213-2000, but use JIS X0208
                         ESC sequence for JIS X0208 comaptibility character
  "utf-8" ... UTF-8
  "utf-16" ... alias of "utf-16-be"
  "utf-16-be" ... UTF-16, big endian
  "utf-16-le" ... UTF-16, little endian


ret = kconv.bom(code)

  ret: BOM string
  code: "utf-8"     ... UTF-8 BOM
        "utf-16"    ... UTF-16 BOM (Big Endian)
        "utf-16-be" ... UTF-16 BOM (Big Endian)
        "utf-16-le" ... UTF-16 BOM (Little Endian)

]]

local utable = import(".kconv_utable")
local bit = import(".bit")
bit.bshift = bit.lshift

local collectgarbage = collectgarbage
local error = error
local ipairs = ipairs
local loadfile = loadfile
local pairs = pairs
local string = string
local table = table
local tostring = tostring
local type = type

--module("kconv")

-- [[ Constant ]] --

local SO = 0x0e
local SI = 0x0f
local ESC = 0x1b
local SS2 = 0x8e
local SS3 = 0x8f

-- [[ Option variable ]] --

local uopt = "cp932"

-- [[ Support functions ]] --

-- get one character, as a number, from a string
local function getc(str, spos)
  if spos > #str then
    return -1, -1
  else
    return str:sub(spos, spos):byte(), spos + 1
  end
end

-- put one character, as a number, to a table
local function putc(out, c)
  out[#out + 1] = c
end

-- put string to a table
local function puts(out, s)
  for _, c in ipairs{s:byte(1, #s)} do
    putc(out, c)
  end
end

-- convert number table to string
local function table2str(tbl)
  local s = {}
  for i, b in ipairs(tbl) do
    s[i] = string.char(tbl[i])
  end
  return table.concat(s)
end

-- check the number is ascii in SJIS or not
local function is_sjis_ascii(c)
  return c < 0x80
end

-- check the number is X0201 in SJIS or not
local function is_sjis_x0201(c)
  return c >= 0xa1 and c <= 0xdf
end

-- check the number is first byte of X0213 in SJIS or not
local function is_sjis_x0213_first(c)
  return (c >= 0x81 and c <= 0x9f) or (c >= 0xe0 and c <= 0xfc)
end

-- check the number is first byte of X0213, first plane in SJIS or not
local function is_sjis_x0213_1_first(c)
  return (c >= 0x81 and c <= 0x9f) or (c >= 0xe0 and c <= 0xef)
end

-- check the number is first byte of X0213, second plane in SJIS or not
local function is_sjis_x0213_2_first(c)
  return c >= 0xf0 and c <= 0xfc
end

-- check the number is second byte of X0213 in SJIS or not
local function is_sjis_x0213_second(c)
  return (c >= 0x40 and c <= 0x7e) or (c >= 0x80 and c <= 0xfc)
end

-- check the number is ascii in EUC or not
local function is_euc_ascii(c)
  return c < 0x80
end

-- check the number is X0201 in EUC or not
local function is_euc_x0201(c)
  return c >= 0xa1 and c <= 0xdf
end

-- check the number is X0213 in EUC or not
local function is_euc_x0213(c)
  return c >= 0xa1 and c <= 0xfe
end

-- check the number is X0201 in JIS or not
local function is_jis_x0201(c)
  return c >= 0x21 and c <= 0x5f
end

-- check the number is X0213 in JIS or not
local function is_jis_x0213(c)
  return c >= 0x21 and c <= 0x7e
end

-- convert from GR to GL
local function GR_to_GL(c)
  return c - 0x80
end

-- convert from GL to GR
local function GL_to_GR(c)
  return c + 0x80
end

-- convert from JIS(X0213 first plane) to SJIS
local function jis_to_sjis(j1, j2)
  local s1, s2

  if bit.btest(j1, 1) then
    if j2 < 0x60 then
	s2 = j2 + 0x1f
    else
	s2 = j2 + 0x20
    end
  else
    s2 = j2 + 0x7e
  end
  if j1 < 0x5f then
    s1 = bit.bshift(j1 + 0xe1, -1)
  else
    s1 = bit.bshift(j1 + 0x161, -1)
  end
  return s1, s2
end

-- convert from JIS(X0213 second plane) to SJIS
local function jis_to_sjis2(j1, j2)
  local s1, s2
  local k = j1 - 0x20

  if k == 1 or (3 <= k and k <= 5) or k == 8 or (12 <= k and k <= 15) then
    s1 = bit.bshift(k + 0x1df, -1) - bit.bshift(k, -3) * 3
  elseif k >= 78 and k <= 94 then
    s1 = bit.bshift(k + 0x19b, -1)
  else
    return nil
  end
  if bit.btest(k, 1) then
    if j2 <= 0x5f then
      s2 = j2 + 0x1f
    else
      s2 = j2 + 0x20
    end
  else
    s2 = j2 + 0x7e
  end
  return s1, s2
end

-- convert from SJIS to JIS(X0213 first plane)
local function sjis_to_jis(s, s2)
  local j, j2

  j = bit.bshift(s, 1)
  if s <= 0x9f then
    if s2 < 0x9f then
      j = j - 0xe1
    else
      j = j - 0xe0
    end
  else
    if s2 < 0x9f then
      j = j - 0x161
    else
      j = j - 0x160
    end
  end
  if s2 < 0x7f then
    j2 = s2 - 0x1f
  elseif s2 < 0x9f then
    j2 = s2 - 0x20
  else
    j2 = s2 - 0x7e
  end
  return j, j2
end

-- convert from SJIS to JIS(X0213 second plane)
local function sjis_to_jis2(s, s2)
  local plane2sjis = {
    { 0x21, 0x28 }, { 0x23, 0x24 }, { 0x25, 0x20 + 12 },
    { 0x20 + 13, 0x20 + 14 }, {0x20 + 15, 0x20 + 78 }
  }
  local odd = s2 <= 0x9e and 0 or 1
  if s <= 0xf4 then
    j = plane2sjis[s - 0xf0 + 1][odd + 1]
  else
    j = 79 + bit.bshift(s - 0xf5, 1) + odd + 0x20
  end
  if s2 < 0x7f then
    j2 = s2 - 0x1f
  elseif s2 < 0x9f then
    j2 = s2 - 0x20
  else
    j2 = s2 - 0x7e
  end
  return j, j2
end

-- [[ Converting function ]] --

-- convert from SJIS to SJIS
local function sjis_input(str)
  return str
end

-- convert from SJIS to SJIS
local function sjis_output(str)
  return str
end

-- convert from EUC to SJIS
local function euc_input(str)
  local out = {}
  local spos = 1
  local c, c2

  while spos <= #str do
    c, spos = getc(str, spos)
    if is_euc_ascii(c) then
      putc(out, c)
    elseif c == SS2 then
      if spos > #str then
	putc(out, c)
      else
	c, spos = getc(str, spos)
	if not is_euc_x0201(c) then
	  putc(out, SS2)
	  spos = spos -1
	else
	  putc(out, c)
	end
      end
    elseif is_euc_x0213(c) then
      if spos > #str then
	putc(out, c)
      else
	c2, spos = getc(str, spos)
	if is_euc_x0213(c2) then
	  c, c2 = jis_to_sjis(GR_to_GL(c), GR_to_GL(c2))
	end
	putc(out, c)
	putc(out, c2)
      end
    elseif c == SS3 then
      if spos > #str then
	putc(out, c)
      else
	c, spos = getc(str, spos)
	if spos > #str then
	  putc(out, SS3)
	  putc(out, c)
	else
	  c2, spos = getc(str, spos)
	  if is_euc_x0213(c2) then
	    local cc, cc2 = jis_to_sjis2(GR_to_GL(c), GR_to_GL(c2))
	    if cc then c, c2 = cc, cc2 end
	  end
	  putc(out, c)
	  putc(out, c2)
	end
      end
    else
      putc(out, c)
    end
  end
  return table2str(out)
end

-- convert from SJIS to EUC
local function euc_output(str)
  local out = {}
  local spos = 1
  local c, c2, j, j2

  while spos <= #str do
    c, spos = getc(str, spos)
    if is_sjis_ascii(c) then
      putc(out, c)
    elseif is_sjis_x0201(c) then
      putc(out, SS2)
      putc(out, c)
    elseif is_sjis_x0213_first(c) then
      if spos > #str then
	putc(out, c)
      else
	c2, spos = getc(str, spos)
	if not is_sjis_x0213_second(c2) then
	  putc(out, c)
	  spos = spos - 1
	else
	  if is_sjis_x0213_1_first(c) then
	    j, j2 = sjis_to_jis(c, c2)
	  else
	    j, j2 = sjis_to_jis2(c, c2)
	    putc(out, SS3)
	  end
	  putc(out, GL_to_GR(j))
	  putc(out, GL_to_GR(j2))
	end
      end
    else
      putc(out, c)
    end
  end
  return table2str(out)
end

-- convert from JIS to SJIS
local function jis_input(str)
  local ASCII, X0201, X0213_1, X0213_2 = 1, 2, 3, 4
  local mode = ASCII
  local ESC_sequence = {
    ["(B"] = ASCII,
    ["(@"] = ASCII,
    ["(I"] = X0201,
    ["$(Q"] = X0213_1,
    ["$(O"] = X0213_1,
    ["$B"] = X0213_1,
    ["$@"] = X0213_1,
    ["$(P"] = X0213_2
  }
  local out = {}
  local spos = 1
  local c, c2

  while spos <= #str do
    c, spos = getc(str, spos)
    if c == ESC then
      local found = false
      for seq, m in pairs(ESC_sequence) do
	if str:sub(spos, spos + #seq - 1) == seq then
	  mode = m
	  spos = spos + #seq
	  found = true
	  break
	end
      end
      if not found then
	putc(out, c)
      end
    elseif c == SO then
      mode = X0201
    elseif c == SI then
      mode = ASCII
    else
      if mode == ASCII then
	putc(out, c)
      elseif mode == X0201 then
	if not is_jis_x0201(c) then
	  putc(out, c)
	else
	  putc(out, GL_to_GR(c))
	end
      elseif mode == X0213_1 or mode == X0213_2 then
	if not is_jis_x0213(c) or spos > #str then
	  putc(out, c)
	else
	  c2, spos = getc(str, spos)
	  if is_jis_x0213(c2) then
	    if mode == X0213_1 then
	      c, c2 = jis_to_sjis(c, c2)
	    else
	      local cc, cc2 = jis_to_sjis2(c, c2)
	      if cc then c, c2 = cc, cc2 end
	    end
	  end
	  putc(out, c)
	  putc(out, c2)
	end
      else
	putc(out, c)
      end
    end
  end
  return table2str(out)
end

-- convert from SJIS to JIS
local function jis_output(x0213_2004, compatible)
  return function (str)
	   local ASCII, X0201, X0213_1, X0213_2 = 1, 2, 3, 4
	   local mode = ASCII
	   local out = {}
	   local spos = 1
	   local c, c2, j, j2

	   local function isDefinedInX0208(c, c2)
	     local ku = c - 0x20
	     local ten = c - 0x20

	     if ku == 1 then return true end
	     if ku == 2 and
	       (ten <= 14 or
		(26 <= ten and ten <= 33) or
	        (42 <= ten and ten <= 48) or
	        (60 <= ten and ten <= 74) or
	        (82 <= ten and ten <= 89) or
	        ten == 94) then
	       return true
	     end
	     if ku == 3 and
	       ((16 <= ten and ten <= 25) or
	        (33 <= ten and ten <= 58) or
	        (65 <= ten and ten <= 90)) then
	       return true
	     end
	     if ku == 4 and ten <= 83 then return true end
	     if ku == 5 and ten <= 86 then return true end
	     if ku == 6 and (ten <= 24 or (33 <= ten and ten <= 56)) then
	       return true
	     end
	     if ku == 7 and (ten <= 33 or (49 <= ten and ten <= 81)) then
	       return true
	     end
	     if ku == 8 and ten <= 32 then return true end
	     if (16 <= ku and ku <= 46) or
	        (ku == 47 and ten <= 51) then
	       return true
	     end
	     if (48 <= ku and ku <= 83) or
	        (ku == 84 and ten <= 6) then
	       return true
	     end
	     return false
	   end

	   local function mode_change(omode, nmode)
	     local ESC_sequence = {
	       [ASCII] = "\027(B",
	       [X0201] = "\027(I",
	       [X0213_1] = { "\027$B", "\027$(Q", "\027$(O" },
	       [X0213_2] = "\027$(P"
	     }
	     if omode ~= nmode then
	       if nmode == X0213_1 then
		 if compatible and isDefinedInX0208(j, j2) then
		   puts(out, ESC_sequence[X0213_1][1])
		 elseif x0213_2004 then
		   puts(out, ESC_sequence[X0213_1][2])
		 else
		   puts(out, ESC_sequence[X0213_1][3])
		 end
	       else
		 puts(out, ESC_sequence[nmode])
	       end
	     end
	     return nmode
	   end

	   while spos <= #str do
	     c, spos = getc(str, spos)
	     if is_sjis_ascii(c) then
	       mode = mode_change(mode, ASCII)
	       putc(out, c)
	     elseif is_sjis_x0201(c) then
	       mode = mode_change(mode, X0201)
	       putc(out, GR_to_GL(c))
	     elseif is_sjis_x0213_first(c) then
	       if spos > #str then
		 putc(out, c)
	       else
		 c2, spos = getc(str, spos)
		 if not is_sjis_x0213_second(c2) then
		   putc(out, c)
		   spos = spos - 1
		 else
		   if is_sjis_x0213_1_first(c) then
		     j, j2 = sjis_to_jis(c, c2)
		     mode = mode_change(mode, X0213_1)
		   else
		     j, j2 = sjis_to_jis2(c, c2)
		     mode = mode_change(mode, X0213_2)
		   end
		   putc(out, j)
		   putc(out, j2)
		 end
	       end
	     else
	       putc(out, c)
	     end
	   end
	   mode_change(mode, ASCII)
	   return table2str(out)
	 end
end


----- Unicode -----

-- [[ Load conversion table ]] --

--loadfile("kconv_utable.lua")()
collectgarbage("collect")

-- [[ Support function ]] --

-- convert Unicode to SJIS
local function unicode_to_sjis(u)
  if u <= 0x7f then return u end
  if utable.utable_unicode_to_sjis[0x3000] then
    local s = utable.utable_unicode_to_sjis[u]
    if not s then return false end
    if type(s) == "table" then
      return s[uopt] or s[1] or false
    end
    return s
  else
    for k, v in pairs(utable.utable_sjis_to_unicode) do
      if u == v or
	(type(v) == "table" and u == v[uopt]) then
	return k
      end
    end
    return false
  end
end

-- convert SJIS to Unicode
local function sjis_to_unicode(s)
  local u = utable.utable_sjis_to_unicode[s]
  if type(u) == "table" then
    return u[uopt]
  end
  if u and u >= 0x00110000 then
    return bit.bshift(u, -16), bit.band(u, 0xffff)
  end
  return u
end

-- convert Unicode to SJIS (X0201 character)
local function unicode_to_sjis_x0201(u)
  return u - 0xff61 + 0xa1
end

-- convert SJIS to Unicode (X0201 character)
local function sjis_to_unicode_x0201(s)
  return s + 0xff61 - 0xa1
end

-- convert Unicode to SJIS (combined character)
local function unicode_to_sjis_combined(u, u2)
  if not u2 then return false end
  for k, t in pairs(utable.unicode_combined_table) do
    if t[1] == u then
      if u2 == 0 then return true end
      if t[2] == u2 then return k end
    end
  end
  return false
end

-- check first combined character or not
local function isUnicodeCombined1(u)
  return unicode_to_sjis_combined(u, 0)
end

----- Unicode -----

-- [[ kconv.bom( ) ]] --

local function bom(code)
  local bomTable = {
    ["utf-8"] = "\239\187\191",
    ["utf-16"] = "\254\255",
    ["utf-16-be"] = "\254\255",
    ["utf-16-le"] = "\255\254"
  }
  local bom = bomTable[code or "utf-16"]
  if not bom then
    error('not support such kanji code "' .. tostring(code) .. '"', 2)
  end
  return bom
end


-- [[ Converting function ]] --

-- UTF-8 to SJIS
local function u8_input(str)
  local out = {}
  local spos = 1
  local u

  local function u8_input_1(str, spos)
    local c, spos = getc(str, spos)
    if c < 0x80 then return c, spos end
    local n, cc = 0, c
    while bit.btest(cc, 0x80) do
      n = n + 1
      cc = bit.bshift(cc, 1)
    end
    if n < 2 or n > 4 then return false end
    local u = bit.band(c, bit.bshift(1, 7 - n) - 1)
    for i = 1, n - 1 do
      if spos > #str then return false end
      c, spos = getc(str, spos)
      if bit.band(c, 0xc0) ~= 0x80 then return false end
      u = bit.bor(bit.bshift(u, 6), bit.band(c, 0x3f))
    end
    return u, spos
  end

  local function u8_output_1(u)
    local s = unicode_to_sjis(u)
    if not s then
      return true
    elseif s <= 0xff then
      putc(out, s)
    else
      putc(out, bit.bshift(s, -8))
      putc(out, bit.band(s, 0xff))
    end
    return false
  end

  if str:sub(1, 3) == bom("utf-8") then
    spos = 4
  end

  while spos <= #str do
    local sspos, err = spos, false
    u, spos = u8_input_1(str, spos)
    if not u then
      err = true
    elseif u < 0x80 then
      putc(out, u)
    elseif u >= 0xff61 and u <= 0xff9f then
      local s = unicode_to_sjis_x0201(u)
      putc(out, s)
    elseif isUnicodeCombined1(u) then
      if spos > #str then
	err = u8_output_1(u)
      else
	local u2, spos2 = u8_input_1(str, spos)
	local s = unicode_to_sjis_combined(u, u2)
	if not u2 or not s then
	  err = u8_output_1(u)
	else
	  putc(out, bit.bshift(s, -8))
	  putc(out, bit.band(s, 0xff))
	  spos = spos2
	end
      end
    else
      err = u8_output_1(u)
    end
    if err then
      local c
      c, spos = getc(str, sspos)
      putc(out, c)
    end
  end
  return table2str(out)
end

-- SJIS to UTF-8
local function u8_output(str)
  local function u8_output_1(out, u)
    if u < 0x80 then
      putc(out, u)
    elseif u < 0x0800 then
      putc(out, bit.bor(0xc0, bit.bshift(u, -6)))
      putc(out, bit.bor(0x80, bit.band(u, 0x3f)))
    elseif u < 0x10000 then
      putc(out, bit.bor(0xe0, bit.bshift(u, -12)))
      putc(out, bit.bor(0x80, bit.band(bit.bshift(u, -6), 0x3f)))
      putc(out, bit.bor(0x80, bit.band(u, 0x3f)))
    else
      putc(out, bit.bor(0xf0, bit.bshift(u, -18)))
      putc(out, bit.bor(0x80, bit.band(bit.bshift(u, -12), 0x3f)))
      putc(out, bit.bor(0x80, bit.band(bit.bshift(u, -6), 0x3f)))
      putc(out, bit.bor(0x80, bit.band(u, 0x3f)))
    end
  end

  local out = {}
  local spos = 1
  local c, c2

  while spos <= #str do
    c, spos = getc(str, spos)
    if is_sjis_ascii(c) then
      putc(out, c)
    elseif is_sjis_x0201(c) then
      local u = sjis_to_unicode_x0201(c)
      putc(out, bit.bshift(u, -8))
      putc(out, bit.band(u, 0xff))
    elseif is_sjis_x0213_first(c) then
      if spos > #str then
	putc(out, c)
      else
	c2, spos = getc(str, spos)
	if not is_sjis_x0213_second(c2) then
	  putc(out, c)
	  spos = spos - 1
	else
	  local u, u2 = sjis_to_unicode(c * 256 + c2)
	  if not u then
	    putc(out, c)
	    putc(out, c2)
	  else
	    u8_output_1(out, u)
	    if u2 then u8_output_1(out, u2) end
	  end
	end
      end
    else
      putc(out, c)
    end
  end
  return table2str(out)
end

-- UTF-16 to SJIS
local function u16_input(le)
  return function (str)
	   local out = {}
	   local spos = 1
	   local u, u2

	   if str:sub(1, 2) == bom(le and "utf-16-le" or "utf-16-be") then
	     spos = 3
	   end

	   local function u16_input_1(str, spos)
	     local c, c2, u, u2
	     c, spos = getc(str, spos)
	     c2, spos = getc(str, spos)
	     u = le and (c2 * 256 + c) or (c * 256 + c2)
	     if u >= 0xd800 and u <= 0xdfff then
	       if spos > #str - 1 then return false end
	       c, spos = getc(str, spos)
	       c2, spos = getc(str, spos)
	       u2 = le and (c2 * 256 + c) or (c * 256 + c2)
	       if u2 < 0xdc00 or u2 > 0xdfff then return false end
	       u = bit.bor(bit.bshift(bit.band(u, 0x03ff), 10),
			   bit.band(u2, 0x03ff)) + 0x10000
	     end
	     return u, spos
	   end

	   local function u16_output_1(u)
	     local s = unicode_to_sjis(u)
	     if not s then
	       return true
	     elseif s <= 0xff then
	       putc(out, s)
	     else
	       putc(out, bit.bshift(s, -8))
	       putc(out, bit.band(s, 0xff))
	     end
	     return false
	   end

	   while spos <= #str do
	     local sspos, err = spos, false
	     u, spos = u16_input_1(str, spos)
	     if not u then
	       err = true
	     elseif isUnicodeCombined1(u) then
	       if spos > #str then
		 err = u16_output_1(u)
	       else
		 local u2, spos2 = u16_input_1(str, spos)
		 local s = unicode_to_sjis_combined(u, u2)
		 if not u2 or not s then
		   err = u16_output_1(u)
		 else
		   putc(out, bit.bshift(s, -8))
		   putc(out, bit.band(s, 0xff))
		   spos = spos2
		 end
	       end
	     else
	       err = u16_output_1(u)
	     end
	     if err then
	       local c, c2
	       c, spos = getc(str, sspos)
	       c2, spos = getc(str, spos)
	       putc(out, c)
	       putc(out, c2)
	     end
	   end
	   return table2str(out)
	 end
end

-- SJIS to UTF-16
local function u16_output(le)
  return function (str)
	   local function u16_output_1(out, u)
	     local function u16_output_2(out, u)
	       if le then
		 putc(out, bit.band(u, 0xff))
		 putc(out, bit.bshift(u, -8))
	       else
		 putc(out, bit.bshift(u, -8))
		 putc(out, bit.band(u, 0xff))
	       end
	     end

	     if u <= 0xffff then
	       u16_output_2(out, u)
	     else
	       u16_output_2(out, bit.bor(0xd800, bit.bshift(u - 0x10000, -10)))
	       u16_output_2(out, bit.bor(0xdc00, bit.band(u, 0x03ff)))
	     end
	   end

	   local out = {}
	   local spos = 1
	   local c, c2

	   while spos <= #str do
	     c, spos = getc(str, spos)
	     if is_sjis_ascii(c) then
	       u16_output_1(out, c)
	     elseif is_sjis_x0201(c) then
	       u16_output_1(out, sjis_to_unicode_x0201(c))
	     elseif is_sjis_x0213_first(c) then
	       if spos > #str then
		 putc(out, c)
	       else
		 c2, spos = getc(str, spos)
		 if not is_sjis_x0213_second(c2) then
		   putc(out, c)
		   spos = spos - 1
		 else
		   local u, u2 = sjis_to_unicode(c * 256 + c2)
		   if not u then
		     putc(out, c)
		     putc(out, c2)
		   else
		     u16_output_1(out, u)
		     if u2 then u16_output_1(out, u2) end
		   end
		 end
	       end
	     else
	       putc(out, c)
	     end
	   end
	   return table2str(out)
	 end
end

----- Unicode -----

-- [[ kconv.kconvert( ) ]] --

local function kconvert(str, icode, ocode, opt)
  local convTable = {
    { code = "sjis", input = sjis_input, output = sjis_output },
    { code = "euc", input = euc_input, output = euc_output },
    { code = "jis", input = jis_input, output = jis_output(true, true) },
    { code = "iso-2022-jp-2004", input = jis_input, output = jis_output(true, false) },
    { code = "iso-2022-jp-2004-compatible", input = jis_input, output = jis_output(true, true) },
    { code = "iso-2022-jp-3", input = jis_input, output = jis_output(false, false) },
    { code = "iso-2022-jp-3-compatible", input = jis_input, output = jis_output(false, true) },
----- Unicode -----
    { code = "utf-8", input = u8_input, output = u8_output },
    { code = "utf-16", input = u16_input(false), output = u16_output(false) },
    { code = "utf-16-be", input = u16_input(false), output = u16_output(false) },
    { code = "utf-16-le", input = u16_input(true), output = u16_output(true) }
----- Unicode -----
  }
  local function getTable(code)
    for _, t in pairs(convTable) do
      if t.code == code then return t end
    end
    error('not support such kanji code "' .. code .. '"', 3)
  end
  local itable, otable = getTable(icode), getTable(ocode)
  local saved_uopt = uopt
  if opt then
    if opt == "cp932" or opt == "x0213" then
      uopt = opt
    else
      error('unknown option "' .. tostring(opt) ..'"', 2)
    end
  end
  local ret = otable.output(itable.input(str))
  uopt = saved_uopt
  return ret
end

----- Unicode -----

local M = {}
M.bit = bit
M.kconvert = kconvert
M.bom = bom
return M
