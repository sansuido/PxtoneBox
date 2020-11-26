local	ActionInterval = import(".ActionInterval")

local	TintTo = {}
TintTo = class("cc.TintTo", ActionInterval)

function TintTo:ctor(duration, red, green, blue, ...)
	ActionInterval.ctor(self, duration, red, green, blue, ...)
	
	self.cc.to = cc.c3b(0, 0, 0)
	self.cc.from = cc.c3b(0, 0, 0)
	
	self:initWithDuration(duration, red, green, blue, ...)
end


function TintTo:initWithDuration(duration, red, green, blue)
	if ActionInterval.initWithDuration(self, duration) then
		self.cc.to = cc.c3b(red, green, blue)
	end
end


function TintTo:startWithTarget(target)
	ActionInterval.startWithTarget(self, target)
	self.cc.from = target.cc.color
end


function TintTo:update(dt)
	
	if self.cc.from then
		self.cc.target:setColor(
			cc.c3b(
				self.cc.from.r + (self.cc.to.r - self.cc.from.r) * dt,
				self.cc.from.g + (self.cc.to.g - self.cc.from.g) * dt,
				self.cc.from.b + (self.cc.to.b - self.cc.from.b) * dt
			)
		)
	end
end


return TintTo

