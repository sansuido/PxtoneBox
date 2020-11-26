
local	EaseBounce = import(".EaseBounce")

local	EaseBounceOut = {}
EaseBounceOut = class("cc.EaseBounce", EaseBounce)


function EaseBounceOut:update(dt)
	local	value = self:bounceTime(dt)
	self.cc.inner:update(value)
end


return EaseBounceOut
