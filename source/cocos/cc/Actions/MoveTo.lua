local	MoveBy = import(".MoveBy")

local	MoveTo = {}
MoveTo = class("cc.MoveTo", MoveBy)


function MoveTo:ctor(duration, position, y, ...)
	MoveBy.ctor(self)
	self.cc.endPosition = cc.p(0, 0)
	self:initWithDuration(duration, position, y)
end


function MoveTo:initWithDuration(duration, position, y)
	if MoveBy.initWithDuration(self, duration, position, y) then
		if type(position) == "table" then
			y = position.y
			position = position.x
		end
		self.cc.endPosition = cc.p(position, y)
		return true
	end
end


function MoveTo:startWithTarget(target)
	MoveBy.startWithTarget(self, target)
	self.cc.positionDelta.x = self.cc.endPosition.x - target:getPosition().x
	self.cc.positionDelta.y = self.cc.endPosition.y - target:getPosition().y
end

return MoveTo
