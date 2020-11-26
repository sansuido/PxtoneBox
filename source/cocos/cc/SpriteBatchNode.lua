
local	Node = import(".Node")

local	SpriteBatchNode = {}
SpriteBatchNode = class("cc.SpriteBatchNode", Node)


function SpriteBatchNode:ctor(...)
	
	Node.ctor(self, ...)
	
	self.cc.texture = nil
	self.cc.spriteBatch = nil
	
	self:setAnchorPoint(cc.p(0.5, 0.5))
end


function SpriteBatchNode:initWithFile(
	texture
	)
	if type(texture) == "string" then
		self.cc.texture = self:getDirector():loadSource("image", texture)
	else
		self.cc.texture = texture
	end
	if self.cc.texture then
--		self.cc.texture:setFilter("nearest", "nearest")
		self.cc.spriteBatch = love.graphics.newSpriteBatch(self.cc.texture)
	end
end


function SpriteBatchNode:getTexture()
	return self.cc.texture
end


function SpriteBatchNode:draw(offset)
	if self.cc.spriteBatch then
		local	r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(self.cc.color.r or 1, self.cc.color.g or 1, self.cc.color.b or 1, self.cc.opacity or 1)
--		love.graphics.setColor(self.cc.color.r or 255, self.cc.color.g or 255, self.cc.color.b or 255, self.cc.opacity or 255)
		local	drawSpace = self:getDrawSpace(offset)
		
		love.graphics.push()
			
			love.graphics.draw(
				self.cc.spriteBatch,
				drawSpace.x,
				drawSpace.y
			)
			-- 元に戻す
			love.graphics.origin()
		love.graphics.pop()
		love.graphics.setColor(r, g, b, a)
	end
	Node.draw(self, offset)
end


function SpriteBatchNode:onReorder()
	
	
	local	children = self:getChildren()
	
	if self.cc.spriteBatch then
		if #children > self.cc.spriteBatch:getBufferSize() then
			self.cc.spriteBatch:setBufferSize(#children)
		end
		self.cc.spriteBatch:clear()
		for index, child in ipairs(children) do
			local	apip = child:getAnchorPointInPoints()
			-- テキスチャが同一の場合、バッチ側で処理する（仮）
			if type(child.batchEnabled) == "function" then
				if self:getTexture() == child:getTexture() then
					
					self.cc.spriteBatch:add(
						child.cc.textureQuad,
						child:getPosition().x - apip.x,
						child:getPosition().y - apip.y
					)
					child:batchEnabled(true)
				else
					child:batchEnabled(false)
				end
			end
			
		end
		self.cc.spriteBatch:flush()
	end
end



return SpriteBatchNode
