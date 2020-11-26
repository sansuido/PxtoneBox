
local	EaseBounce = import(".EaseBounce")

local	EaseBounceInOut = {}
EaseBounceInOut = class("cc.EaseBounce", EaseBounce)


function EaseBounceInOut:update(dt)
	local	value = 0
	
	if dt < 0.5 then
		dt = dt * 2
		value = (1 - self:bounceTime(1 - dt)) * 0.5
	else
		value = self:bounceTime(dt * 2 - 1) * 0.5 + 0.5
	end
	self.cc.inner:update(value)
end


return EaseBounceInOut
