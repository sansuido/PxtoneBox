
local	kconv = import(".lib.kconv")
local	Path = import(".lib.path")

local	MainLayer = {}
MainLayer = class("MainLayer", cc.Layer)
function MainLayer:ctor(...)
	cc.Layer.ctor(self, ...)
	
	self:scheduleUpdate()
	
	self.m_file_count = 0
	self.m_read_byte = 0
	self.m_write_byte = 0
	self.m_error_message = ""
	
	self.m_stockfilenames = {}
	
	self.m_channel_no = 0
	self.m_channels = {}
	self.m_logs = {}
	
	-- 背景
	do
		local	backGround = cc.Sprite:create()
		backGround:setTexture("PxtoneBox/res/pxtonebox character.png")
		backGround:setTextureRect(cc.rect(0, 112, 320, 128))
		backGround:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5)
		self:addChild(backGround)
	end
	
	-- ファイルカウント
	do
		local	text = ccui.TextAtlas:create()
		text:setProperty("", "PxtoneBox/res/pxtonebox character.png", 32, 32)
		text:addCharacter("0123456789-.files", cc.p(0, 48))
		text:setPosition(cc.p(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5))
		text:setName("file_count")
		self:addChild(text)
	end
	-- バイト
	do
		local	text = ccui.TextAtlas:create()
		text:setProperty("", "PxtoneBox/res/pxtonebox character.png", 16, 16)
		text:addCharacter("0123456789-./ files", cc.p(0, 16))
		text:addCharacter("abcdefghijklmnopqrstuvwxyz", cc.p(0, 256))
		text:setPosition(cc.p(self:getContentSize().width - 8, 8))
		text:setAnchorPoint(cc.p(1, 0))
		text:setName("byte")
		self:addChild(text)
	end
	-- エラーメッセージ
	do
		local	text = ccui.TextAtlas:create()
		text:setProperty("", "PxtoneBox/res/pxtonebox character.png", 16, 16)
		text:addCharacter("0123456789-.  not enough memory.", cc.p(0, 32))
		text:addCharacter("abcdefghijklmnopqrstuvwxyz", cc.p(0, 272))
		text:setPosition(cc.p(self:getContentSize().width * 0.5, self:getContentSize().height / 2 * 0.5 + 4))
		text:setName("error_message")
		
		self:addChild(text)
	end
end


function MainLayer:onEnter()
	-- 描画する
	self:drawFileCount()
	self:drawByte()
end


function MainLayer:setErrorMessage(error_message)
	local	label = self:getChildByName("error_message")
	self.m_error_message = string.lower(error_message)
	if label then
		label:setStringValue(self.m_error_message)
	end
end

function MainLayer:drawFileCount()
	local	label = self:getChildByName("file_count")
	if label then
		local	count = #self.m_stockfilenames + self.m_file_count
		if count >= 2 then
			label:setStringValue(string.format("%d files", count))
		else
			label:setStringValue(string.format("%d file", count))
		end
	end
end


function MainLayer:calcFileCount(calc)
	self.m_file_count = self.m_file_count + calc
	self:drawFileCount()
end


function MainLayer:drawByte()
	local	label = self:getChildByName("byte")
	if label then
		label:setStringValue(string.format("%d / %d", self.m_write_byte, self.m_read_byte))
	end
end


function MainLayer:calcWriteByte(write_byte)
	self.m_write_byte = self.m_write_byte + write_byte
	self:drawByte()
end


function MainLayer:calcReadByte(read_byte)
	self.m_read_byte = self.m_read_byte + read_byte
	self:drawByte()
end


function MainLayer:filedropped(file)
	do
		local	filename = kconv.kconvert(file:getFilename(), "utf-8", "sjis")
		local	extension = string.lower(Path:getExtension(filename))
		if extension == "mid" or extension == "ptcop" then
			table.insert(self.m_stockfilenames, filename)
		end
	end
end


