local	EventMouseManager = {}

EventMouseManager = class("cc.EventMouseManager")


function EventMouseManager:_directorFilter(x, y)
	local	offset = cc.Director:getInstance().cc.offset
	local	scaler = cc.Director:getInstance().cc.scaler
	local	size = cc.Director:getInstance():getContentSize()
	
	return
		math.floor((x - offset.x) / (scaler * size.width)  * size.width),
		math.floor((y - offset.y) / (scaler * size.height) * size.height)
end

function EventMouseManager:_directorFilter2(x, y)
	local	scaler = cc.Director:getInstance().cc.scaler
	return x / scaler, y / scaler
end


function EventMouseManager:ctor()
	local	x, y = love.mouse.getX(), love.mouse.getY()
	
	x = x or 0
	y = y or 0
	
	x, y = self:_directorFilter(x, y)
	
	self.cc.location = cc.p(x, y)
	self.cc.previousLocation = self.cc.location
	self.cc.startLocation = nil
	self.cc.buttons = {}
	self.cc.button = nil
	
	self.cc.capture = nil
	self.cc.list = {}
	self.cc.delta = 0
end


function EventMouseManager:addNode(
	node,
	event
	)
	
	event.cc.manager = self
	self.cc.list[node] = event
end


function EventMouseManager:removeNode(
	node
	)
	self.cc.list[node] = nil
end


function EventMouseManager:getLocation()
	return self.cc.location
end


function EventMouseManager:getPreviousLocation()
	return self.cc.previousLocation
end


function EventMouseManager:getStartLocation()
	return self.cc.startLocation
end


function EventMouseManager:getScroll()
	return self.cc.scroll
end

function EventMouseManager:getButton()
	return self.cc.button
end


function EventMouseManager:getButtons()
	return self.cc.buttons
end


function EventMouseManager:getDelta()
	return self.cc.delta
end


function EventMouseManager:getCapture(
	-- 仮
	)
	return self.cc.capture
end


function EventMouseManager:setCapture(
	-- 仮
	capture
	)
	self.cc.capture = capture
end


function EventMouseManager:removeCapture(
	-- 仮
	)
	self.cc.capture = nil
end


function EventMouseManager:callEvent(
	callname
	)
	local	capture = self.cc.capture
	
	if capture then
		local	event = self.cc.list[capture]
		if type(event[callname]) == "function" then
			local	bl = event[callname](capture, event)
			if bl then
				capture:setDrawRequest()
			end
		end
	else
		local	tbls = {}
		table.walk(
			self.cc.list,
			function(event, node)
				table.insert(tbls, { node = node, event = event })
			end
		)
		table.sort(
			tbls,
			function(a, b)
				return a.node:getDrawOrder() > b.node:getDrawOrder()
			end
		)
		for index, tbl in ipairs(tbls) do
			if type(tbl.event[callname]) == "function" then
			-- cc.Blinkで制御が消えるのがあれなんで、visible判定を外してみた？
--			if type(tbl.event[callname]) == "function" and tbl.node:isVisible() then
				local	bl = tbl.event[callname](tbl.node, tbl.event)
				if bl then
					tbl.node:setDrawRequest()
					break
				end
			end
		end
--		for node, event in pairs(self.cc.list) do
--			if type(event[callname]) == "function" then
--				event[callname](node, event)
--			end
--		end
	end
end


function EventMouseManager:mousemoved(x, y, dx, dy)
	x, y = self:_directorFilter(x, y)
	dx, dy = self:_directorFilter2(dx, dy)
	
	self.cc.scroll = cc.p(0, 0)
	self.cc.delta = cc.p(dx , dy)
	self.cc.previousLocation = self.cc.location
	self.cc.location = cc.p(x, y)
	self.cc.button = nil
	
	self:callEvent("onMouseMove")
end


function EventMouseManager:mousepressed(x, y, button)
	x, y = self:_directorFilter(x, y)
	
	self.cc.scroll = cc.p(0, 0)
	self.cc.delta = cc.p(0, 0)
	self.cc.previousLocation = self.cc.location
	self.cc.location = cc.p(x, y)
	self.cc.buttons[button] = true
	self.cc.button = button
	
	-- 生のイベント
	self:callEvent("mousePressed")
	
	if button == 1 then
--	if button == "l" then
		self.cc.startLocation = cc.p(x, y)
		love.mouse.setGrabbed(true)
		self:callEvent("onMouseDown")
	end
end


function EventMouseManager:mousereleased(x, y, button)
	x, y = self:_directorFilter(x, y)
	
	self.cc.scroll = cc.p(0, 0)
	self.cc.delta = cc.p(0, 0)
	self.cc.previousLocation = self.cc.location
	self.cc.location = cc.p(x, y)
	self.cc.buttons[button] = false
	self.cc.button = button
	
	-- 生のイベント
	self:callEvent("mouseReleased")
	
	if button == 1 then
--	if button == "l" then
		self:callEvent("onMouseUp")
		self.cc.startLocation = nil
		love.mouse.setGrabbed(false)
	end
end


function EventMouseManager:wheelmoved(x, y)
	self.cc.scroll = cc.p(x, y)
	self:callEvent("onScroll")
end

return EventMouseManager
