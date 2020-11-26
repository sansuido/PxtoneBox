local	CONST = import(".pxtnConst")

local	PxtnOverDrive = {}
PxtnOverDrive = class("PxtnOverDrive")


function PxtnOverDrive:ctor(...)
	self.m_group = nil
	self.m_cut = nil
	self.m_amp = nil
end

function PxtnOverDrive:write(desc)
	local	res = true
	local	size = 2 + 2 + 4 + 4 + 4
	local	xxx, group, cut, amp, yyy = 0, self.m_group, self.m_cut, self.m_amp, 0
	
	if res then res = desc:w_asfile(size, 4, "integer") end
	if res then res = desc:w_asfile(xxx, 2, "integer") end
	if res then res = desc:w_asfile(group, 2, "integer") end
	if res then res = desc:w_asfile(cut, 4, "float") end
	if res then res = desc:w_asfile(amp, 4, "float") end
	if res then res = desc:w_asfile(yyy, 4, "float") end
	
	return res
end


function PxtnOverDrive:read(desc)
	local	size, xxx, group, cut, amp, yyy = desc:r({4, 2, 2, 4, 4, 4}, {"integer", "integer", "integer", "float", "float", "integer"})
	if size == nil then return CONST.ERR.ERR_desc_r end
	
	self.m_group = group
	self.m_cut = cut
	self.m_amp = amp
	
	return CONST.ERR.OK
end

return PxtnOverDrive