function MainLayer:command(command, result)
	
	local	channel = self.m_channels[result.no]
	
	if command == "create" then
		self.m_channels[result.no] = {
			read_file = result.read_file,
			read_byte = 0,
			write_byte = 0,
		}
		self:calcFileCount(1)
		
	elseif command == "read" then
		if channel.write_file == nil then channel.write_file = result.write_file end
		channel.read_byte = channel.read_byte + result.byte
		
		self:calcReadByte(result.byte)
		
	elseif command == "write" then
		
		if channel.write_file == nil then channel.write_file = result.write_file end
		channel.write_byte = channel.write_byte + result.byte
		
		self:calcWriteByte(result.byte)
		
	elseif command == "end" or command == "error" then
		self:calcReadByte(-channel.read_byte)
		self:calcWriteByte(-channel.write_byte)
		self:calcFileCount(-1)
		
		for i, text in ipairs(self.m_logs) do
			text:setPosition(cc.pAdd(text:getPosition(), cc.p(0, -8)))
			text:setOpacity(text:getOpacity() - 64 / 255)
			if i >= 4 then
				text:removeFromParent()
				table.remove(self.m_logs, i)
			end
		end
		
		if command == "end" then
			self:setErrorMessage("")
			do
				local	text = ccui.TextAtlas:create()
				text:setProperty("", "PxtoneBox/res/pxtonebox character.png", 8, 8)
				text:addCharacter("0123456789-./", cc.p(0, 0))
				text:addCharacter("abcdefghijklmnopqrstuvwxyz", cc.p(0, 240))
				text:setPosition(cc.p(8, self:getContentSize().height - 8))
				text:setAnchorPoint(cc.p(0, 1))
				text:setStringValue(string.lower(result.write_file))
				self:addChild(text)
				table.insert(self.m_logs, 1, text)
			end
		elseif command == "error" then
			self:setErrorMessage(result.err)
			do
				local	text = ccui.TextAtlas:create()
				text:setProperty("", "PxtoneBox/res/pxtonebox character.png", 8, 8)
				text:addCharacter("0123456789-./", cc.p(0, 8))
				text:addCharacter("abcdefghijklmnopqrstuvwxyz", cc.p(0, 248))
				text:setPosition(cc.p(8, self:getContentSize().height - 8))
				text:setAnchorPoint(cc.p(0, 1))
				text:setStringValue(string.lower(result.write_file))
				self:addChild(text)
				table.insert(self.m_logs, 1, text)
			end
		end
		
		-- 閉じる
		self.m_channels[result.no] = nil
	end
end

function MainLayer:update(dt)
	-- チャンネルの監視を行う
	do
		local	channel_names = {
			"smf2pxtone:read",
			"smf2pxtone:write",
			"smf2pxtone:end",
			"smf2pxtone:error",
			"pxtone2smf:read",
			"pxtone2smf:write",
			"pxtone2smf:end",
			"pxtone2smf:error",
--			"pxtone2material:read",
--			"pxtone2material:write",
--			"pxtone2material:end",
--			"pxtone2material:error",
		}
		for i, channel_name in ipairs(channel_names) do
			local	ch = love.thread.getChannel(channel_name)
			if ch and ch:getCount() > 0 then
				local	result = ch:pop()
				local	fpos, lpos, command = string.find(channel_name, ".*:(.*)$")
				if command then
					self:command(command, result)
				end
			end
		end
	end
	
	-- スレッドが規定値以下ならスレッドに積み込む
	while #self.m_stockfilenames > 0 and self.m_file_count < 3 do
		local	filename = self.m_stockfilenames[1]
		local	extension = string.lower(Path:getExtension(filename))
		local	result = {
			read_file = filename
		}
		
		table.remove(self.m_stockfilenames, 1)
		
		if extension == "mid" then
			local	thread = love.thread.newThread("/PxtoneBox/thread/smf2pxtone.lua")
			local	start_ch = love.thread.getChannel("smf2pxtone:start")
			thread:start()
			self.m_channel_no = self.m_channel_no + 1
			result.no = self.m_channel_no
			start_ch:push(result)
			self:command("create", result)
		elseif extension == "ptcop" then
			local	thread = love.thread.newThread("/PxtoneBox/thread/pxtone2smf.lua")
			local	start_ch = love.thread.getChannel("pxtone2smf:start")
			thread:start()
			self.m_channel_no = self.m_channel_no + 1
			result.no = self.m_channel_no
			start_ch:push(result)
			self:command("create", result)
		end
		
	end
end

return MainLayer
