local	ActionInterval = import(".ActionInterval")

local	MoveBy = {}
MoveBy = class("cc.MoveBy", ActionInterval)


function MoveBy:ctor(...)
	ActionInterval.ctor(self, ...)
	
	self.cc.positionDelta = cc.p(0, 0)
	self.cc.startPosition = cc.p(0, 0)
	self.cc.previousPosition = cc.p(0, 0)
	
	self:initWithDuration(...)
end


function MoveBy:initWithDuration(duration, position, y, ...)
	ActionInterval.initWithDuration(self, duration, position, y, ...)
	
	if type(position) == "table" then
		self.cc.positionDelta = cc.p(position.x, position.y)
		return true
	elseif type(position) == "number" then
		self.cc.positionDeleta = cc.p(position, y)
		return true
	end
	return false
end

function MoveBy:startWithTarget(target)

	ActionInterval.startWithTarget(self, target)
	local	locPosX = target:getPositionX()
	local	locPosY = target:getPositionY()
	
	self.cc.previousPosition.x = locPosX
	self.cc.previousPosition.y = locPosY
	self.cc.startPosition.x = locPosX
	self.cc.startPosition.y = locPosY
	
end


function MoveBy:update(dt)
	if self.cc.target then
		local	x = self.cc.positionDelta.x * dt
		local	y = self.cc.positionDelta.y * dt
		local	locStartPosition = self.cc.startPosition
		self.cc.target:setPosition(locStartPosition.x + x, locStartPosition.y + y)
	end
end


return MoveBy
