
local	ActionHashElement = import(".ActionHashElement")

local	ActionManager = {}
ActionManager = class("cc.ActionManager")

function ActionManager:ctor(...)
	self.cc.arrayTargets = {}
	self.cc.hashTargets = {}
	
end

function ActionManager:addAction(
	action,
	target,
	paused
	)
	
	
	if action and target then
		
		local	element = self.cc.hashTargets[target]
		if element == nil then
			element = ActionHashElement:create()
			element.cc.paused = paused
			element.cc.target = target
			
			self.cc.hashTargets[target] = element
			table.insert(self.cc.arrayTargets, element)
		end
		
		table.insert(element.cc.actions, action)
		action:startWithTarget(target)
	end
end


function ActionManager:removeAllActionsFromTarget(
	target
	)
	if target == nil then return end
	local	element = self.cc.hashTargets[target]
	if element then
		self:deleteHashElement(element)
	end
end


function ActionManager:deleteHashElement(element)
	if element then
		if self.cc.hashTargets[element.cc.target] then
			self.cc.hashTargets[element.cc.target] = nil
			table.removebyvalue(self.cc.arrayTargets, element)
		end
	end
end


function ActionManager:resumeTarget(
	target
	)
	local	element = self.cc.hashTargets[target]
	if element then
		element.cc.paused = false
	end
end


function ActionManager:pauseTarget(
	target
	)
	
	local	element = self.cc.hashTargets[target]
	if element then
		element.cc.paused = true
	end
end


function ActionManager:removeAction(action)
	if action then
		local	target = action:getOriginalTarget()
		local	element = self.cc.hashTargets[target]
		if element then
			local	max = #element.cc.actions
			local	index = 1
			while index <= max do
				if element.cc.actions[index] == action then
					table.remove(element.cc.actions, index)
					index = index - 1
					max = max - 1
				end
				index = index + 1
			end
		end
	end
end


function ActionManager:removeActionByTag(tag, target)
	if target then
		local	element = self.cc.hashTargets[target]
		if element then
			local	max = #element.cc.actions
			local	index = 1
			while index <= max do
				local	action = element.cc.actions[index]
				if action:getTag() == tag and action:getOriginalTarget() == target then
					table.remove(element.cc.actions, index)
					index = index - 1
					max = max - 1
				end
				index = index + 1
			end
		end
	end
	
end


function ActionManager:getActionByTag(tag, target)
	if target then
		local	element = self.cc.hashTargets[target]
		if element then
			local	max = #element.cc.actions
			for i = 1, max do
				local	action = element.cc.actions[index]
				if action:getTag() == tag then
					return action
				end
			end
		end
	end
end


function ActionManager:update(
	dt
	)
	
	local	locTargets = self.cc.arrayTargets
	local	locCurrentTarget = nil
	local	max = #locTargets
	for index = 1, max do
		self.cc.currentTarget = locTargets[index]
		locCurrentTarget = self.cc.currentTarget
		if locCurrentTarget.cc.paused == false then
			local	actionIndex
			local	actionMax = #locCurrentTarget.cc.actions
			for actionIndex = 1, actionMax do
				locCurrentTarget.cc.currentAction = locCurrentTarget.cc.actions[actionIndex]
				
				if locCurrentTarget.cc.currentAction then
					
					locCurrentTarget.cc.currentActionSalvaged = false
					
					locCurrentTarget.cc.currentAction:step(dt * 1)
					
					if locCurrentTarget.cc.currentActionSalvaged == true then
						locCurrentTarget.cc.currentAction = nil
					elseif locCurrentTarget.cc.currentAction:isDone() == true then
						locCurrentTarget.cc.currentAction:stop()
						local	action = locCurrentTarget.cc.currentAction
						locCurrentTarget.cc.currentAction = nil
						
						self:removeAction(action)
					end
					locCurrentTarget.cc.currentAction = nil
				end
			end
			
		end
	end
end

return ActionManager


