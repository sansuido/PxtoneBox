local	ActionEase = import(".ActionEase")

local	EaseSineIn = {}
EaseSineIn = class("cc.EaseSineIn", ActionEase)

function EaseSineIn:update(dt)
	local	value = dt
	if dt ~= 0 and dt ~= 1 then
		value = -1 * math.cos(dt * math.pi / 2) + 1
	end
	self.cc.inner:update(value)
end


return EaseSineIn
