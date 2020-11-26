local	ActionEase = import(".ActionEase")

local	EaseSineInOut = {}
EaseSineInOut = class("cc.EaseSineInOut", ActionEase)

function EaseSineInOut:update(dt)
	local	value = dt
	if dt ~= 0 and dt ~= 1 then
		value = -0.5 * (math.cos(math.pi * dt) - 1)
	end
	self.cc.inner:update(value)
end


return EaseSineInOut
