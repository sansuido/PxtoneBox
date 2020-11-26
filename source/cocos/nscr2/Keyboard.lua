local	Keyboard = {}

Keyboard.setKeyRepeat = function() end

Keyboard.isScancodeDown = function(...)
	local	buttons = { ... }
	for i, button in ipairs(buttons) do
		if gui.getkey(button) then
			return true
		end
	end
	return false
end

return Keyboard
