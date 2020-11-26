local	FiniteTimeAction = import(".FiniteTimeAction")

local	ActionInstant = {}
ActionInstant = class("cc.ActionInstant", FiniteTimeAction)


function ActionInstant:ctor(...)
	
	FiniteTimeAction.ctor(self, ...)
end


function ActionInstant:isDone()
	return true
end


function ActionInstant:step(dt)
	self:update(1)
end


function ActionInstant:reverse()
	return self:clone()
end


function ActionInstant:clone()
	return ActionInstant:create()
end


return ActionInstant
