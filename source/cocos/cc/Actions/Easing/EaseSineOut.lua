local	ActionEase = import(".ActionEase")

local	EaseSineOut = {}
EaseSineOut = class("cc.EaseSineOut", ActionEase)

function EaseSineOut:update(dt)
	local	value = dt
	if dt ~= 0 and dt ~= 1 then
		value = math.sin(dt * math.pi / 2)
	end
	self.cc.inner:update(value)
end


return EaseSineOut
