local	CONST = import(".pxtnConst")

local	PxtnMaster = {}
PxtnMaster = class("PxtnMaster")

function PxtnMaster:ctor(...)
	
	self:reset()
end


function PxtnMaster:reset()
	self.m_beat_num   = CONST.EVENTDEFAULT.BEATNUM
	self.m_beat_tempo = CONST.EVENTDEFAULT.BEATTEMPO
	self.m_beat_clock = CONST.EVENTDEFAULT.BEATCLOCK
	self.m_meas_num = 1
	self.m_repeat_meas = 0
	self.m_last_meas = 0
end


function PxtnMaster:set(beat_num, beat_tempo, beat_clock)
	self.m_beat_num   = beat_num
	self.m_beat_tempo = beat_tempo
	self.m_beat_clock = beat_clock
end


function PxtnMaster:get()
	return self.m_beat_num, self.m_beat_tempo, self.m_beat_clock, self.m_meas_num
end


function PxtnMaster:get_beat_num()    return self.m_beat_num end
function PxtnMaster:get_beat_tempo()  return self.m_beat_tempo end
function PxtnMaster:get_beat_clock()  return self.m_beat_clock end
function PxtnMaster:get_meas_num()    return self.m_meas_num end
function PxtnMaster:get_repeat_meas() return self.m_repeat_meas end
function PxtnMaster:get_last_meas()   return self.m_last_meas end
function PxtnMaster:get_last_clock()  return self.m_last_meas * self.m_beat_clock * self.m_beat_num end
function PxtnMaster:get_play_meas()   if self.m_last_meas ~= 0 then return self.m_last_meas end return self.m_meas_num end
function PxtnMaster:get_this_clock(meas, beat, clock) return self.m_beat_num * self.m_beat_clock * meas + self.m_beat_clock * beat + clock end


function PxtnMaster:adjustMeasNum(clock)
	local	beat_num = (clock + self.m_beat_clock - 1)  / self.m_beat_clock
	local	meas_num = (beat_num + self.m_beat_num - 1) / self.m_beat_num
	if self.m_meas_num <= meas_num then self.m_meas_num = meas_num end
	if self.m_repeat_meas >= self.m_meas_num then self.m_repeat_meas = 0 end
	if self.m_last_meas >= self.m_meas_num then self.m_last_meas = self.m_meas_num end
end


function PxtnMaster:set_meas_num(meas_num)
	if meas_num < 1                    then meas_num = 1 end
	if meas_num <= self.m_repeat_meas  then meas_num = self.m_repeat_meas + 1 end
	if meas_num < self.m_last_meas     then meas_num = self.m_last_meas end
	self.m_meas_num = meas_num
end


function PxtnMaster:io_w_v5(desc, rough)
	rough = rough or 1
	local	res = true
	local	size = 15
	
	local	bclock = self.m_beat_clock / rough
	local	clock_repeat = bclock * self.m_beat_num * self:get_repeat_meas()
	local	clock_last = bclock * self.m_beat_num * self:get_last_meas()
	local	bnum = self.m_beat_num
	local	btempo = self.m_beat_tempo
	
	if res then res = desc:w_asfile(size,         4, "integer") end
	if res then res = desc:w_asfile(bclock,       2, "integer") end
	if res then res = desc:w_asfile(bnum,         1, "integer") end
	if res then res = desc:w_asfile(btempo,       4, "float") end
	if res then res = desc:w_asfile(clock_repeat, 4, "integer") end
	if res then res = desc:w_asfile(clock_last,   4, "integer") end
	return res
end


function PxtnMaster:set_repeat_meas(meas) meas = math.max(meas, 0) self.m_repeat_meas = meas end
function PxtnMaster:set_last_meas(meas) meas = math.max(meas, 0) self.m_last_meas = meas end
function PxtnMaster:set_beat_clock(beat_clock) beat_clock = math.max(beat_clock, 0) self.m_beat_clock = beat_clock end

