
local	EventKeyboardManager = {}

EventKeyboardManager = class("cc.EventKeyboardManager")

function EventKeyboardManager:ctor()
	
	
	-- リピート情報を補足する
	love.keyboard.setKeyRepeat(true)
	
	self.cc.key = nil
	self.cc.isrepeat = nil
	self.cc.keys = {}
	
	self.cc.capture = nil
	self.cc.list = {}
end


function EventKeyboardManager:addNode(
	node,
	event
	)
	
	event.cc.manager = self
	self.cc.list[node] = event
end


function EventKeyboardManager:removeNode(
	node
	)
	self.cc.list[node] = nil
end


function EventKeyboardManager:getCapture(
	-- 仮
	)
	return self.cc.capture
end


function EventKeyboardManager:setCapture(
	-- 仮
	capture
	)
	self.cc.capture = capture
end


function EventKeyboardManager:removeCapture(
	-- 仮
	)
	self.cc.capture = nil
end


function EventKeyboardManager:getKey()
	return self.cc.key, self.cc.isrepeat
end

function EventKeyboardManager:getKeys()
	return self.cc.keys
end

function EventKeyboardManager:callEvent(
	callname
	)
	
	local	capture = self.cc.capture
	if capture then
		local	event = self.cc.list[capture]
		if type(event[callname]) == "function" then
			event[callname](capture, event)
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
				if bl then break end
			end
		end
	end
end


function EventKeyboardManager:keypressed(
	key,
	scancode,
	isrepeat
	)
	
	self.cc.key = key
	self.cc.isrepeat = isrepeat
	self.cc.keys[key] = true
	
	-- とりあえず投げてみる
	self:callEvent("keyPressed")
end


function EventKeyboardManager:keyreleased(
	key
	)
	
	self.cc.key = key
	self.cc.isrepeat = false
	self.cc.keys[key] = false
	
	-- とりあえず投げてみる
	self:callEvent("keyReleased")
end


return EventKeyboardManager
