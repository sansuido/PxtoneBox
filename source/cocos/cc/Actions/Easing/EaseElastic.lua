local	ActionEase = import(".ActionEase")

local	EaseElastic = {}
EaseElastic = class("cc.EaseElastic", ActionEase)

function EaseElastic:ctor(action, period, ...)
	ActionEase.ctor(self, action, period, ...)
	
	self:initWithAction(action, period)
end


function EaseElastic:initWithAction(action, period)
	if ActionEase.initWithAction(self, action) then
		self.cc.period = period or 0.3
		return true
	end
end


return EaseElastic
