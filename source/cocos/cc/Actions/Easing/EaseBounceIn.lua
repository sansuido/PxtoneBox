
local	EaseBounce = import(".EaseBounce")

local	EaseBounceIn = {}
EaseBounceIn = class("cc.EaseBounce", EaseBounce)


function EaseBounceIn:update(dt)
	local	value = 1 - self:bounceTime(1 - dt)
	self.cc.inner:update(value)
end


return EaseBounceIn
