local	ActionEase = import(".ActionEase")

local	EaseExponentialIn = {}
EaseExponentialIn = class("cc.EaseExponentialIn", ActionEase)

function EaseExponentialIn:update(dt)
	local	value = 0
	if dt ~= 0 then
		value = math.pow(2, 10 * (dt - 1))
	end
	self.cc.inner:update(value)
end


return EaseExponentialIn
