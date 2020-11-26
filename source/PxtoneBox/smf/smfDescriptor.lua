local	CONST = import(".smfConst")

local	SmfDescriptor = {}
SmfDescriptor = class("SmfDescriptor")

function SmfDescriptor:ctor(...)
	self.m_fileName = nil
	self.m_isLove2d = false
	self.m_file = nil
end


function SmfDescriptor:get_cur()
	if self.m_isLove2d then
		return self.m_file:tell()
	else
		return self.m_file:seek()
	end
end


function SmfDescriptor:get_size()
	if self.m_isLove2d then
		return self.m_file:getSize()
	else
		local	cur = self:get_cur()
		local	size = self.m_file:seek("end")
		self.m_file:seek("set", cur)
		return size
	end
end


function SmfDescriptor:set_file_r(fileName, isLove2d)
	isLove2d = isLove2d or false
	if isLove2d == true then
		self.m_file = love.filesystem.newFile(fileName)
		if self.m_file then
			self.m_file:open("r")
		end
	else
		self.m_file = io.open(fileName, "rb")
	end
end


function SmfDescriptor:set_file_w(fileName, isLove2d)
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


function SmfDescriptor:commit(unit, callback)
	unit = unit or 1024
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


function SmfDescriptor:w_asfile(value, size, tp)
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
		end
		if type(value) ~= "string" then return false end
		
		self.m_file:write(value)
	end
	return true
end


function SmfDescriptor:r(size, tp)
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
		if tp == "integer" then
			res = self:string_to_integer(str, size)
		else
			res = str
		end
		return res
	end
end


function SmfDescriptor:v_w_asfile(num)
	local	res = true
	local	size = self:v_chk(num)
	for i = 1, size do
		local	v_num = bit.band(bit.rshift(num, 7 * (size - i)), 0x7f)
		if i ~= size then
			v_num = v_num + 0x80
		end
		self:w_asfile(string.char(v_num))
	end
	return res
end


function SmfDescriptor:v_r(count)
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
			res = res + bit.band(byte, 0x7f)
			if bit.band(byte, 0x80) == 0 then break end
			res = bit.lshift(res, 7)
		end
		
		return res
	end
end


function SmfDescriptor:v_chk(num)
	if num <        0x80 then return 1 end
	if num <      0x4000 then return 2 end
	if num <    0x200000 then return 3 end
	if num <  0x10000000 then return 4 end
	if num <= 0xffffffff then return 5 end
	return 6
end


function SmfDescriptor:string_to_integer(str, size)
	-- stringをintegerに変換（sizeはbyteで指定）
	size = size or #str
	local	res = 0
	for i = size, 1, -1 do
		res = res + bit.lshift(string.byte(string.sub(str, i, i)), 8 * (size - i))
	end
	return res
end


function SmfDescriptor:integer_to_string(num, size)
	-- integerをstringに変換（sizeはbyteで指定）
	size = size or 0
	local	res = ""
	for i = size, 1, -1 do
		local	c = string.char(bit.band(bit.rshift(num, 8 * (i - 1)), 0xff))
		res = res .. c
	end
	return res
end


function SmfDescriptor:seek(mode, val)
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


return SmfDescriptor

