local	AnimationFrame = import(".AnimationFrame")

local	Animation = {}
Animation = class("cc.Animation")

function Animation:ctor(
	frames,
	delayPerUnit,
	loops
	)
	
	self.cc.frames = {}
	self.cc.delayPerUnit = 0
	self.cc.loops = 1
	
	self:initWithSpriteFrames(frames, delayPerUnit, loops)
	
--	if frames then self:setFrames(frames) end
--	if delay then self:setDelayPerUnit(delay) end
end


function Animation:getLoops()
	return self.cc.loops
end


function Animation:setLoops(loops)
	self.cc.loops = loops
end


function Animation:getDuration()
	return self.cc.delayPerUnit * #self.cc.frames
end

function Animation:getDelayPerUnit()
	return self.cc.delayPerUnit
end


function Animation:setDelayPerUnit(
	delayPerUnit
	)
	
	self.cc.delayPerUnit = delayPerUnit
end


--function Animation:getTotalDelayUnits()
--	return self.cc.delayPerUnit * #self.cc.frames
--end

function Animation:getTotalDelayUnits()
	return self.cc.totalDelayUnits
end


function Animation:getFrames()
	return self.cc.frames
end


function Animation:setFrames(
	frames
	)
	
	for i, frame in ipairs(frames) do
		table.insert(self.cc.frames, frame)
	end
end


function Animation:initWithSpriteFrames(
	frames,
	delayPerUnit,
	loops
	)
	
	self.cc.delayPerUnit = delayPerUnit or self.cc.delayPerUnit or 0
	self.cc.totalDelayUnits = 0
	self.cc.loops = loops or self.cc.loops or 1
	for i, frame in ipairs(frames) do
		local	animFrame = AnimationFrame:create()
		animFrame:initWithSpriteFrame(frame, 1, nil)
		table.insert(self.cc.frames, animFrame)
	end
	self.cc.totalDelayUnits = #frames
end



return Animation
