local	ActionEase = import(".ActionEase")

local	EaseBackOut = {}
EaseBackOut = class("cc.EaseBackOut", ActionEase)


function EaseBackOut:update(dt)
	local	overshoot = 1.70158
	dt = dt - 1
	self.cc.inner:update(dt * dt * ((overshoot + 1) * dt + overshoot) + 1)
end


return EaseBackOut

