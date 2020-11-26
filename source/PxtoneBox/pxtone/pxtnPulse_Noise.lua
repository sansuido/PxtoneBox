local	CONST = import(".pxtnConst")

local	PxtnPulse_Noise = {}

local	g_code = "PTNOISE-"
local	g_ver  = 20120418
local	MAX_NOISEEDITUNITNUM     = 4
local	MAX_NOISEEDITENVELOPENUM = 3

local	NOISEEDITFLAG_XX1       = 0x0001
local	NOISEEDITFLAG_XX2       = 0x0002
local	NOISEEDITFLAG_ENVELOPE  = 0x0004
local	NOISEEDITFLAG_PAN       = 0x0008
local	NOISEEDITFLAG_OSC_MAIN  = 0x0010
local	NOISEEDITFLAG_OSC_FREQ  = 0x0020
local	NOISEEDITFLAG_OSC_VOLU  = 0x0040
local	NOISEEDITFLAG_OSC_PAN   = 0x0080

local	NOISEEDITFLAG_UNCOVERED = 0xffffff83


PxtnPulse_Noise = class("PxtnPulse_Noise")
function PxtnPulse_Noise:ctor(...)
	
	self.m_smp_num_44k = nil
	self.m_unit_num = nil
	self.m_units = {}
end


function PxtnPulse_Noise:writeOscillator(osc, desc)
	local	res = true
	local	b_rev
	
	
	if osc.b_rev then
		b_rev = 1
	else
		b_rev = 0
	end
	
	if res then res = desc:v_w_asfile(osc.tp) end
	if res then res = desc:v_w_asfile(b_rev) end
	if res then res = desc:v_w_asfile(osc.freq * 10) end
	if res then res = desc:v_w_asfile(osc.volume * 10) end
	if res then res = desc:v_w_asfile(osc.offset * 10) end
	
	return res
end


function PxtnPulse_Noise:readOscillator(osc, desc)
	local	tp, b_rev, freq, volume, offset = desc:v_r(5)
	if tp == nil then return CONST.ERR.ERR_desc_r end
	
	osc.tp = tp
	if b_rev > 0 then
		osc.b_rev = true
	else
		osc.b_rev = false
	end
	osc.freq = freq / 10
	osc.volume = volume / 10
	osc.offset = offset / 10
	
	return CONST.ERR.OK
end

function PxtnPulse_Noise:makeFlags(unit)
	local	flags = 0
	flags = bit.bor(flags, NOISEEDITFLAG_ENVELOPE)
	if unit.pan then flags = bit.bor(flags, NOISEEDITFLAG_PAN) end
	if unit.main and unit.main.tp ~= CONST.WAVETYPE.None then flags = bit.bor(flags, NOISEEDITFLAG_OSC_MAIN) end
	if unit.freq and unit.freq.tp ~= CONST.WAVETYPE.None then flags = bit.bor(flags, NOISEEDITFLAG_OSC_FREQ) end
	if unit.volu and unit.volu.tp ~= CONST.WAVETYPE.None then flags = bit.bor(flags, NOISEEDITFLAG_OSC_VOLU) end
	return flags
end


