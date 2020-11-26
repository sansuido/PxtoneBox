local	CONST = import(".pxtnConst")

local	PxtnUnit = {}
PxtnUnit = class("PxtnUnit")

function PxtnUnit:ctor(...)
	self.m__bPlayed   = true;
	self.m__bOperated = true;
	self.m_name = "no name"
end


function PxtnUnit:set_name(name)
	self.m_name = name
end


function PxtnUnit:get_name()
	return self.m_name
end


function PxtnUnit:get_write_name()
	-- 書き込み時名称を取得（ゼロで埋めとく）
	local	size = #self.m_name
	return self.m_name .. string.rep(string.char(0x00), CONST.MAX_TUNEUNITNAME - size)
end


function PxtnUnit:read_v3x(desc)
	local	size, tp, group = desc:r({4, 2, 2}, "integer")
	if size == nil then return CONST.ERR.ERR_desc_r end
	
	return CONST.ERR.OK, group
end


return PxtnUnit

