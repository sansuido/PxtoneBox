local	Action = {}
Action = class("cc.Action")


function Action:ctor(...)
	self.cc.originalTarget = nil
	self.cc.target = nil
	self.cc.tag = nil
end


function Action:startWithTarget(target)
	self.cc.originalTarget = target
	self.cc.target = target
end


function Action:stop()
	self.cc.target = nil
end


function Action:step(dt)
	-- [Action step]. override me
end


function Action:update(dt)
	-- [Action update]. override me
end


function Action:getTarget()
	return self.cc.target
end


function Action:setTarget(target)
	self.cc.target = target
end


function Action:getOriginalTarget()
	return self.cc.originalTarget
end


function Action:setOriginalTarget(originalTarget)
	self.cc.originalTarget = originalTarget
end


function Action:getTag()
	return self.cc.tag
end


function Action:setTag(tag)
	self.cc.tag = tag
end


function Action:stop()
	self.cc.target = nil
end

--function Action:isDone()
--	return true
--end


return Action