function PxtnPulse_Noise:write(desc)
	local	res = true
	local	start_cur = desc:get_cur()
	local	unit_num
	
	if res then res = desc:w_asfile(g_code) end
	if res then res = desc:w_asfile(g_ver, 4, "integer") end
	if res then res = desc:v_w_asfile(self.m_smp_num_44k) end
	
	unit_num = 0
	for i = 1, self.m_unit_num do
		local	unit = self.m_units[i]
		if unit.bEnable == true then
			unit_num = unit_num + 1
		end
	end
	if res then res = desc:w_asfile(unit_num, 1, "integer") end
	
	for i = 1, self.m_unit_num do
		local	unit = self.m_units[i]
		if unit.bEnable == true then
			local	flags = self:makeFlags(unit)
			if res then res = desc:v_w_asfile(flags) end
			
			do
				if res then res = desc:v_w_asfile(unit.enve_num) end
				for e = 1, unit.enve_num do
					if res then res = desc:v_w_asfile(unit.enves[e].x) end
					if res then res = desc:v_w_asfile(unit.enves[e].y) end
				end
			end
			
			if bit.band(flags, NOISEEDITFLAG_PAN) > 0 then
				if res then res = desc:w_asfile(unit.pan, 1, "integer") end
			end
			
			if bit.band(flags, NOISEEDITFLAG_OSC_MAIN) > 0 then 
				if res then res = self:writeOscillator(unit.main, desc) end
			end
			
			if bit.band(flags, NOISEEDITFLAG_OSC_FREQ) > 0 then
				if res then res = self:writeOscillator(unit.freq, desc) end
			end
			
			if bit.band(flags, NOISEEDITFLAG_OSC_VOLU) > 0 then
				if res then res = self:writeOscillator(unit.volu, desc) end
			end
		end
	end
	
	return res, desc:get_cur() - start_cur
end


function PxtnPulse_Noise:read(desc)
	
	local	err = CONST.ERR.ERR_VOID
	local	code, ver = desc:r({8, 4}, {"string", "integer"})
	if code == nil then return CONST.ERR.ERR_desc_r end
	if code ~= g_code then return CONST.ERR.ERR_inv_code end
	if ver > g_ver then return CONST.ERR.ERR_fmt_new end
	self.m_smp_num_44k = desc:v_r()
	if self.m_smp_num_44k == nil then return CONST.ERR.ERR_desc_r end
	self.m_unit_num = desc:r(1, "integer")
	if self.m_unit_num == nil then return CONST.ERR.ERR_desc_r end
	if self.m_unit_num < 0 then return CONST.ERR.ERR_inv_data end
	if self.m_unit_num > MAX_NOISEEDITUNITNUM then return CONST.ERR.ERR_fmt_unknown end
	
	for i = 1, self.m_unit_num do
		self.m_units[i] = {}
		local	unit = self.m_units[i]
		
		unit.bEnable = true
		
		local	flags = desc:v_r()
		if flags == nil then return CONST.ERR.ERR_desc_r end
		
		if bit.band(flags, NOISEEDITFLAG_UNCOVERED) > 0 then return CONST.ERR.ERR_fmt_unknown end
		
		-- envelope
		if bit.band(flags, NOISEEDITFLAG_ENVELOPE) > 0 then
			unit.enves = {}
			unit.enve_num = desc:v_r()
			if unit.enve_num == nil then return CONST.ERR.ERR_desc_r end
			if unit.enve_num > MAX_NOISEEDITENVELOPENUM then return CONST.ERR.ERR_fmt_unknown end
			for e = 1, unit.enve_num do
				unit.enves[e] = {}
				unit.enves[e].x, unit.enves[e].y = desc:v_r(2)
				if unit.enves[e].x == nil then return CONST.ERR.ERR_desc_r end
			end
		end
		
		-- pan
		if bit.band(flags, NOISEEDITFLAG_PAN) > 0 then
			unit.pan = desc:r(1, "integer")
		end
		if bit.band(flags, NOISEEDITFLAG_OSC_MAIN) > 0 then 
			unit.main = {}
			err = self:readOscillator(unit.main, desc)
			
			if err ~= CONST.ERR.OK then return err end
		end
		
		if bit.band(flags, NOISEEDITFLAG_OSC_FREQ) > 0 then
			unit.freq = {}
			err = self:readOscillator(unit.freq, desc)
			if err ~= CONST.ERR.OK then return err end
		end
		
		if bit.band(flags, NOISEEDITFLAG_OSC_VOLU) > 0 then
			unit.volu = {}
			err = self:readOscillator(unit.volu, desc)
			if err ~= CONST.ERR.OK then return err end
		end
	end
	
	return CONST.ERR.OK
end


return PxtnPulse_Noise

