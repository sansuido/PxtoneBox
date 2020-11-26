local	SourceManager = {}

SourceManager = class("cc.SourceManager")

function SourceManager:ctor(...)
	
	self.cc.list = {}
end

function SourceManager:loadSource(
	type,
	...
	)
	local	func = nil
	local	source = nil
	self.cc.list[type] = self.cc.list[type] or {}
	if type == "image" then
		func = love.graphics.newImage
	elseif type == "font" then
		func = love.graphics.newFont
	elseif type == "sound" then
		func = love.sound.newSoundData
	end
	if func then
		local	args = { ... }
		local	key = ""
		
		for i, arg in ipairs(args) do
			if i > 1 then key = key .. ":" end
			key = key .. tostring(arg)
		end
		
		source = self.cc.list[type][key]
		if source == nil then
			source = func(...)
			self.cc.list[type][key] = source
		end
	end
	return source
end



return SourceManager

