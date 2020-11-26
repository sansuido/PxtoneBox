local	EaseRateAction = import(".EaseRateAction")

local	EaseOut = {}
EaseOut = class("cc.EaseOut", EaseRateAction)

function EaseOut:update(dt)
	self.cc.inner:update(math.pow(dt, 1 / self.cc.rate))
end


return EaseOut
