
local	EventMouse = {}
EventMouse = class("cc.EventMouse")


function EventMouse:ctor()
	self.cc.manager = nil
end

function EventMouse:getLocation()
	if self.cc.manager then
		return self.cc.manager:getLocation()
	end
end

function EventMouse:getPreviousLocation()
	if self.cc.manager then
		return self.cc.manager:getPreviousLocation()
	end
end


function EventMouse:getStartLocation()
	if self.cc.manager then
		return self.cc.manager:getStartLocation()
	end
end


function EventMouse:getScroll()
	if self.cc.manager then
		return self.cc.manager:getScroll()
	end
end

function EventMouse:getDelta()
	if self.cc.manager then
		return self.cc.manager:getDelta()
	end
end

function EventMouse:getButton()
	if self.cc.manager then
		return self.cc.manager:getButton()
	end
end


function EventMouse:getButtons()
	if self.cc.manager then
		return self.cc.manager:getButtons()
	end
end


function EventMouse:getCapture()
	if self.cc.manager then
		return self.cc.manager:getCapture()
	end
end

function EventMouse:isCapture(
	node
	)
	if self.cc.manager and node then
		return self.cc.manager:getCapture() == node
	end
end

function EventMouse:setCapture(
	-- 仮
	capture
	)
	if self.cc.manager then
		return self.cc.manager:setCapture(capture)
	end
end

function EventMouse:removeCapture()
	-- 仮
	if self.cc.manager then
		return self.cc.manager:removeCapture()
	end
end

return EventMouse

