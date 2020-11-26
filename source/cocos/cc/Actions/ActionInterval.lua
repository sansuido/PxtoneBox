local	FiniteTimeAction = import(".FiniteTimeAction")

local	ActionInterval = {}

ActionInterval = class("cc.ActionInterval", FiniteTimeAction)

function ActionInterval:ctor(dt, ...)
	
	FiniteTimeAction.ctor(self, dt, ...)
	
	self.cc.timesForRepeat = 1
	self.cc.elapsed = 0
	self.cc.firstTick = false
	self.cc.easeList = nil
	self.cc.timeForRepeat = 1
	self.cc.repeatForever = false
	self.cc.repeatMethod = false
	self.cc.speed = 1
	self.cc.speedMethod = false
	self.MAX_VALUE = 2
	
	self:initWithDuration(dt)
end

function ActionInterval:getElapsed()
	return self.cc.elapsed
end

function ActionInterval:initWithDuration(dt)
	if type(dt) == "number" then
		self.cc.duration = dt
		
	else
		self.cc.duration = cc.FLT_EPSILON
	end
	
	self.cc.elapsed = 0
	self.cc.firstTick = true
	
	return true
end


function ActionInterval:getDuration() 
	return self.cc.duration * (self.cc.timesForRepeat or 1)
end

function ActionInterval:setDuration(duration)
	self.cc.duration = duration
end


function ActionInterval:isDone()
	return self.cc.elapsed >= self.cc.duration
end

function ActionInterval:step(dt)
	if self.cc.firstTick then
		self.cc.firstTick = false
		self.cc.elapsed = 0
	else
		self.cc.elapsed = self.cc.elapsed + dt;
		
		local	mul = self.cc.duration
		if mul < 0.0000001192092896 then mul = 0.0000001192092896 end
		local	tick = self.cc.elapsed / mul
		if tick > 1 then tick = 1 end
		if tick < 0 then tick = 0 end
		
		self:update(tick)
		if self.cc.repeatMethod and self.cc.timesForRepeat > 1 and this:isDone() then
			if self.cc.repeatForever == false then
				self.cc.timesForRepeat = self.cc.timesForRepeat - 1
			end
			
			self:startWithTarget(self.cc.target)
			self:step(self.cc.epapsed - self.cc.duration)
		end
	end
end

function ActionInterval:startWithTarget(target)
	FiniteTimeAction.startWithTarget(self, target)
	self.cc.elapsed = 0
	self.cc.firstTick = true
end

return ActionInterval



