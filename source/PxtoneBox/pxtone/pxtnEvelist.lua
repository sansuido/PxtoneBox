local	CONST = import(".pxtnConst")
local	SMF_CONST = import("..smf.smfConst")

local	PxtnEvelist = {}
PxtnEvelist = class("PxtnEvelist")

function PxtnEvelist:ctor(...)
	
	self.m_eves = {}
end


function PxtnEvelist:table_Add_i(tbl, clock, unit_no, kind, value)
	local	index = #tbl + 1
	table.insert(tbl, {
		clock   = clock,
		index   = index,
		kind    = kind,
		unit_no = unit_no,
		value   = value
	})
end


function PxtnEvelist:linear_Add_i(clock, unit_no, kind, value)
	self:table_Add_i(self.m_eves, clock, unit_no, kind, value)
end


function PxtnEvelist:x4x_Read_Add(clock, unit_no, kind, value)
	-- prev, nextの処理がよくわからん……
	self:table_Add_i(self.m_eves, clock, unit_no, kind, value)
end


function PxtnEvelist:Kind_IsTail(kind)
	return kind == CONST.EVENTKIND.ON or kind == CONST.EVENTKIND.PORTAMENT
end


function PxtnEvelist:io_Write(desc, rough, callback)
	rough = rough or 1
	local	res = true
	
	local	reletived_size = 0
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
	
	-- 書き込み用に、ソートをしとく
	table.sort(
		self.m_eves,
		function(a, b)
			if a.clock ~= b.clock then return a.clock < b.clock end
			if a.index ~= b.index then return a.index < b.index end
		end
	)
	
	for i, eve in ipairs(self.m_eves) do
		reletived_size = reletived_size + desc:v_chk(eve.clock)
		reletived_size = reletived_size + 1
		reletived_size = reletived_size + 1
		reletived_size = reletived_size + desc:v_chk(eve.value)
		
		check_callback()
	end
	
	if res then res = desc:w_asfile(4 + reletived_size, 4, "integer") end
	if res then res = desc:w_asfile(#self.m_eves,       4, "integer") end
	
	check_callback()
	
	absolute = 0
	for i, eve in ipairs(self.m_eves) do
		
		local	value = eve.value
		local	clock
		
		if self:Kind_IsTail(eve.kind) then value = eve.value / rough end
		
		clock = eve.clock - absolute
		
		if res then res = desc:v_w_asfile(clock / rough) end
		if res then res = desc:w_asfile(eve.unit_no, 1, "integer") end
		if res then res = desc:w_asfile(eve.kind,    1, "integer") end
		if res then res = desc:v_w_asfile(value) end
		if res == false then break
		end
		
		absolute = eve.clock
		
		check_callback()
	end
	
	return res
end

function PxtnEvelist:io_Read(desc, rough)
	
	rough = rough or 1
	
	local	size, eve_num = desc:r({4, 4}, "integer")
	if size == nil then return CONST.ERR.ERR_desc_r end
	
	
	local	absolute = 0
	for e = 1, eve_num do
		local	clock = desc:v_r()
		if clock == nil then return CONST.ERR.ERR_desc_r end
		
		local	unit_no, kind = desc:r({1, 1}, "integer")
		
		if unit_no == nil then return CONST.ERR.ERR_desc_r end
		
		local	value = desc:v_r()
		if value == nil then return CONST.ERR.ERR_desc_r end
		
		absolute = absolute + clock
		clock = absolute * rough
		if self:Kind_IsTail(kind) then value = value * rough end
		
		self:linear_Add_i(clock, unit_no, kind, value)
	end
	
	return CONST.ERR.OK
end


function PxtnEvelist:io_Read_EventNum(desc)
	local	size, eve_num = desc:r({4, 4}, "integer")
	if size == nil then return 0 end
	for e = 1, eve_num do
		if desc:v_r() == nil then return 0 end
		if desc:r(1, "integer") == nil then return 0 end
		if desc:r(1, "integer") == nil then return 0 end
		if desc:v_r() == nil then return 0 end
	end
	return eve_num
end


function PxtnEvelist:io_Unit_Read_x4x_EVENT(desc, bTailAbsolute, bCheckRRR, rough)
	
	rough = rough or 1
	
	local	size, unit_index, event_kind, data_num, rrr, event_num = desc:r({4, 2, 2, 2, 2, 4}, "integer")
	if size == nil then return CONST.ERR.ERR_desc_r end
	
	local	absolute = 0
	for e = 1, event_num do
		local	clock = desc:v_r()
		if clock == nil then return CONST.ERR.ERR_desc_r end
		local	value = desc:v_r()
		if value == nil then return CONST.ERR.ERR_desc_r end
		
		absolute = absolute + clock
		clock = absolute * rough
		if self:Kind_IsTail(event_kind) then value = value * rough end
		
		self:x4x_Read_Add(clock, unit_index, event_kind, value)
		
		if bTailAbsolute and self:Kind_IsTail(event_kind) then
			absolute = absolute + value
		end
	end
	
	return CONST.ERR.OK
end


function PxtnEvelist:io_Read_x4x_EventNum(desc)
	local	size, unit_index, event_kind, data_num, rrr, event_num = desc:r({4, 2, 2, 2, 2, 4}, "integer")
	if size == nil then return CONST.ERR.desc_r end
	if data_num ~= 2 then return CONST.ERR.fmt_unknown end
	
	for e = 1, event_num do
		if desc:v_r() == nil then return pxtnERR_desc_broken end
		if desc:v_r() == nil then return pxtnERR_desc_broken end
	end
	return CONST.ERR.OK, event_num
end


function PxtnEvelist:io_Read_SMF(smf)
	
	self.m_eves = {}
	
	-- クローンして取得
	local	eves = clone(smf:get_eves())
	
	do
		-- MIDIイベント以外を除去
		local	index = 1
		local	max = #eves
		while index <= max do
			if eves[index].tp ~= SMF_CONST.EVENTTYPE.MIDI then
				table.remove(eves, index)
				index = index - 1
				max = max - 1
			end
			index = index + 1
		end
	end
	-- 読込用にソート
	table.sort(
		eves,
		function(a, b)
			if a.ch ~= b.ch then return a.ch < b.ch end
			if a.clock ~= b.clock then return a.clock < b.clock end
			if a.tp ~= b.tp then return a.tp < b.tp end
			if a.kind ~= b.kind then return a.kind < b.kind end
			if a.value ~= b.value then return a.value < b.value end
			if a.number ~= b.number then return a.number < b.number end
		end
	)
	
	local	rough = 1
	local	units = {}
	local	onkeys = {}
	local	unit_no = 0
	local	sound_key = nil
	local	num = 0
	local	max_num = 0
	local	ch = eves[1].ch
	local	voice_num = 0
	local	drums = {}
	local	ccs = {}
	
	for i, eve in ipairs(eves) do
		if eve.ch ~= ch then
			if ch == 9 then
				for key, drum in pairs(drums) do
					for i, item in ipairs(drum) do
						self:linear_Add_i(
							item.clock,
							unit_no,
							item.kind,
							item.value
						)
					end
					
					table.insert(units, {
						unit_no = unit_no,
						ch = ch,
						voice_num = voice_num,
						percussion_key = key
					})
					for i, item in ipairs(ccs) do
						self:linear_Add_i(
							item.clock,
							unit_no,
							item.kind,
							item.value
						)
					end
					unit_no = unit_no + 1
					voice_num = voice_num + 1
				end
			else
				for i = 1, max_num do
					table.insert(units, {
						unit_no = unit_no,
						ch = ch,
						voice_num = voice_num,
						sound_key = sound_key
					})
					
					for i, item in ipairs(ccs) do
						self:linear_Add_i(
							item.clock,
							unit_no,
							item.kind,
							item.value
						)
					end
					unit_no = unit_no + 1
				end
				if max_num > 0 then
					voice_num = voice_num + 1
				end
			end
			
			onkeys = {}
			sound_key = nil
			num = 0
			max_num = 0
			ch = eve.ch
			drums = {}
			ccs = {}
		end
		
		-- valueがゼロのものはオフにみなす
		local	kind = eve.kind
		if eve.kind == SMF_CONST.MIDIKIND.ON then
			if eve.value == 0 then kind = SMF_CONST.MIDIKIND.OFF end
		end
		
		if kind == SMF_CONST.MIDIKIND.OFF then
			-- ★キーを離した
			
			if onkeys[eve.number] then
				-- キーの長さを算出して積み込む
				
				local	onclock = eve.clock - onkeys[eve.number].clock
				
				-- チャンネル10はドラムの為、特殊に処理
				local	tbl
				if ch == 9 then
					drums[eve.number] = drums[eve.number] or {}
					tbl = drums[eve.number]
				else
					tbl = self.m_eves
				end
				
				self:table_Add_i(tbl, onkeys[eve.number].clock * rough, onkeys[eve.number].unit_no, CONST.EVENTKIND.ON, onclock * rough)
				
				onkeys[eve.number] = nil
				num = num - 1
			end
			
		elseif kind == SMF_CONST.MIDIKIND.ON then
			-- ★キーを押した
			
			if onkeys[eve.number] == nil then
				-- なかった場合はキーが発生
				
				-- チャンネル10はドラムの為、特殊に処理
				local	tbl
				local	key
				if ch == 9 then
					drums[eve.number] = drums[eve.number] or {}
					tbl = drums[eve.number]
					-- キーを真ん中のラに変えてみた（仮）
					key = 96 * 256
				else
					tbl = self.m_eves
					key = (eve.number + 39) * 256
				end
				
				self:table_Add_i(tbl, eve.clock * rough, unit_no + num, CONST.EVENTKIND.VELOCITY, eve.value)
				self:table_Add_i(tbl, eve.clock * rough, unit_no + num, CONST.EVENTKIND.KEY, key)
				
				onkeys[eve.number] = {
					clock = eve.clock,
					value = eve.value,
					unit_no = unit_no + num
				}
				num = num + 1
				max_num = math.max(max_num, num)
			else
				-- あった場合はボリュームだけ変更？めんどいのでとりあえず放置
			end
		elseif kind == SMF_CONST.MIDIKIND.PC then
			-- 初回のみ拾う
			if  sound_key == nil then
				sound_key = eve.number
			end
		elseif kind == SMF_CONST.MIDIKIND.CC then
			-- プログラムチェンジ
			if eve.number == 10 then
				-- パンボリューム
				self:table_Add_i(ccs, eve.clock * rough, unit_no, CONST.EVENTKIND.PAN_VOLUME, eve.value)
			end
		end
	end
	
	if ch == 9 then
		for key, drum in pairs(drums) do
			for i, item in ipairs(drum) do
				self:linear_Add_i(
					item.clock,
					unit_no,
					item.kind,
					item.value
				)
			end
			table.insert(units, {
				unit_no = unit_no,
				ch = ch,
				voice_num = voice_num,
				percussion_key = key
			})
			
			for i, item in ipairs(ccs) do
				self:linear_Add_i(
					item.clock,
					unit_no,
					item.kind,
					item.value
				)
			end
			unit_no = unit_no + 1
			voice_num = voice_num + 1
		end
	else
		for i = 1, max_num do
			table.insert(units, {
				unit_no = unit_no,
				ch = ch,
				voice_num = voice_num,
				sound_key = sound_key
			})
			
			
			for i, item in ipairs(ccs) do
				self:linear_Add_i(
					item.clock,
					unit_no,
					item.kind,
					item.value
				)
			end
			unit_no = unit_no + 1
		end
		voice_num = voice_num + 1
	end
	
	return units
end


return PxtnEvelist
