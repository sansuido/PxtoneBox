local	CONST = import(".smfConst")
local	PXTN_CONST = import("..pxtone.pxtnConst")
local	SmfDescriptor = import(".smfDescriptor")

local	SmfService = {}
SmfService = class("SmfService")


function SmfService:ctor(...)
	
	self.m_format = 0
	self.m_track = 0
	self.m_division = 0
	
	-- めんどくさいので、全部ここに入れ込んじゃう
	self.m_eves = {}
	
	-- 可変テンポだけど、一つを算出して取り出す
	self.m_tempo = 120
	
	self.m_name = ""
end


function SmfService:get_eves()
	return self.m_eves
end


function SmfService:readHeader(desc)
	local	err = CONST.ERR.ERR_VOID
	local	code, size
	code, size, self.m_format, self.m_track, self.m_division = desc:r({4, 4, 2, 2, 2}, {"string", "integer", "integer", "integer", "integer"})
	if code == nil then return CONST.ERR.ERR_desc_r end
	if code ~= "MThd" then return CONST.ERR.ERR_fmt_unknown end
	
	return CONST.ERR.OK
end


function SmfService:addEvent(clock, ch, tp, kind, number, value)
	local	index = 1
	local	eve = self.m_eves[#self.m_eves]
	if eve then index = eve.index + 1 end
	
	table.insert(self.m_eves, {
		clock  = clock,
		index  = index,
		ch     = ch,
		tp     = tp,
		kind   = kind,
		number = number,
		value  = value
	})
end


function SmfService:readTrack(desc)
	local	err = CONST.ERR.ERR_VOID
	local	code, size = desc:r({4, 4}, {"string", "integer"})
	if code == nil then return CONST.ERR.ERR_desc_r end
	if code ~= "MTrk" then return CONST.ERR.ERR_fmt_unknown end
	local	start_cur = desc:get_cur()

	local	cur_size = function()
		return desc:get_cur() - start_cur
	end

	-- テンポ把握
	local	tempo_stack = {}
	
	local	absolute = 0
	while true do

		local	clock = desc:v_r()
		if clock == nil then break end
		clock = math.floor(clock / self.m_division * 480)

		local	head = desc:r(1, "integer")
		if head == nil then return CONST.ERR.ERR_desc_r end
		
		absolute = absolute + clock
		
		if head < 0xf0 then
			-- ■MIDIイベント
			local	tp = CONST.EVENTTYPE.MIDI
			local	number = desc:v_r(1)
			if number == nil then return CONST.ERR.ERR_desc_r end
			
			local	kind = bit.band(head, 0xf0)
			local	ch = bit.band(head, 0x0f)
			
			if kind == 0x80 then
				-- ノート　オフ
				local	value = desc:v_r(1)
				if value == nil then return CONST.ERR.ERR_desc_r end
				self:addEvent(absolute, ch, tp, kind, number, value)
				
			elseif kind == 0x90 then
				-- ノート　オン
				local	value = desc:v_r(1)
				if value == nil then return CONST.ERR.ERR_desc_r end
				self:addEvent(absolute, ch, tp, kind, number, value)
				
			elseif kind == 0xa0 then
				-- ポリフォニックキープレッシャー
				local	value = desc:v_r(1)
				if value == nil then return CONST.ERR.ERR_desc_r end
				self:addEvent(absolute, ch, tp, kind, number, value)
				
			elseif kind == 0xb0 then
				-- コントロール・チェンジ
				local	value = desc:v_r(1)
				if value == nil then return CONST.ERR.ERR_desc_r end
				
				self:addEvent(absolute, ch, tp, kind, number, value)
				
			elseif kind == 0xc0 then
				-- プログラムチェンジ
				self:addEvent(absolute, ch, tp, kind, number)
				
			elseif kind == 0xd0 then
				-- チャンネルプレッシャー
				self:addEvent(absolute, ch, tp, kind, number)
				
			elseif kind == 0xe0 then
				-- ピッチホイールチェンジ
				local	value = desc:v_r()
				if value == nil then return CONST.ERR.ERR_desc_r end
				self:addEvent(absolute, ch, tp, kind, number, value)
			else
				-- 不明
				return CONST.ERR.ERR_desc_r
			end
			
			
		elseif head <= 0xf7 then
			-- ■SysExイベント
			local	tp = CONST.EVENTTYPE.SYSEX
			
			local	sz = desc:r(1, "integer")
			if sz == nil then return CONST.ERR.ERR_desc_r end
			local	value = desc:r(sz)
			
			self:addEvent(absolute, 0, tp, head, 0, value)
		else
			-- ■メタイベント
			local	tp = CONST.EVENTTYPE.META
			
			local	kind, sz = desc:r({1, 1}, "integer")
			if kind == nil then return CONST.ERR.ERR_desc_r end
			local	value = nil
			if sz > 0 then
				value = desc:r(sz)
				if value == nil then return CONST.ERR.ERR_desc_r end
			end
			

			self:addEvent(absolute, 0, tp, kind, 0, value)
			
			if kind == 0x00 then
				-- シーケンス番号
--				print("シーケンス番号", absolute, value)
				
			elseif kind == 0x01 then
				-- コメントなどのテキスト
--				print("コメントなどのテキスト", absolute, value)
			
			elseif kind == 0x02 then
				-- 著作権表示
--				print("著作権", absolute, value)
				
			elseif kind == 0x03 then
				-- シーケンス名・トラック名
--				print("トラック", absolute, value)
				self.m_name = value
				
			elseif kind == 0x04 then
				-- 楽器名
--				print("楽器名", absolute, value)
				
			elseif kind == 0x05 then
				-- 歌詞
--				print("歌詞", absolute, value)
				
			elseif kind == 0x06 then
--				print("マーカー", absolute, value)
			elseif kind == 0x07 then
--				print("キューポイント", absolute, value)
			elseif kind == 0x08 then
--				print("プログラム名", absolute, value)
			elseif kind == 0x09 then
--				print("デバイス名", absolue, value)
			elseif kind == 0x51 then
				-- セットテンポ（3byte）
--				print("セットテンポ", absolute, math.floor(60000000 / desc:string_to_integer(value)))
				
				if #tempo_stack >= 1 then
					local	tempo = tempo_stack[#tempo_stack]
					tempo.lclock = absolute
					tempo.clock = tempo.lclock - tempo.fclock
				end
				table.insert(tempo_stack,
					{
						tempo  = math.floor(60000000 / desc:string_to_integer(value)),
						fclock = absolute
					}
				)
				
			elseif kind == 0x58 then
				-- 拍子（4byte）
--				local	nums = {}
--				for i = 1, sz do
--					table.insert(nums, string.byte(string.sub(value, i, i)))
--				end
--				print("拍子", absolute, unpack(nums))
				
			elseif kind == 0x59 then
				-- キー（調）を表す（2byte）
--				local	nums = {}
--				for i = 1, sz do
--					table.insert(nums, string.byte(string.sub(value, i, i)))
--				end
--				print("キー", absolute, unpack(nums))
				
			elseif kind == 0x2f then
--				print("おわり")
				-- トラックチャンクの終わりを示す（0byte）
				if #tempo_stack >= 1 then
					local	tempo = tempo_stack[#tempo_stack]
					tempo.lclock = absolute
					tempo.clock = tempo.lclock - tempo.fclock
				end
				break
			else
			end
		end
	end
	
	-- 最長テンポの算出処理（超強引＞＜）
	do
		local	tempo_list = {}
		local	max_value = nil
		for i, tempo in ipairs(tempo_stack) do
			tempo_list[tempo.tempo] = tempo_list[tempo.tempo] or 0 + tempo.clock
		end
		table.walk(tempo_list,
			function(value, tempo)
				if max_value == nil or value > max_value then
					self.m_tempo = tempo
					max_value = value
				end
			end
		)
	end
	return CONST.ERR.OK
end


function SmfService:writeTrack(desc, callback)
	local	res = true
	local	size_cur, end_cur
	local	size = 0
	local	absolute = 0
	
	local	check_size = desc:get_size()
	local	check_callback = function()
		if res then
			if type(callback) == "function" then
				callback(desc:get_size() - check_size)
			end
			check_size = desc:get_size()
		end
	end
	
	
	if res then res = desc:w_asfile("MTrk") end
	size_cur = desc:get_cur()
	if res then res = desc:w_asfile(size, 4, "integer") end
	
	check_callback()
	
	local	eves = clone(self.m_eves)
	table.sort(
		eves,
		function(a, b)
			if a.clock ~= b.clock then return a.clock < b.clock end
			if a.index ~= b.index then return a.index < b.index end
		end
	)
	
	absolute = 0
	for i, eve in ipairs(eves) do
		local	clock = eve.clock - absolute
		
		if eve.tp == CONST.EVENTTYPE.MIDI then
			-- ■MIDIイベント
			if res then res = desc:v_w_asfile(clock) end
			if res then res = desc:w_asfile(eve.kind + eve.ch, 1, "integer") end
			if res then res = desc:v_w_asfile(eve.number) end
			if eve.kind ~= 0xc0 then
				if res then res = desc:v_w_asfile(eve.value) end
			end
		elseif eve.tp == CONST.EVENTTYPE.SYSEX then
			-- ■SysEXイベント
			if res then res = desc:v_w_asfile(clock) end
			if res then res = desc:w_asfile(eve.kind, 1, "integer") end
			if res then res = desc:w_asfile(#eve.value, 1, "integer") end
			if res then res = desc:w_asfile(eve.value) end
			
			
		elseif eve.tp == CONST.EVENTTYPE.META then
			-- ■METAイベント
			if res then res = desc:v_w_asfile(clock) end
			if res then res = desc:w_asfile(0xff, 1, "integer") end
			if res then res = desc:w_asfile(eve.kind, 1, "integer") end
			if eve.value then
				if res then res = desc:w_asfile(#eve.value, 1, "integer") end
				if res then res = desc:w_asfile(eve.value) end
			else
				if res then res = desc:w_asfile(0, 1, "integer") end
			end
		end
		absolute = eve.clock
		
		check_callback()
	end
	
	end_cur = desc:get_cur()
	size = end_cur - size_cur - 4
	desc:seek(CONST.SEEK.SET, size_cur)
	if res then res = desc:w_asfile(size, 4, "integer") end
	desc:seek(CONST.SEEK.SET, end_cur)
	
	return res
end


function SmfService:read(desc)
	local	err
	
	desc:seek(CONST.SEEK.SET, 0)
	err = self:readHeader(desc)
	if err ~= CONST.ERR.OK then return err end
	
	while true do
		if desc:get_cur() >= desc:get_size() then
			break
		end
		err = self:readTrack(desc)
		if err ~= CONST.ERR.OK then return err end
	end
	
	return err
end


function SmfService:write(desc, callback)
	local	res = true
	
	local	check_size = desc:get_size()
	local	check_callback = function()
		if res then
			if type(callback) == "function" then
				callback(desc:get_size() - check_size)
			end
			check_size = desc:get_size()
		end
	end
	
	-- header
	if res then res = desc:w_asfile("MThd") end
	if res then res = desc:w_asfile(  6, 4, "integer") end -- size
	if res then res = desc:w_asfile(  0, 2, "integer") end -- format
	if res then res = desc:w_asfile(  1, 2, "integer") end -- track
	if res then res = desc:w_asfile(480, 2, "integer") end -- division
	
	check_callback()
	
	-- track
	if res then res = self:writeTrack(desc, callback) end
	-- スキップ
	check_size = desc:get_size()
	
	return true
end


function SmfService:pre_count_unit_PXTN(pxtn)
	-- 生成前にイベントとユニットを解析し、unit_noとchannel_noの変換リストを作成
	local	units = {}
	local	voices = {}
	
	-- イベントを周回し、unitsに解析可能なデータをセット
	for i, eve in ipairs(pxtn.m_evels.m_eves) do
		local	unit_no = eve.unit_no + 1
		
		units[unit_no] = units[unit_no] or {}
		
		-- イベントの積み込み
		units[unit_no].eves = units[unit_no].eves or {}
		table.insert(units[unit_no].eves, eve)
		
		-- キーの解析
		if eve.kind == PXTN_CONST.EVENTKIND.KEY then
			local	key = eve.value / 256 - 39
			units[unit_no].keys = units[unit_no].keys or {}
			units[unit_no].keys[key] = units[unit_no].keys[key] or 0
			units[unit_no].keys[key] = units[unit_no].keys[key] + 1
			
		end
		
		-- 長さの解析
		if eve.kind == PXTN_CONST.EVENTKIND.ON then
			units[unit_no].on = units[unit_no].on or 0
			units[unit_no].on = math.max(units[unit_no].on, eve.value)
		end
		
		-- 楽器の解析
		if eve.kind == PXTN_CONST.EVENTKIND.VOICENO then
			-- 初回のボイスを取得
			if units[unit_no].voice_no == nil then
				units[unit_no].voice_no = eve.value + 1
			end
		end
		
		-- パンの解析
		if eve.kind == PXTN_CONST.EVENTKIND.PAN_VOLUME then
			-- 初回のパンを取得
			if units[unit_no].pan_volume == nil then
				units[unit_no].pan_volume = eve.value
			end
		end
	end
	
	-- キーが無いユニットは削除（暫定）
	table.filter(units,
		function(unit, key)
			if unit.keys == nil then
				return false
			end
			return true
		end
	)
	
	-- セットされたユニットを成形
	for unit_no, unit in pairs(units) do
		for key, count in pairs(unit.keys) do
			unit.total_count = unit.total_count or 0
			unit.total_count = unit.total_count + count
			unit.key_count = unit.key_count or 0
			unit.key_count = unit.key_count + 1
			if unit.key_min == nil then unit.key_min = key end
			if unit.key_max == nil then unit.key_max = key end
			unit.key_min = math.min(unit.key_min, key)
			unit.key_max = math.max(unit.key_max, key)
			
			unit.voice_no = unit.voice_no or 1
			unit.pan_volume = unit.pan_volume or 64
		end
		
		-- 名称から、楽器を判定
		local	name = pxtn.m_units[unit_no]:get_name()
		local	fp, lp, value = string.find(name, "^(%d%d%d[%+%-])")
		if value then
			local	mark = string.sub(value, 4, 4)
			local	key = tonumber(string.sub(value, 1, 3))
			
			if mark == "-" then
				unit.sound_key = key - 1
				
			elseif mark == "+" then
				unit.percussion_key = key
				unit.channel_no = 10
			end
		end
		
--		-- パーカッション判定？
--		if unit.keys[57] and unit.key_count <= 1 then
--			-- キーの頻度が一つでラだった場合、パーカッションとみなす（暫定）
--			unit.percussion_key = 0
--			unit.channel_no = 10
--		end
		
		-- パーカッション以外は、ボイスにカウントを積み込む
		if unit.percussion_key == nil then
			local	key = unit.voice_no * 1000 + unit.pan_volume
			voices[key] = voices[key] or {}
			voices[key].voice_no = unit.voice_no
			voices[key].pan_volume = unit.pan_volume
			voices[key].count = voices[key].count or 0
			voices[key].count = voices[key].count + 1
			voices[key].total_count = voices[key].total_count or 0
			voices[key].total_count = voices[key].total_count + unit.total_count
		end
	end
	
	
	-- 頻度の高いユニットを採用（少ないのを16chに固める……）
	do
		local	vvs = table.values(voices)
		table.sort(
			vvs,
			function(a, b)
				if a.total_count ~= b.total_count then return a.total_count > b.total_count end
				if a.count ~= b.count then return a.count > b.count end
			end
		)
		for i, vv in ipairs(vvs) do
			local	key = vv.voice_no * 1000 + vv.pan_volume
			if i <= 14 then
				voices[key].channel_flag = true
			else
				voices[key].channel_no = 16
			end
		end
	end
	
	
	-- ボイスを周回し、チャンネルを割り振る
	local	order_pairs = function(tab)
		local sorted = {}
		for key in pairs(tab) do
			table.insert(sorted,key)
		end
		table.sort(sorted)
		local i = 0
		return function()
		i = i + 1
		if i > #sorted then
			return nil,nil
			else
				local key = sorted[i]
				return key,tab[key]
			end
		end
	end
	
	do
		local	channel_no = 1
		for key, voice in order_pairs(voices) do
			if voice.channel_flag == true then
				voice.channel_no = channel_no
				channel_no = channel_no + 1
				if channel_no == 10 then
					channel_no = 11
				end
			end
		end
	end
	
	-- ユニットにチャンネルを配布
	for unit_no, unit in pairs(units) do
		if unit.percussion_key == nil then
			local	key = unit.voice_no * 1000 + unit.pan_volume
			unit.channel_no = voices[key].channel_no
		end
	end
	return units
end


function SmfService:io_Read_PXTN(pxtn, units)
	-- pxtoneのユニットからノートを生成
	
	local	absolute = 0
	local	channel_soundkey = {}
	local	channel_cc = {}
	
	-- メタイベントに名称を積み込む
	self:addEvent(0, 0, CONST.EVENTTYPE.META, 0x03, 0, pxtn.m_name)
	
	-- メタイベントにテンポを積み込む
	self:addEvent(0, 0, CONST.EVENTTYPE.META, 0x51, 0, SmfDescriptor:integer_to_string(math.floor(60000000 / pxtn.m_master.m_beat_tempo), 3))
	
	for unit_no, unit in pairs(units) do
		if unit.channel_no then
			local	clock = unit.eves[1].clock
			local	velocity = nil
			local	key = 57
			local	value = nil
			
			if channel_soundkey[unit.channel_no] == nil and unit.sound_key then
				-- プログラムチェンジを積んでなかったら、積む
				self:addEvent(0, unit.channel_no - 1, CONST.EVENTTYPE.MIDI, CONST.MIDIKIND.PC, unit.sound_key)
				channel_soundkey[unit.channel_no] = unit.sound_key
			end
			
			for i, eve in ipairs(unit.eves) do
				
				if clock ~= eve.clock then
					-- 積み込み発生
					if key and value and velocity then
						-- ノート　オン
						
						self:addEvent(clock, unit.channel_no - 1, CONST.EVENTTYPE.MIDI, CONST.MIDIKIND.ON, key, velocity)
						self:addEvent(clock + value, unit.channel_no - 1, CONST.EVENTTYPE.MIDI, CONST.MIDIKIND.ON, key, 0)
						
						absolute = math.max(absolute, clock + value)
					end
					clock = eve.clock
					velocity = nil
					value = nil
				end
				
				-- ベロシティ
				if eve.kind == PXTN_CONST.EVENTKIND.VELOCITY then
					velocity = math.min(eve.value, 127)
				end
				
				-- キーの解析
				if eve.kind == PXTN_CONST.EVENTKIND.KEY then
					if unit.percussion_key then
						key = unit.percussion_key
					else
						key = eve.value / 256 - 39
					end
				end
				
				-- 長さの解析
				if eve.kind == PXTN_CONST.EVENTKIND.ON then
					value = eve.value
				end
				
				-- パンボリューム
				if eve.kind == PXTN_CONST.EVENTKIND.PAN_VOLUME then
					channel_cc[unit.channel_no] = channel_cc[unit.channel_no] or {}
					channel_cc[unit.channel_no].pan_volumes = channel_cc[unit.channel_no].pan_volumes or {}
					if channel_cc[unit.channel_no].pan_volumes[clock] == nil then
						
						self:addEvent(clock, unit.channel_no - 1, CONST.EVENTTYPE.MIDI, CONST.MIDIKIND.CC, 10, math.min(eve.value, 127))
						channel_cc[unit.channel_no].pan_volumes[clock] = eve.value
					end
				end
			end
			
			if key and value and velocity then
				-- ノート　オン
				
				self:addEvent(clock, unit.channel_no - 1, CONST.EVENTTYPE.MIDI, CONST.MIDIKIND.ON, key, velocity)
				self:addEvent(clock + value, unit.channel_no - 1, CONST.EVENTTYPE.MIDI, CONST.MIDIKIND.ON, key, 0)
				
				absolute = math.max(absolute, clock + value)
			end
		end
	end
	
	-- トラックチャンクの終わり
	self:addEvent(absolute, 0, CONST.EVENTTYPE.META, 0x2f, 0, "")
end

function SmfService:read_PXTN(pxtn)
	local	units = self:pre_count_unit_PXTN(pxtn)
	self:io_Read_PXTN(pxtn, units)
end

return SmfService
