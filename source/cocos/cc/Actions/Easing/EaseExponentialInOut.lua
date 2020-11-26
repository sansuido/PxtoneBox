local	ActionEase = import(".ActionEase")

local	EaseExponentialInOut = {}
EaseExponentialInOut = class("cc.EaseExponentialInOut", ActionEase)

function EaseExponentialInOut:update(dt)
	local	value = dt
	if dt ~= 0 and dt ~= 1 then
		dt = dt * 2
		if dt < 1 then
			value = 0.5 * math.pow(2, 10 * (dt - 1))
		else
			value = 0.5 * (-math.pow(2, -10 * (dt - 1)) + 2)
		end
	end
	self.cc.inner:update(value)
end


return EaseExponentialInOut
