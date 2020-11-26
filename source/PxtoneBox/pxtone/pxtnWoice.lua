local	CONST = import(".pxtnConst")
local	PxtnPulse_PCM = import(".pxtnPulse_PCM")
local	PxtnPulse_Noise = import(".pxtnPulse_Noise")
local	PxtnPulse_Oggv = import(".pxtnPulse_Oggv")

local	PxtnWoice = {}
PxtnWoice = class("PxtnWoice")

local	g_code = "PTVOICE-"
local	g_ver = 20060111


function PxtnWoice:ctor(...)
	
	self.m_name = ""
	self.m_type = CONST.WOICETYPE.None
	self.m_data = ""
	
	self.m_x3x_basic_key = 0
	self.m_x3x_tuning = 0
	
	self.m_voices = {}
end


function PxtnWoice:voice_Allocate(num)
	-- ボイス積み込み
	
	
	for i = 1, num do
		table.insert(self.m_voices,
			{
				basic_key   = CONST.EVENTDEFAULT.BASICKEY,
				volume      = 128,
				pan         = 64,
				tuning      = 1.0,
				voice_flags = CONST.PTV_VOICEFLAG.SMOOTH,
				data_flags  = CONST.PTV_DATAFLAG_WAVE,
				
				voice_type  = nil,
				pcm         = nil,
				ptn         = nil,
				oggv        = nil,
			}
		)
	end
	
end


function PxtnWoice:set_name(name)
	self.m_name = name
end


function PxtnWoice:get_name()
	return self.m_name
end


function PxtnWoice:get_write_name()
	-- 書き込み時名称を取得（ゼロで埋めとく）
	local	size = #self.m_name
	return self.m_name .. string.rep(string.char(0x00), CONST.MAX_TUNEWOICENAME - size)
end

function PxtnWoice:get_type()
	return self.m_type
end


