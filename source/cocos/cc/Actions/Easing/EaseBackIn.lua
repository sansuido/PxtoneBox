local	ActionEase = import(".ActionEase")

local	EaseBackIn = {}
EaseBackIn = class("cc.EaseBackIn", ActionEase)


function EaseBackIn:update(dt)
	local	overshoot = 1.70158
	local	value = dt
	if dt ~= 0 or dt ~= 1 then
		value = dt * dt * ((overshoot + 1) * dt - overshoot)
	end
	self.cc.inner:update(value)
end


return EaseBackIn

