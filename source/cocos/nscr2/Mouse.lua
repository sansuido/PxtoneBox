local	Mouse = {}

Mouse.setGrabbed = function() end

Mouse.getX = function()
	local	x, y = nscr2.gui.getmouse()
	return x
end


Mouse.getY = function()
	local	x, y = nscr2.gui.getmouse()
	return y
end

return Mouse
