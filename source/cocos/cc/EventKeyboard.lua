
local	EventKeyboard = {}
EventKeyboard = class("cc.EventKeyboard")


function EventKeyboard:ctor()
	self.cc.manager = nil
	
end


function EventKeyboard:setCapture(
	capture
	)
	if self.cc.manager then
		return self.cc.manager:setCapture(capture)
	end
end


function EventKeyboard:removeCapture()
	if self.cc.manager then
		return self.cc.manager:removeCapture()
	end
end


function EventKeyboard:getKey()
	if self.cc.manager then
		return self.cc.manager:getKey()
	end
end


function EventKeyboard:getKeys()
	if self.cc.manager then
		return self.cc.manager:getKeys()
	end
end


return EventKeyboard
