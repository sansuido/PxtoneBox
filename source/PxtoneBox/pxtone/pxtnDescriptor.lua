local	CONST = import(".pxtnConst")

local	PxtnDescriptor = {}
PxtnDescriptor = class("PxtnDescriptor")

function PxtnDescriptor:ctor(...)
	self.m_fileName = nil
	self.m_isLove2d = false
end


function PxtnDescriptor:get_cur()
	if self.m_isLove2d == true then
		return self.m_file:tell()
	else
		return self.m_file:seek()
	end
end


function PxtnDescriptor:get_size()
	if self.m_isLove2d == true then
		return self.m_file:getSize()
	else
		local	cur = self:get_cur()
		local	size = self.m_file:seek("end")
		self.m_file:seek("set", cur)
		return size
	end
end


function PxtnDescriptor:set_file_r(fileName, isLove2d)
	self.m_isLove2d = isLove2d or false
	if self.m_isLove2d == true then
		self.m_file = love.filesystem.newFile(fileName)
		if self.m_file then
			self.m_file:open("r")
		end
	else
		self.m_file = io.open(fileName, "rb")
	end
end


function PxtnDescriptor:set_file_w(fileName, isLove2d)
	local	bl, err
	self.m_fileName = fileName
	self.m_isLove2d = isLove2d or false
	
	if self.m_isLove2d == true then
		self.m_file, err = love.filesystem.newFile(self.m_fileName)
		if self.m_file then
			bl, err = self.m_file:open("w")
			if bl == false then
--				error(err)
			end
		else
--			error(err)
		end
	else
		self.m_file, err = io.open(self.m_fileName, "wb")
		if self.m_file == nil then
--			error(err)
		end
	end
	
	if err then
		error(err)
	end
end



function PxtnDescriptor:commit(unit, callback)
	if self.m_isLove2d == true then
		if self.m_file then
			if callback then callback(self:get_size()) end
			self.m_file:close()
			self.m_file = nil
		end
	else
		if self.m_file then
			if callback then callback(self:get_size()) end
			self.m_file:close()
			self.m_file = nil
		end
	end
end


