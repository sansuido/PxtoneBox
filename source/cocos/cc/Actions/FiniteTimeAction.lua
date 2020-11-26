local	Action = import(".Action")

local	FiniteTimeAction = {}
FiniteTimeAction = class("cc.FiniteTimeAction", Action)


function FiniteTimeAction:ctor(...)
	
	Action.ctor(self, ...)
	
	self.cc.duration = 0
end


function FiniteTimeAction:getDuration()
	return self.cc.duration * self.cc.timeForRepeat
end


function FiniteTimeAction:setDuration(duration)
	self.cc.duration = duration
end


function FiniteTimeAction:reverse()
	return nil
end


function FiniteTimeAction:clone()
	return FiniteTimeAction:create()
end


return FiniteTimeAction


