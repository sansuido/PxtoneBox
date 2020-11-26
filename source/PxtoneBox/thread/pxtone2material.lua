
require("cocos.init")

local	CONST = require("PxtoneBox.pxtone.pxtnConst")
local	PxtnDescriptor = require("PxtoneBox.pxtone.pxtnDescriptor")
local	PxtnService = require("PxtoneBox.pxtone.pxtnService")
local	Path = require("PxtoneBox.lib.path")

local	pxtnDesc = PxtnDescriptor:create()
local	pxtn = PxtnService:create()

local	start_ch = love.thread.getChannel("pxtone2material:start")
local	read_file = start_ch:demand()

pxtnDesc:set_file_r(read_file)

pxtn:read(pxtnDesc)

local	path = Path:removeFileSpec(read_file) .. Path:addBackslash(Path:removeExtension(Path:stripPath(read_file)))
if Path:isDirectory(path) == false then
	Path:createDirectory(path)
end

for i, woice in ipairs(pxtn.m_woices) do
	
	local	desc = PxtnDescriptor:create()
	local	voice = woice.m_voices[1]
	local	name = woice:get_name()
	if #name == 0 then name = tostring(i) end
	
	-- ゼロがあった場合は除去しとく
	local	pos = string.find(name, "%z")
	if pos then name = string.sub(name, 1, pos - 1) end
	-- ファイル名に使用できない文字はリネームしとく
	name = string.gsub(name, "[\\/:*?\"<>|]", "_")
	
	if woice:get_type() == CONST.WOICETYPE.PCM then
		desc:set_file_w(path .. name .. ".wav")
		if voice.pcm:write(desc) == true then
			desc:commit()
		end
	elseif woice:get_type() == CONST.WOICETYPE.PTN then
		desc:set_file_w(path .. name .. ".ptnoise")
		if voice.ptn:write(desc) == true then
			desc:commit()
		end
	elseif woice:get_type() == CONST.WOICETYPE.PTV then
		desc:set_file_w(path .. name .. ".ptvoice")
		if woice:ptv_Write(desc) == true then
			desc:commit()
		end
	elseif woice:get_type() == CONST.WOICETYPE.OGGV then
		desc:set_file_w(path .. name .. ".ogg")
		if voice.oggv:ogg_write(desc) == true then
			desc:commit()
		end
	end
end

local	read_byte = 0
local	pool_byte = 0
local	unit = 1024
do
	local	desc = PxtnDescriptor:create()
	local	read_ch = love.thread.getChannel("pxtone2material:read")
	
	desc:set_file_w(path .. Path:removeExtension(Path:stripPath(read_file)) .. ".ptcop")
	
	local	callback = function(byte)
		read_byte = read_byte + byte
		pool_byte = pool_byte + byte
		if pool_byte >= unit then
			read_ch:push(unit)
			pool_byte = pool_byte - unit
		end
	end
	if pxtn:write(desc, callback) == true then
		read_ch:supply(pool_byte)
		
		local	write_ch = love.thread.getChannel("pxtone2material:write")
		desc:commit(unit,
			function(byte)
				write_ch:push(byte)
			end
		)
		write_ch:supply(0)
	end
end

local	end_ch = love.thread.getChannel("pxtone2material:end")
end_ch:supply(read_byte)

