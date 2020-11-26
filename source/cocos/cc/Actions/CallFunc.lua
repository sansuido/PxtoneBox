
local	ActionInstant = import(".ActionInstant")


local	CallFunc = {}
CallFunc = class("cc.CallFunc", ActionInstant)


function CallFunc:ctor(
	selector,
	selectorTarget,
	data,
	...
	)
	
	ActionInstant.ctor(self, selector, selectorTarget, data, ...)
	
	self:initWithFunction(selector, selectorTarget, data)
end


function CallFunc:initWithFunction(
	selector,
	selectorTarget,
	data
	)
	
	if selector then self.cc.selector = selector end
	if selectorTarget then self.cc.selectorTarget = selectorTarget end
	if data then self.cc.data = data end
	
	return true
end


function CallFunc:execute()
	if self.cc.selector then
		self.cc.selector(self.cc.selectorTarget, self.cc.data)
		-- なんか引数がおかしいので上に修正
--		self.cc.selector(self.cc.selectorTarget, self.cc.target, self.cc.data)
	end
end


function CallFunc:update(dt)
	self:execute()
end


function CallFunc:clone()
	return CallFunc:create(self.cc.selector, self.cc.selectorTarget, self.cc.data)
end


return CallFunc
