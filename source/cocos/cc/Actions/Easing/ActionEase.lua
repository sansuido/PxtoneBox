
local	ActionInterval = import("..ActionInterval")

local	ActionEase = {}

ActionEase = class("cc.ActionEase", ActionInterval)

function ActionEase:ctor(action)
	ActionInterval.ctor(self)
	
	self:initWithAction(action)
end


function ActionEase:initWithAction(action)
	if self:initWithDuration(action:getDuration()) then
		self.cc.inner = action
		return true
	end
end


function ActionEase:startWithTarget(target)
	ActionInterval.startWithTarget(self, target)
	self.cc.inner:startWithTarget(self.cc.target)
end


function ActionEase:stop()
	self.cc.inner:stop()
	ActionInterval.stop(self)
end


function ActionEase:update(dt)
	self.cc.inner:update(dt)
end


return ActionEase

