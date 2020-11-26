local	ActionEase = import(".ActionEase")

local	EaseExponentialOut = {}
EaseExponentialOut = class("cc.EaseExponentialOut", ActionEase)

function EaseExponentialOut:update(dt)
	local	value = 1
	if dt ~= 1 then
		value = -math.pow(2, -10 * dt) + 1
	end
	self.cc.inner:update(value)
end


return EaseExponentialOut
