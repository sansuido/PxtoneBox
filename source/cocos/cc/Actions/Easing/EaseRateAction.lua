local	ActionEase = import(".ActionEase")

local	EaseRateAction = {}
EaseRateAction = class("cc.EaseRateAction", ActionEase)

function EaseRateAction:ctor(action, rate, ...)
	ActionEase.ctor(self, action, rate, ...)
	self:initWithAction(action, rate)
end


function EaseRateAction:setRate(rate)
	self.cc.rate = rate
end


function EaseRateAction:getRate()
	return self.cc.rate
end


function EaseRateAction:initWithAction(action, rate)
	if ActionEase.initWithAction(self, action) then
		self.cc.rate = rate or 2
		return true
	end
	return false
end


return EaseRateAction
