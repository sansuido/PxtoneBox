-- 疑似シーン

local	Node = import(".Node")

local	EventMouseManager = import(".EventMouseManager")
local	EventKeyboardManager = import(".EventKeyboardManager")

local	Scene = {}
Scene = class("cc.Scene", Node)


function Scene:ctor(...)
	Node.ctor(self, ...)
	self.cc.scene = self
	self.cc.eventMouseManager = EventMouseManager:create()
	self.cc.eventKeyboardManager = EventKeyboardManager:create()
	self.cc.schedules = {}
	
	local	director = self:getDirector()
	
	self.cc.contentSize = director:getContentSize()
	
	-- 上に変更
--	self.cc.contentSize = cc.size(love.graphics.getWidth(), love.graphics.getHeight())
end

function Scene:createWithPhysics()
	-- 物理演算を構築しながら作成（仮）
	self:create()
	self.cc.physicsWorld = love.physics.newWorld()
end


function Scene:registerSchedule(
	-- （仮）
	node,
	schedule
	)
	self.cc.schedules[node] = {
		callback = schedule
	}
end

function Scene:removeSchedule(
	-- （仮）
	node
	)
	self.cc.schedules[node] = nil
end


function Scene:registerEventMouseListener(
	-- （仮）
	node,
	eventMouseListener
	)
	
	self.cc.eventMouseManager:addNode(node, eventMouseListener)
end


function Scene:removeEventMouseListener(
	-- （仮）
	node
	)
	self.cc.eventMouseManager:removeNode(node)
end


function Scene:registerEventKeyboardListener(
	-- （仮）
	node,
	eventKeyboardListener
	)
	self.cc.eventKeyboardManager:addNode(node, eventKeyboardListener)
end


function Scene:removeEventKeyboardListener(
	-- （仮）
	node
	)
	self.cc.eventKeyboardManager:removeNode(node)
end



function Scene:onUpdate(
	dt
	)
	
	if self.cc.physicsWorld then
		self.cc.physicsWorld:update(dt)
	end
	
	-- ■スケジュール関連処理
	do
		for node, status in pairs(self.cc.schedules) do
			status.callback(node, dt)
		end
	end
end


function Scene:mousemoved(...)
	if self.cc.eventMouseManager then
		self.cc.eventMouseManager:mousemoved(...)
	end
end


function Scene:mousepressed(...)
	if self.cc.eventMouseManager then
		self.cc.eventMouseManager:mousepressed(...)
	end
end


function Scene:mousereleased(...)
	if self.cc.eventMouseManager then
		self.cc.eventMouseManager:mousereleased(...)
	end
end


function Scene:wheelmoved(...)
	if self.cc.eventMouseManager then
		self.cc.eventMouseManager:wheelmoved(...)
	end
end

function Scene:keypressed(...)
	if self.cc.eventKeyboardManager then
		self.cc.eventKeyboardManager:keypressed(...)
	end
end


function Scene:keyreleased(...)
	if self.cc.eventKeyboardManager then
		self.cc.eventKeyboardManager:keyreleased(...)
	end
end

return Scene


