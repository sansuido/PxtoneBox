local	CONST = import(".pxtnConst")

local	PxtnDelay = {}
PxtnDelay = class("PxtnDelay")

function PxtnDelay:ctor(...)
	
	self.m_b_played = true
	self.m_unit     = CONST.DELAYUNIT.Beat
	self.m_group    =    0
	self.m_rate     = 33.0
	self.m_freq     =  3.0
	self.m_smp_num  =    0
	self.m_offset   =    0
	self.m_rate_s32 =  100
end


function PxtnDelay:write(desc)
	local	res = true
	local	size = 2 + 2 + 4 + 4
	
	if res then res = desc:w_asfile(size, 4, "integer") end
	if res then res = desc:w_asfile(self.m_unit, 2, "integer") end
	if res then res = desc:w_asfile(self.m_group, 2, "integer") end
	if res then res = desc:w_asfile(self.m_rate, 4, "float") end
	if res then res = desc:w_asfile(self.m_freq, 4, "float") end
	
	return res
end

function PxtnDelay:read(desc)
	-- 2, 2, 4, 4
	local	size, unit, group, rate, freq = desc:r({4, 2, 2, 4, 4}, {"integer", "integer", "integer", "float", "float"})
	if size == nil then return CONST.ERR.ERR_desc_r end
	
	self.m_unit = unit
	self.m_freq = freq
	self.m_rate = rate
	self.m_group = group
	
	return CONST.ERR.OK
end


return PxtnDelay
