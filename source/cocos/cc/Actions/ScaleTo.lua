local	ActionInterval = import(".ActionInterval")

local	ScaleTo = class("cc.ScaleTo", ActionInterval)


function ScaleTo:ctor(duration, scaleX, scaleY, ...)
	ActionInterval.ctor(self, duration, scaleX, scaleY, ...)
	
	self.cc.scaleX = 1
	self.cc.scaleY = 1
	self.cc.startScaleX = 1
	self.cc.startScaleY = 1
	self.cc.endScaleX = 0
	self.cc.endScaleY = 0
	self.cc.deltaX = 0
	self.cc.deltaY = 0
	
	self:initWithDuration(duration, scaleX, scaleY)
end


function ScaleTo:initWithDuration(duration, scaleX, scaleY)
	if ActionInterval.initWithDuration(self, duration) == true then
		self.cc.endScaleX = scaleX
		self.cc.endScaleY = scaleY or scaleX
		return true
	end
	return false
end


function ScaleTo:startWithTarget(target)
	ActionInterval.startWithTarget(self, target)
	self.cc.startScaleX = target.cc.scaleX
	self.cc.startScaleY = target.cc.scaleY
    self.cc.deltaX = self.cc.endScaleX - self.cc.startScaleX
    self.cc.deltaY = self.cc.endScaleY - self.cc.startScaleY
end


function ScaleTo:update(dt)
	if self.cc.target then
		self.cc.target.cc.scaleX = self.cc.startScaleX + self.cc.deltaX * dt
		self.cc.target.cc.scaleY = self.cc.startScaleY + self.cc.deltaY * dt
	end
end

return ScaleTo
