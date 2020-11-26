local	ActionInterval = import(".ActionInterval")

local	Animate = {}

Animate = class("cc.Animate", ActionInterval)

function Animate:ctor(animation, ...)
	ActionInterval.ctor(self, animation, ...)
	
	if animation then self:initWithAnimation(animation) end
end


function Animate:getAnimation()
	return self.cc.animation
end


function Animate:setAnimation(
	animation
	)
	self.cc.animation = animation
end


function Animate:initWithAnimation(animation)
	
	if self:initWithDuration(animation:getDuration() * animation:getLoops()) then
		self.cc.nextFrame = 1
		self:setAnimation(animation)
		self.cc.origFrame = nil
		self.cc.executeLoops = 0
		
		self.cc.splitTimes = {}
		
		local	singleDuration = animation:getDuration()
		local	accumUnitsOfTime = 0
		
		-- これだけが間違ってた
		local	newUnitOfTimeValue = singleDuration / animation:getTotalDelayUnits()
		local	frames = animation:getFrames()
		for i, frame in ipairs(animation:getFrames()) do
			local	value = (accumUnitsOfTime * newUnitOfTimeValue) / singleDuration
			accumUnitsOfTime = accumUnitsOfTime + frame:getDelayPerUnits()
			
			table.insert(self.cc.splitTimes, value)
		end
		
		return true
	end
	return false
end

function Animate:startWithTarget(target)
	ActionInterval.startWithTarget(self, target)
	self.cc.nextFrame = 1
	self.cc.executedLoops = 0
end


function Animate:update(dt)
	
	local	frames = self:getAnimation():getFrames()
	local	numberOfFrames = #frames
	
	if dt < 1.0 then
		dt = dt * self:getAnimation():getLoops()
		dt = dt % 1.0
	end
	
	for i = self.cc.nextFrame, numberOfFrames do
		if self.cc.splitTimes[i] <= dt then
			
			self.cc.currentFrameIndex = i
			
			self.cc.target:setSpriteFrame(frames[self.cc.currentFrameIndex]:getSpriteFrame())
			
			self.cc.nextFrame = i + 1
		else
			break
		end
	end
end


return Animate