function PxtnMaster:io_r_v5(desc, rough)
	
	rough = rough or 1
	
	local	err = CONST.ERR.ERR_VOID
	local	size = desc:r(4, "integer")
	if size == nil then return CONST.ERR.ERR_desc_r end
	if size ~= 15 then return CONST.ERR.ERR_fmt_unknown end
	
	local	beat_clock, beat_num, beat_tempo, clock_repeat, clock_last = desc:r({2, 1, 4, 4, 4}, {"integer", "integer", "float", "integer", "integer"})
	
	self.m_beat_num   = beat_num
	self.m_beat_tempo = beat_tempo
	self.m_beat_clock = beat_clock * rough
	
	self:set_repeat_meas(clock_repeat / (beat_num * beat_clock))
	self:set_last_meas(clock_last / (beat_num * beat_clock))
	
	return CONST.ERR.OK
end


function PxtnMaster:io_r_v5_EventNum(desc)
	local	size = desc:r(4, "integer")
	if size == nil or size ~= 15 then return 0 end
	if desc:r(15) == nil then return 0 end
	return 5
end


function PxtnMaster:io_r_x4x(desc, rough)
	
	rough = rough or 1
	
	local	size, data_num, rrr, event_num = desc:r({4, 2, 2, 4}, "integer")
	
	local	beat_clock = CONST.EVENTDEFAULT.BEATCLOCK
	local	beat_num   = CONST.EVENTDEFAULT.BEATNUM
	local	beat_tempo = CONST.EVENTDEFAULT.BEATTEMPO
	local	repeat_clock = 0
	local	last_clock = 0
	
	if size == nil then return CONST.ERR.ERR_desc_r end
	if data_num ~= 3 then return CONST.ERR.ERR_fmt_unkown end
	if rrr ~= 0 then return CONST.ERR.ERR_fmt_unkown end
	
	local	absolute = 0
	for e = 1, event_num do
		local	status, clock, volume = desc:v_r(3)
		
		absolute = absolute + clock
		clock = absolute
		
		if status == nil then return CONST.ERR.desc_broken end
		
		if     status == CONST.EVENTKIND.BEATCLOCK then
			
			beat_clock = volume
			if clock ~= 0 then return CONST.ERR.desc_broken end
			
		elseif status == CONST.EVENTKIND.BEATTEMPO then
			beat_tempo = desc:integer_to_float(volume)
			if clock ~= 0 then return CONST.ERR.desc_broken end
			
		elseif status == CONST.EVENTKIND.BEATNUM   then
			beat_num = volume
			if clock ~= 0 then return CONST.ERR.desc_broken end
			
		elseif status == CONST.EVENTKIND.REPEAT    then
			
			repeat_clock = clock
			if volume ~= 0 then return CONST.ERR.desc_broken end
			
		elseif status == CONST.EVENTKIND.LAST      then
			
			last_clock = clock
			if volume ~= 0 then return CONST.ERR.desc_broken end
			
		else
			return CONST.ERR.fmt_unkown
		end
	end
	
	self.m_beat_num   = beat_num
	self.m_beat_tempo = beat_tempo
	self.m_beat_clock = beat_clock * rough
	
	self:set_repeat_meas(repeat_clock / (beat_num * beat_clock))
	self:set_last_meas(last_clock / (beat_num * beat_clock))
	
	return CONST.ERR.OK
end


function PxtnMaster:io_r_x4x_EventNum(desc)
	local	size, data_num, rrr, event_num = desc:r({4, 2, 2, 4}, "integer")
	
	if size == nil then return 0 end
	if data_num ~= 3 then return 0 end
	
	for e = 1, event_num do
		if desc:v_r() == nil then return 0 end
		if desc:v_r() == nil then return 0 end
		if desc:v_r() == nil then return 0 end
	end
	return event_num
end


return PxtnMaster