function PxtnWoice:io_matePCM_w(desc)
	local	res = true
	
	local	voice = self.m_voices[1]
	local	pcm = voice.pcm
	local	size = 2 + 2 + 4 + 2 + 2 + 4 + 4 + 4 + #pcm:get_data()
	
	if res then res = desc:w_asfile(size, 4, "integer") end
	if res then res = desc:w_asfile(0, 2, "integer") end
	if res then res = desc:w_asfile(voice.basic_key, 2, "integer") end
	if res then res = desc:w_asfile(voice.voice_flags, 4, "integer") end
	if res then res = desc:w_asfile(pcm:get_ch(), 2, "integer") end
	if res then res = desc:w_asfile(pcm:get_bps(), 2, "integer") end
	if res then res = desc:w_asfile(pcm:get_sps(), 4, "integer") end
	if res then res = desc:w_asfile(voice.tuning, 4, "float") end
	if res then res = desc:w_asfile(#pcm:get_data(), 4, "integer") end
	if res then res = desc:w_asfile(pcm:get_data(), #pcm:get_data()) end
	
	return res
end


function PxtnWoice:io_matePCM_r(desc)
	local	err = CONST.ERR.ERR_VOID
	local	size, x3x_unit_no, basic_key, voice_flags, ch, bps, sps, tuning, data_size
	
	size, x3x_unit_no, basic_key, voice_flags, ch, bps, sps, tuning, data_size = desc:r({4, 2, 2, 4, 2, 2, 4, 4, 4}, {"integer", "integer", "integer", "integer", "integer", "integer", "integer", "float", "integer"})
	if size == nil then return CONST.ERR.ERR_desc_r end
	local	data = desc:r(data_size)
	if data == nil then return CONST.ERR.ERR_desc_r end
	
	do
		self:voice_Allocate(1)
		local	voice = self.m_voices[1]
		
		self.m_type = CONST.WOICETYPE.PCM
		
		voice.pcm = PxtnPulse_PCM:create()
		err = voice.pcm:initialize(ch, sps, bps, data_size / (bps / 8 * ch))
		if err ~= CONST.ERR.OK then return err end
		voice.pcm:set_data(data)
		
		
		voice.voice_type = CONST.VOICETYPE.Sampling
		voice.voice_flags = voice_flags
		voice.basic_key = basic_key
		voice.tuning = tuning
		
		self.m_x3x_basic_key = basic_key
		self.m_x3x_tuning = 0
	end
	
	return CONST.ERR.OK
end


function PxtnWoice:io_matePTN_w(desc)
	local	res = true
	local	voice = self.m_voices[1]
	local	size = 2 + 2 + 4 + 4 + 4
	local	data_size = 0
	local	size_cur = desc:get_cur()
	local	end_cur
	
	-- 仮サイズを書き込み
	if res then res = desc:w_asfile(size, 4, "integer") end
	if res then res = desc:w_asfile(0, 2, "integer") end
	if res then res = desc:w_asfile(voice.basic_key, 2, "integer") end
	if res then res = desc:w_asfile(voice.voice_flags, 4, "integer") end
	if res then res = desc:w_asfile(voice.tuning, 4, "float") end
	if res then res = desc:w_asfile(1, 4, "integer") end
	if res then res, data_size = voice.ptn:write(desc) end
	
	if res then
		-- サイズを書き直す
		end_cur = desc:get_cur()
		desc:seek(CONST.SEEK.SET, size_cur)
		if res then res = desc:w_asfile(size + data_size, 4, "integer") end
		desc:seek(CONST.SEEK.SET, end_cur)
	end
	
	return res
end

function PxtnWoice:io_matePTN_r(desc)
	local	err = CONST.ERR.ERR_VOID
	local	size, x3x_unit_no, basic_key, voice_flags, tuning, rrr
	size, x3x_unit_no, basic_key, voice_flags, tuning, rrr = desc:r({4, 2, 2, 4, 4, 4}, {"integer", "integer", "integer", "integer", "float", "integer"})
	
	if size == nil then return CONST.ERR.ERR_desc_r end
	local	data_size = size - (2 + 2 + 4 + 4 + 4)
	
	do
		self:voice_Allocate(1)
		local	voice = self.m_voices[1]
		
		self.m_type = CONST.WOICETYPE.PTN
		
		voice.ptn = PxtnPulse_Noise:create()
		err = voice.ptn:read(desc)
		if err ~= CONST.ERR.OK then
			return err
		end
		
		voice.voice_type = CONST.VOICETYPE.Noise
		voice.voice_flags = voice_flags
		voice.basic_key = basic_key
		voice.tuning = tuning
		
		self.m_x3x_basic_key = basic_key
		self.m_tuning = 0
	end
	
	return CONST.ERR.OK
end

function PxtnWoice:io_matePTV_w(desc)
	local	res = true
	local	size = 2 + 2 + 4 + 4
	local	data_size
	local	size_cur, data_size_cur, end_cur
	
	size_cur = desc:get_cur()
	if res then res = desc:w_asfile(size, 4, "integer") end
	if res then res = desc:w_asfile(0, 2, "integer") end
	if res then res = desc:w_asfile(0, 2, "integer") end
	if res then res = desc:w_asfile(0, 4, "float") end
	data_size_cur = desc:get_cur()
	if res then res = desc:w_asfile(0, 4, "integer") end
	if res then res = self:ptv_Write(desc) end
	
	-- 各種サイズを再計算
	end_cur = desc:get_cur()
	data_size = end_cur - data_size_cur - 4
	size = size + data_size
	
	desc:seek(CONST.SEEK.SET, size_cur)
	if res then res = desc:w_asfile(size, 4, "integer") end
	desc:seek(CONST.SEEK.SET, data_size_cur)
	if res then res = desc:w_asfile(data_size, 4, "integer") end
	desc:seek(CONST.SEEK.SET, end_cur)
	
	return res
end


function PxtnWoice:io_matePTV_r(desc)
	local	err = CONST.ERR.ERR_VOID
	local	size, x3x_unit_no, x3x_tuning, sz
	size, x3x_unit_no, x3x_tuning, sz = desc:r({4, 2, 2, 4, 4}, {"integer", "integer", "integer", "float", "integer"})
	
	if size == nil then return CONST.ERR.ERR_desc_r end
	local	data_size = size - (2 + 2 + 4 + 4)
	
	err = self:ptv_Read(desc)
	if err ~= CONST.ERR.OK then return err end
	
	if x3x_tuning ~= 1.0 then
		self.m_x3x_tuning = x3x_tuning
	end
	
	return CONST.ERR.OK
end

function PxtnWoice:io_mateOGGV_w(desc)
	local	res = true
	local	voice = self.m_voices[1]
	local	size = 2 + 2 + 4 + 4 + voice.oggv:getSize()
	
	if res then res = desc:w_asfile(size, 4, "integer") end
	if res then res = desc:w_asfile(0, 2, "integer") end
	if res then res = desc:w_asfile(voice.basic_key, 2, "integer") end
	if res then res = desc:w_asfile(voice.voice_flags, 4, "integer") end
	if res then res = desc:w_asfile(voice.tuning, 4, "float") end
	if res then res = voice.oggv:pxtn_write(desc) end
	
	return res
end

function PxtnWoice:io_mateOGGV_r(desc)
	
	local	err = CONST.ERR.ERR_VOID
	local	size, xxx, basic_key, voice_flags, tuning
	size, xxx, basic_key, voice_flags, tuning = desc:r({4, 2, 2, 4, 4}, {"integer", "integer", "integer", "integer", "float"})
	
	if size == nil then return CONST.ERR.ERR_desc_r end
	local	data_size = size - (2 + 2 + 4 + 4)
	
	do
		self:voice_Allocate(1)
		local	voice = self.m_voices[1]
		
		self.m_type = CONST.WOICETYPE.OGGV
		
		voice.oggv = PxtnPulse_Oggv:create()
		err = voice.oggv:pxtn_read(desc)
		if err ~= CONST.ERR.OK then
			return err
		end
		
		voice.voice_type = CONST.VOICETYPE.OggVorbis
		voice.voice_flags = voice_flags
		voice.basic_key = basic_key
		voice.tuning = tuning
		
		self.m_x3x_basic_key = basic_key
		self.m_tuning = 0
	end
	
	return CONST.ERR.OK
end

function PxtnWoice:ptv_Write_Wave(desc, voice)
	local	res = true
	
	if res then res = desc:v_w_asfile(voice.voice_type) end
	
	if     voice.voice_type == CONST.VOICETYPE.Coodinate then
		
		
		if res then res = desc:v_w_asfile(voice.wave.num) end
		if res then res = desc:v_w_asfile(voice.wave.reso) end
		for i = 1, voice.wave.num do
			
			
			if res then res = desc:w_asfile(voice.wave.points[i].x, 1, "integer") end
			if res then res = desc:w_asfile(voice.wave.points[i].y, 1, "integer") end
		end
		
	elseif voice.voice_type == CONST.VOICETYPE.Overtone then
		
		if res then res = desc:v_w_asfile(voice.wave.num) end
		for i = 1, voice.wave.num do
			if res then res = desc:v_w_asfile(voice.wave.points[i].x) end
			if res then res = desc:v_w_asfile(voice.wave.points[i].y) end
		end
		
	elseif voice.voice_type == CONST.VOICETYPE.Sampling then
		return false
	else
		return false
	end
	
	return true
end

function PxtnWoice:ptv_Write_Envelope(desc, voice)
	local	res = true
	if res then res = desc:v_w_asfile(voice.envelope.fps) end
	if res then res = desc:v_w_asfile(voice.envelope.head_num) end
	if res then res = desc:v_w_asfile(voice.envelope.body_num) end
	if res then res = desc:v_w_asfile(voice.envelope.tail_num) end
	
	local	num = voice.envelope.head_num + voice.envelope.body_num + voice.envelope.tail_num
	for i = 1, num do
		if res then res = desc:v_w_asfile(voice.envelope.points[i].x) end
		if res then res = desc:v_w_asfile(voice.envelope.points[i].y) end
	end
	
	return res
end


function PxtnWoice:ptv_Write(desc)
	local	res = true
	local	start_cur, end_cur, size
	
	
	if res then res = desc:w_asfile(g_code) end
	if res then res = desc:w_asfile(g_ver, 4, "integer") end
	if res then res = desc:w_asfile(0, 4, "integer") end
	
	
	start_cur = desc:get_cur()
	
	if res then res = desc:v_w_asfile(0) end
	
	if res then res = desc:v_w_asfile(0) end
	
	if res then res = desc:v_w_asfile(0) end
	
	if res then res = desc:v_w_asfile(#self.m_voices) end
	
	
	for i, voice in ipairs(self.m_voices) do
		
	
		if res then res = desc:v_w_asfile(voice.basic_key) end
		if res then res = desc:v_w_asfile(voice.volume) end
		if res then res = desc:v_w_asfile(voice.pan) end
		if res then res = desc:v_w_asfile(desc:float_to_integer(voice.tuning)) end
		if res then res = desc:v_w_asfile(voice.voice_flags) end
		if res then res = desc:v_w_asfile(voice.data_flags) end
		
		if bit.band(voice.data_flags, CONST.PTV_DATAFLAG.WAVE    ) > 0 then
			
			
			if res then res = self:ptv_Write_Wave(desc, voice) end
		end
		
		if bit.band(voice.data_flags, CONST.PTV_DATAFLAG.ENVELOPE) > 0 then
			
			
			if res then res = self:ptv_Write_Envelope(desc, voice) end
		end
		
	end
	
	end_cur = desc:get_cur()
	size = end_cur - start_cur
	desc:seek(CONST.SEEK.SET, start_cur - 4)
	desc:w_asfile(size, 4, "integer")
	desc:seek(CONST.SEEK.SET, end_cur)
	
	return res
end


function PxtnWoice:ptv_Read_Wave(desc, voice)
	
	voice.voice_type = desc:v_r()
	if voice.voice_type == nil then return CONST.ERR.ERR_desc_r end
	
	if     voice.voice_type == CONST.VOICETYPE.Coodinate then
		
		voice.wave = {}
		voice.wave.points = {}
		voice.wave.num, voice.wave.reso = desc:v_r(2)
		if voice.wave.num == nil then return CONST.ERR.ERR_desc_r end
		for i = 1, voice.wave.num do
			voice.wave.points[i] = {}
			voice.wave.points[i].x, voice.wave.points[i].y = desc:r({1, 1}, {"integer", "integer"})
			if voice.wave.points[i].x == nil then return CONST.ERR.ERR_desc_r end
			
		end
		
		
	elseif voice.voice_type == CONST.VOICETYPE.Overtone then
		
		voice.wave = {}
		voice.wave.points = {}
		voice.wave.num = desc:v_r()
		if voice.wave.num == nil then return CONST.ERR.ERR_desc_r end
		for i = 1, voice.wave.num do
			voice.wave.points[i] = {}
			voice.wave.points[i].x, voice.wave.points[i].y = desc:v_r(2)
			if voice.wave.points[i].x == nil then return CONST.ERR.ERR_desc_r end
		end
		
	elseif voice.voice_type == CONST.VOICETYPE.Sampling then
		
		return CONST.ERR.ERR_fmt_unknown
	else
		
		return CONST.ERR.ERR_ptv_no_supported
	end
	
	return CONST.ERR.OK
end


function PxtnWoice:ptv_Read_Envelope(desc, voice)
	voice.envelope = {}
	voice.envelope.points = {}
	voice.envelope.fps, voice.envelope.head_num, voice.envelope.body_num, voice.envelope.tail_num = desc:v_r(4)
	if voice.envelope.fps == nil then return CONST.ERR.ERR_desc_r end
	local	num = voice.envelope.head_num + voice.envelope.body_num + voice.envelope.tail_num
	for i = 1, num do
		voice.envelope.points[i] = {}
		voice.envelope.points[i].x, voice.envelope.points[i].y = desc:v_r(2)
		if voice.envelope.points[i].x == nil then return CONST.ERR.ERR_desc_r end
	end
	return CONST.ERR.OK
end


function PxtnWoice:ptv_Read(desc)
	local	err = CONST.ERR.ERR_VOID
	
	local	code, ver, total = desc:r({8, 4, 4}, {"string", "integer", "integer"})
	
	if code == nil then return CONST.ERR.ERR_desc_r end
	if code ~= g_code then return CONST.ERR.ERR_inv_code end
	if ver > g_ver then return CONST.ERR.ERR_fmt_new end
	
	local	work1, work2, num
	self.m_x3x_basic_key, work1, work2, num = desc:v_r(4)
	
	if self.m_x3x_basic_key == nil then return CONST.ERR.ERR_desc_r end
	if work1 ~= 0 or work2 ~= 0 then return CONST.ERR.ERR_fmt_unknown end
	
	self:voice_Allocate(num)
	for i = 1, num do
		
		local	voice = self.m_voices[i]
		voice.basic_key, voice.volume, voice.pan, work1, voice.voice_flags, voice.data_flags = desc:v_r(6)
		if voice.basic_key == nil then return CONST.ERR.ERR_desc_r end
		voice.tuning = desc:integer_to_float(work1)
		
		
		if bit.band(voice.voice_flags, CONST.PTV_VOICEFLAG.UNCOVERED) > 0 then return CONST.ERR.ERR_fmt_unknown end
		if bit.band(voice.data_flags, CONST.PTV_DATAFLAG.UNCOVERED) > 0 then return CONST.ERR.ERR_fmt_unknown end
		if bit.band(voice.data_flags, CONST.PTV_DATAFLAG.WAVE     ) > 0 then
			
			
			err = self:ptv_Read_Wave(desc, voice)
			if err ~= CONST.ERR.OK then return err end
		end
		if bit.band(voice.data_flags, CONST.PTV_DATAFLAG.ENVELOPE ) > 0 then
			
			
			err = self:ptv_Read_Envelope(desc, voice)
			if err ~= CONST.ERR.OK then return err end
		end
		
	end
	
	
	self.m_type = CONST.WOICETYPE.PTV
	
	return CONST.ERR.OK
end


return PxtnWoice
