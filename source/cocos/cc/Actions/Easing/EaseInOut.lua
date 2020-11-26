local	EaseRateAction = import(".EaseRateAction")

local	EaseInOut = {}
EaseInOut = class("cc.EaseInOut", EaseRateAction)

function EaseInOut:update(dt)
	dt = dt * 2
	
	if dt < 1 then
		self.cc.inner:update(0.5 * math.pow(dt, self.cc.rate))
	else
		self.cc.inner:update(1.0 - 0.5 * math.pow(2 - dt, self.cc.rate))
	end
end


return EaseInOut
