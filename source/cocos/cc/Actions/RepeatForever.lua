
local	ActionInterval = import(".ActionInterval")


local	RepeatForever = {}
RepeatForever = class("cc.RepeatForever", ActionInterval)


function RepeatForever:ctor(action, ...)
	ActionInterval.ctor(self, action, ...)
	self.cc.innerAction = nil
	self:initWithAction(action)
end


function RepeatForever:initWithAction(action)
	self.cc.innerAction = action
	return true
end


function RepeatForever:startWithTarget(target)
	ActionInterval.startWithTarget(self, target)
	self.cc.innerAction:startWithTarget(target)
end

function RepeatForever:isDone()
	return false
end


function RepeatForever:step(dt)
	self.cc.innerAction:step(dt)
	if self.cc.innerAction:isDone() then
		self.cc.innerAction:startWithTarget(self.cc.target)
		self.cc.innerAction:step(self.cc.innerAction:getElapsed() - self.cc.innerAction.cc.duration)
	end
	
end


return RepeatForever

