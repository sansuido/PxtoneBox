local	ActionEase = import(".ActionEase")

local	EaseBackInOut = {}
EaseBackInOut = class("cc.EaseBackInOut", ActionEase)


function EaseBackInOut:update(dt)
	local	overshoot = 1.70158 * 1.525
	local	value
	
	dt = dt * 2
	if dt < 1 then
		value = (dt * dt * ((overshoot + 1) * dt - overshoot)) / 2
	else
		dt = dt - 2
		value = (dt * dt * ((overshoot + 1) * dt + overshoot)) / 2 + 1
	end
	self.cc.inner:update(value)
end


return EaseBackInOut

