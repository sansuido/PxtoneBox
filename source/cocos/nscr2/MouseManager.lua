local	MouseManager = {}
MouseManager = class("MouseManager")


function MouseManager:ctor(...)
	
	local	x, y = gui.getmouse()
	
	x = x or 0
	y = y or 0
	
	--self.cc = self.cc or {}
	self.cc.location = cc.p(x, y)
	self.cc.previousLocation = self.cc.location
	self.cc.startLocation = nil
end


function MouseManager:update(dt)
	local	x, y = gui.getmouse()
	if x and y then
		local	click = { gui.getclick() }
		local	press = {}
		local	release = {}
		self.cc.location = cc.p(x, y)
		local	bMove = cc.pFuzzyEqual(self.cc.location, self.cc.previousLocation, 0.5) == false
		local	bLeftUp = click[1]
		local	bLeftDown = click[4]
		local	bRightUp = click[2]
		local	bRightDown = click[3]
		local	bScroll = click[3] ~= 0
		
		if bLeftUp then table.insert(release, 1) end
		if bLeftDown then table.insert(press, 1) end
		if bRightUp then table.insert(release, 2) end
		if bRightDown then table.insert(press, 2) end
		
		if bMove then
			-- 移動
			love.mousemoved(x, y, self.cc.location.x - self.cc.previousLocation.x, self.cc.location.y - self.cc.previousLocation.y)
		end
		for i, button in ipairs(press) do
			-- 押した
			love.mousepressed(x, y, button, true)
		end
		for i, button in ipairs(release) do
			-- 離した
			love.mousereleased(x, y, button, true)
		end
		
		self.cc.previousLocation = self.cc.location
	end
end

return MouseManager
