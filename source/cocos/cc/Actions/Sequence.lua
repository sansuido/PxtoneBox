local	ActionInterval = import(".ActionInterval")

local	Sequence = {}
Sequence = class("cc.Sequence", ActionInterval)


function Sequence:ctor(...)
	ActionInterval.ctor(self, ...)
	
	self.cc.actions = {}
	self.cc.last = 1
	
	local	tempArray = { ... }
	local	last = #tempArray
	
	if last >= 1 then
		local	prev = tempArray[1]
		local	action1 = nil
		for i = 2, last - 1 do
			if tempArray[i] then
				action1 = prev
				
				local	seq = Sequence:create()
				seq:initWithTwoActions(action1, tempArray[i])
				prev = seq
			end
		end
		
		self:initWithTwoActions(prev, tempArray[last])
	end
end

function Sequence:initWithTwoActions(actionOne, actionTwo)
	local	duration = actionOne.cc.duration + actionTwo.cc.duration
	self:initWithDuration(duration)
	self.cc.actions[1] = actionOne
	self.cc.actions[2] = actionTwo
end


function Sequence:startWithTarget(target)
	ActionInterval.startWithTarget(self, target)
	
	self.cc.split = self.cc.actions[1].cc.duration / self.cc.duration
	self.cc.last = 0
end

function Sequence:stop()
	
	if self.cc.last ~= 0 then
		self.cc.actions[self.cc.last]:stop()
	end
	
	ActionInterval.stop(self)
end

function Sequence:update(dt)
	local	new_t = nil
	local	found = 1
	local	actionFound = nil
	
	if dt < self.cc.split then
		
		new_t = 1
		if self.cc.split ~= 0 then new_t = dt / self.cc.split end
		
		if self.cc.last == 2 then
			self.cc.actions[2]:update(0)
			self.cc.actions[2]:stop()
		end
	else
		found = 2
		if self.cc.split == 1 then
			new_t = 1
		else
			new_t = (dt - self.cc.split) / (1 - self.cc.split)
		end
		
		if self.cc.last == 0 then
			self.cc.actions[1]:startWithTarget(self.cc.target)
			self.cc.actions[1]:update(1)
			self.cc.actions[1]:stop()
		end
		if self.cc.last == 1 then
			self.cc.actions[1]:update(1)
			self.cc.actions[1]:stop()
		end
	end
	
	actionFound = self.cc.actions[found]
	if self.cc.last == found and actionFound:isDone() then
		return
	end
	
	if self.cc.last ~= found then
		actionFound:startWithTarget(self.cc.target)
	end
	
	actionFound.cc.timesForRepeat = actionFound.cc.timesForRepeat or 1
	
	new_t = new_t * actionFound.cc.timesForRepeat
	if new_t > 1 then new_t = new_t % 1 end
	actionFound:update(new_t)
	
	self.cc.last = found
end

return Sequence


