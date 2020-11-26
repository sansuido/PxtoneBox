local	CONST = import(".pxtnConst")

local	PxtnPulse_PCM = {}
PxtnPulse_PCM = class("PxtnPulse_PCM")

function PxtnPulse_PCM:ctor(ch, sps, bps, sample_num)
	self:initialize(ch, sps, bps, sample_num)
end


function PxtnPulse_PCM:initialize(ch, sps, bps, sample_num)
	self.m_data = nil
	self.m_ch = ch or 0
	self.m_sps = sps or 0
	self.m_bps = bps or 0
	self.m_smp_head = 0
	self.m_smp_body = sample_num or 0
	self.m_smp_tail = 0
	if self.m_bps ~= 8 and self.m_bps ~= 16 then
		return CONST.ERR.ERR_pcm_unknown
	end
	return CONST.ERR.OK
end


function PxtnPulse_PCM:write(desc)
	if self.m_data == nil then return false end
	
	local	res = true
	local	riff_size
	local	fact_size
	local	sample_size = (self.m_smp_head + self.m_smp_body + self.m_smp_tail) * self.m_ch * self.m_bps / 8
	
	local	tag_RIFF = "RIFF"
	local	tag_WAVE = "WAVE"
	local	tag_fmt_ = "fmt " .. string.char(0x12, 0, 0, 0)
	local	tag_fact = "fact" .. string.char(0x04, 0, 0, 0)
	local	tag_data = "data"
	
	fact_size = self.m_smp_head + self.m_smp_body + self.m_smp_tail
	riff_size = sample_size + 4 + 26 + 12 + 8
	
	if res then res = desc:w_asfile(tag_RIFF) end
	if res then res = desc:w_asfile(riff_size, 4, "integer") end
	if res then res = desc:w_asfile(tag_WAVE) end
	if res then res = desc:w_asfile(tag_fmt_) end
	-- format
	if res then res = desc:w_asfile(0x0001, 2, "integer") end
	if res then res = desc:w_asfile(self.m_ch, 2, "integer") end
	if res then res = desc:w_asfile(self.m_sps, 4, "integer") end
	if res then res = desc:w_asfile(self.m_sps * self.m_bps * self.m_ch / 8, 4, "integer") end
	if res then res = desc:w_asfile(self.m_bps * self.m_ch / 8, 2, "integer") end
	if res then res = desc:w_asfile(self.m_bps, 2, "integer") end
	if res then res = desc:w_asfile(0, 2, "integer") end
	if res then res = desc:w_asfile(tag_fact) end
	if res then res = desc:w_asfile(fact_size, 4, "integer") end
	if res then res = desc:w_asfile(tag_data) end
	if res then res = desc:w_asfile(sample_size, 4, "integer") end
	if res then res = desc:w_asfile(self.m_data) end
	
	return res
end


function PxtnPulse_PCM:get_ch() return self.m_ch end
function PxtnPulse_PCM:get_bps() return self.m_bps end
function PxtnPulse_PCM:get_sps() return self.m_sps end
function PxtnPulse_PCM:get_smp_body() return self.m_smp_body end
function PxtnPulse_PCM:get_smp_head() return self.m_smp_head end
function PxtnPulse_PCM:get_smp_tail() return self.m_smp_tail end
function PxtnPulse_PCM:get_data() return self.m_data end
function PxtnPulse_PCM:set_data(data) self.m_data = data end


return PxtnPulse_PCM

