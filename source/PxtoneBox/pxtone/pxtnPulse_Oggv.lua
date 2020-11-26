local	CONST = import(".pxtnConst")

local	PxtnPulse_Oggv = {}
PxtnPulse_Oggv = class("PxtnPulse_Oggv")


function PxtnPulse_Oggv:ctor(...)
	
	self.m_data = nil
	self.m_ch = 0
	self.m_sps2 = 0
	self.m_smp_num = 0
	self.m_size = 0
end


function PxtnPulse_Oggv:getSize()
	return self.m_size + 4 * 4
end


function PxtnPulse_Oggv:ogg_write(desc)
	local	res = true
	if res then res = desc:w_asfile(self.m_data) end
	return res
end


function PxtnPulse_Oggv:pxtn_write(desc)
	local	res = true
	
	if res then res = desc:w_asfile(self.m_ch, 4, "integer") end
	if res then res = desc:w_asfile(self.m_sps2, 4, "integer") end
	if res then res = desc:w_asfile(self.m_smp_num, 4, "integer") end
	if res then res = desc:w_asfile(self.m_size, 4, "integer") end
	if res then res = desc:w_asfile(self.m_data) end
	
	return res
end


function PxtnPulse_Oggv:pxtn_read(desc)
	
	self.m_ch, self.m_sps2, self.m_smp_num, self.m_size = desc:r({4, 4, 4, 4}, "integer")
	if self.m_ch == nil then return CONST.ERR.ERR_desc_r end
	self.m_data = desc:r(self.m_size)
	if self.m_data == nil then return CONST.ERR.ERR_desc_r end
	
	return CONST.ERR.OK
end


return PxtnPulse_Oggv