function PxtnDescriptor:w_asfile(value, size, tp)
	local	res
	if type(value) == "table" then
		for i, v in ipairs(value) do
			local	one_size = size
			local	one_tp = tp
			if type(one_size) == "table" then one_size = size[i] or size[#size] end
			if type(one_tp  ) == "table" then one_tp   = tp[i]   or tp[#tp]     end
			res = self:w_asfile(v, one_size, one_tp)
			if res == false then return res end
		end
	else
		
		tp = tp or "string"
		if tp == "integer" then
			value = self:integer_to_string(value, size)
		elseif tp == "float" then
			value = self:float_to_string(value)
		end
		if type(value) ~= "string" then return false end
		
		self.m_file:write(value)
	end
	return true
end


function PxtnDescriptor:r(size, tp)
	tp = tp or "string"
	if type(size) == "table" then
		-- テーブル渡しの場合は渡した分だけ戻り値を返す
		local	results = {}
		for i, sz in ipairs(size) do
			local	one_tp = tp
			if type(tp) == "table" then
				-- 見つからんかったら、最後のを繰り返す（予防線）
				one_tp = tp[i] or tp[#tp]
			end
			local	res = self:r(sz, one_tp)
			if res == nil then return nil end
			table.insert(results, res)
		end
		return unpack(results)
	else
		
		-- 現状位置からsize分読み込む
		local	res = nil
		local	str
		if self.m_isLove2d then
			str = self.m_file:read(size)
		else
			str = self.m_file:read(size)
		end
		
		if tp == "float" then
			res = self:string_to_float(str)
		elseif tp == "integer" then
			res = self:string_to_integer(str, size)
		else
			res = str
		end
		return res
	end
end


function PxtnDescriptor:v_w_asfile(num)
	local	res = true
	local	size = self:v_chk(num)
	for i = 1, size do
		local	v_num = bit.band(bit.rshift(num, 7 * (i - 1)), 0x7f)
		if i ~= size then
			v_num = v_num + 0x80
		end
		self:w_asfile(string.char(v_num))
	end
	return res
end


function PxtnDescriptor:v_r(count)
	count = count or nil
	if type(count) == "number" then
		local	results = {}
		for i = 1, count do
			res = self:v_r()
			if res == nil then return nil end
			table.insert(results, res)
		end
		return unpack(results)
	else
		local	res = 0
		for i = 1, 5 do
			local	byte = self:r(1, "integer")
			if byte == nil then return nil end
			res = res + bit.lshift(bit.band(byte, 0x7f), 7 * (i - 1))
			if bit.band(byte, 0x80) == 0 then break end
		end
		return res
	end
end


function PxtnDescriptor:v_chk(num)
	if num <        0x80 then return 1 end
	if num <      0x4000 then return 2 end
	if num <    0x200000 then return 3 end
	if num <  0x10000000 then return 4 end
	if num <= 0xffffffff then return 5 end
	return 6
end


function PxtnDescriptor:string_to_integer(str, size)
	-- stringをintegerに変換（sizeはbyteで指定）
	size = size or #str
	local	res = 0
	for i = 1, size do
		res = res + bit.lshift(string.byte(string.sub(str, i, i)),  8 * (i - 1))
	end
	return res
end


function PxtnDescriptor:integer_to_string(num, size)
	-- integerをstringに変換（sizeはbyteで指定）
	size = size or 0
	local	res = ""
	for i = 1, size do
		local	c = string.char(bit.band(bit.rshift(num, 8 * (i - 1)), 0xff))
		res = res .. c
	end
	return res
end


function PxtnDescriptor:string_to_bt(str)
	-- stringをbittableに変換
	local	bt = {}
	for i = #str, 1, -1 do
		for shift = 8, 1, -1 do
			table.insert(bt, bit.band(bit.rshift(string.byte(str, i, i), shift - 1), 0x01))
		end
	end
	return bt
end


function PxtnDescriptor:bt_to_string(bt)
	-- bittableをstringに変換
	local	str = ""
	local	pos = 1
	local	byte = #bt / 8
	
	for i = byte, 1, -1 do
		local	code = 0
		for shift = 8, 1, -1 do
			local	pos = (i - 1) * 8 + shift
			code = code + bit.lshift(bt[pos], 8 - shift)
		end
		str = str .. string.char(code)
	end
	return str
end


function PxtnDescriptor:integer_to_bt(num, size)
	-- integerをbittableに変換（sizeはbyteで指定）
	size = size or 0
	local	bt = {}
	for i = 1, size * 8 do
		bt[i] = 0
		if bit.band(num, math.pow(2, size * 8 - i)) ~= 0 then
			bt[i] = 1
		end
	end
	return bt
end


function PxtnDescriptor:bt_to_integer(bt)
	-- bittableをintegerに変換
	local	res = 0
	for i = 1, #bt do
		if bt[i] == 1 then
			res = res + math.pow(2, #bt - i)
		end
	end
	return res
end


function PxtnDescriptor:bt_to_float(bt)
	-- integerをfloatに変換
	local	res = 0
	if #bt ~= 32 then return 0 end
	local	count = 0
	for i = 1, #bt do
		if bt[i] == 1 then count = count + 1 end
	end
	if count == 0 then return 0 end
	
	res = 1
	local	sign = 1
	local	index = 0
	
	-- 符号
	if bt[1] == 1 then sign = -1 end
	-- 指数部
	for i = 2, 9 do
		if bt[i] == 1 then
			index = index + math.pow(2, 9 - i)
		end
	end
	index = index - 0x7f
	-- 仮数部
	for i = 10, 32 do
		if bt[i] == 1 then
			res = res + math.pow(2, (i - 9) * -1)
		end
	end
	-- 算出
	res = res * sign * math.pow(2, index)
	return res
end


function PxtnDescriptor:float_to_bt(num)
	-- floatをbittableに変換
	local	bt = self:integer_to_bt(0, 4)
	if num ~= 0 then
		local	index = 0
		-- 符号
		if num < 0 then
			bt[1] = 1
		end
		num = math.abs(num)
		-- 指数部
		while num >= 2 do
			num = num / 2
			index = index + 1
		end
		while num < 1 do
			num = num * 2
			index = index - 1
		end
		index = index + 0x7f
		for i = 2, 9 do
			if bit.band(index, math.pow(2, 9 - i)) ~= 0 then
				bt[i] = 1
			end
		end
		num = num - 1
		-- 仮数部
		for i = 1, 23 do
			if num >= math.pow(2, i * -1) then
				num = num - math.pow(2, i * -1)
				bt[i + 9] = 1
			end
		end
	end
	return bt
end


function PxtnDescriptor:integer_to_float(num) return self:bt_to_float(self:integer_to_bt(num, 4)) end
function PxtnDescriptor:float_to_integer(num) return self:bt_to_integer(self:float_to_bt(num)) end
function PxtnDescriptor:string_to_float(str) return self:bt_to_float(self:string_to_bt(str)) end
function PxtnDescriptor:float_to_string(num) return self:bt_to_string(self:float_to_bt(num)) end


function PxtnDescriptor:seek(mode, val)
	
	if self.m_isLove2d == true then
		if mode == CONST.SEEK.SET then
			self.m_file:seek(0 + val)
		elseif mode == CONST.SEEK.CUR then
			self.m_file:seek(self.m_file:tell() + val)
		elseif mode == CONST.SEEK.END then
			self.m_file:seek(self.m_file:getSize() + val)
		end
		return true
	else
		if mode == CONST.SEEK.SET then
			self.m_file:seek("set", val)
		elseif mode == CONST.SEEK.SET then
			self.m_file:seek("cur", val)
		elseif mode == CONST.SEEK.END then
			self.m_file:seek("end", val)
		end
		return true
	end
	return true
end


return PxtnDescriptor

