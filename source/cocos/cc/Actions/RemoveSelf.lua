local	ActionInstant = import(".ActionInstant")

local	RemoveSelf = {}
RemoveSelf = class("cc.RemoveSelf", ActionInstant)


function RemoveSelf:ctor(isNeedCleanUp, ...)
	ActionInstant.ctor(self, isNeedCleanUp, ...)
	self.cc.needCleanUp = isNeedCleanUp or true
end


function RemoveSelf:update(dt)
	self.cc.target:removeFromParent(self.cc.needCleanUp)
end


return RemoveSelf

