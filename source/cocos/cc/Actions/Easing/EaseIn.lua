local	EaseRateAction = import(".EaseRateAction")

local	EaseIn = {}
EaseIn = class("cc.EaseIn", EaseRateAction)

function EaseIn:update(dt)
	self.cc.inner:update(math.pow(dt, self.cc.rate))
end


return EaseIn
