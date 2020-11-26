-- 疑似レイヤー

local	Bump = import("..lib.bump")
local	Node = import(".Node")


local	Layer = {}

Layer = class("cc.Layer", Node)


function Layer:ctor(...)
	Node.ctor(self, ...)
	
	local	director = self:getDirector()
	self.cc.contentSize = director:getContentSize()
	-- 上に変更
	--	self.cc.contentSize = cc.size(love.graphics.getWidth(), love.graphics.getHeight())
--	self.cc.contentSize = cc.size(gui.getsize())
	
	self.cc.bumpWorld = Bump.newWorld()
	
--	self:createCanvas()
end


return Layer

