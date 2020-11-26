local	ActionInterval = import(".ActionInterval")

local	Blink = {}
Blink = class("Blink", ActionInterval)

function Blink:ctor(duration, blinks, ...)
	self.cc.blinks = 0
	self.cc.originalState = false
	ActionInterval.ctor(self, duration, blinks, ...)
	
	self:initWithDuration(duration, blinks)
end


function Blink:initWithDuration(duration, blinks)
	ActionInterval.initWithDuration(self, duration)
	self.cc.blinks = blinks
	return true
end


function Blink:startWithTarget(target)
	ActionInterval.startWithTarget(self, target)
	self.cc.originalState = target.cc.visible
end


function Blink:update(dt)
	if self.cc.target and self:isDone() == false then
		local	slice = 1.0 / self.cc.blinks
		local	m = dt % slice
		self.cc.target.cc.visible = (m > (slice / 2))
	end
end


function Blink:stop()
	self.cc.target.cc.visible = self.cc.originalState
	ActionInterval.stop(self)
end

return Blink

