local	ActionInterval = import(".ActionInterval")

local	FadeTo = {}
FadeTo = class("FadeTo", ActionInterval)


function FadeTo:ctor(duration, opacity)
	self.cc.toOpacity = 0
	self.cc.fromOpacity = 0
	
	self:initWithDuration(duration, opacity)
end


function FadeTo:initWithDuration(duration, opacity)
	if ActionInterval.initWithDuration(self, duration, opacity) then
		self.cc.toOpacity = opacity
	end
end


function FadeTo:startWithTarget(target)
	ActionInterval.startWithTarget(self, target)
	self.cc.fromOpacity = target.cc.opacity
end


function FadeTo:update(dt)
	self.cc.target.cc.opacity = self.cc.fromOpacity + (self.cc.toOpacity - self.cc.fromOpacity) * dt
end


return FadeTo

