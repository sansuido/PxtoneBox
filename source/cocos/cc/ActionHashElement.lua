
local	ActionHashElement = {}

ActionHashElement = class("cc.ActionHashElement")


function ActionHashElement:ctor(...)
	self.cc.actions = {}
	self.cc.target = nil
	self.cc.actionIndex = 0
	self.cc.currentAction = nil
	self.cc.currentActionSalvaged = false
	self.cc.paused = flase
end


return ActionHashElement


