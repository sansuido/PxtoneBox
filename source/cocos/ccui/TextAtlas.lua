-- ナンチャッテテキストアトラス

local	Node = import("..cc.Node")

local	g_texture = texture

local	TextAtlas = {}
TextAtlas = class("ccui.TextAtlas", Node)


function TextAtlas:ctor(...)
	
	Node.ctor(self, ...)
	
	self:setAnchorPoint(cc.p(0.5, 0.5))
	--self.cc = self.cc or {}
	self.cc.stringValue = ""
	self.cc.stringMapFile = ""
	self.cc.itemWidth = 0
	self.cc.itemHeight = 0
	self.cc.charMap = ""
	self.cc.gap = 0
	
	self.cc.texture = nil
	self.cc.charTextureRects = {}
end


function TextAtlas:setProperty(
	stringValue,
	charMapFile,
	itemWidth,
	itemHeight,
	charMap,	-- ちょっと変えた（キャラクターマップを完全指定してね）
	pos
	)
	
	self.cc.charMapFile = charMapFile
	self.cc.itemWidth = itemWidth
	self.cc.itemHeight = itemHeight
--	self.cc.charMap = charMap
	charMap = charMap or ""
	pos = pos or cc.p(0, 0)
	
	self.cc.texture = self:getDirector():loadSource("image", self.cc.charMapFile)
	self:addCharacter(charMap, pos)
--	self.cc.texture = love.graphics.newImage(self.cc.charMapFile)
--	if self.cc.texture then
--		local	mapWidth, mapHeight
--		if type(self.cc.texture.getsize) == "function" then
--			mapWidth, mapHeight = self.cc.texture:getsize()
--		else
--			mapWidth, mapHeight = self.cc.texture:getWidth(), self.cc.texture:getHeight()
--		end
--		
--		local	xPos, yPos = 0, 0
--		
--		-- めんどいので、日本語非対応・・；
--		local	len = string.len(charMap)
--		for i = 1, len do
--			local	char = string.sub(charMap, i, i)
--			self.cc.charTextureRects[char] = love.graphics.newQuad(xPos, yPos, self.cc.itemWidth, self.cc.itemHeight, mapWidth, mapHeight)
----			self.cc.charTextureRects[char] = cc.rect(xPos, yPos, self.cc.itemWidth, self.cc.itemHeight)
--			
--			xPos = xPos + itemWidth
--			if xPos > mapWidth then
--				xPos = 0
--				yPos = yPos + itemHeight
--				if yPos > mapHeight then
--					break
--				end
--			end
--		end
--	end
	self:setStringValue(stringValue)
end


function TextAtlas:setTexture(charMapFile)
	self.cc.charMapFile = charMapFile
	self.cc.texture = self:getDirector():loadSource("image", self.cc.charMapFile)
end


function TextAtlas:addCharacter(
	-- キャラクターの追加処理
	charMap,
	pos
	)
	pos = pos or cc.p(0, 0)
	if self.cc.texture then
		local	mapWidth, mapHeight
		if type(self.cc.texture.getsize) == "function" then
			mapWidth, mapHeight = self.cc.texture:getsize()
		else
			mapWidth, mapHeight = self.cc.texture:getWidth(), self.cc.texture:getHeight()
		end
		local	xPos, yPos = pos.x, pos.y
		-- めんどいので、日本語非対応・・；
		local	len = string.len(charMap)
		for i = 1, len do
			local	char = string.sub(charMap, i, i)
			self.cc.charTextureRects[char] = love.graphics.newQuad(xPos, yPos, self.cc.itemWidth, self.cc.itemHeight, mapWidth, mapHeight)
			xPos = xPos + self.cc.itemWidth
			if xPos > mapWidth then
				xPos = 0
				yPos = yPos + self.cc.itemHeight
				if yPos > mapHeight then
					break
				end
			end
		end
	end
end


function TextAtlas:setStringValue(
	stringValue
	)
	self.cc.stringValue = stringValue
	local	len = string.len(self.cc.stringValue)
	self:setContentSize(cc.size(self.cc.itemWidth * len + self.cc.gap * (len - 1), self.cc.itemHeight))
end


function TextAtlas:draw(offset)
	
	if self.cc.texture then
		local	r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(self.cc.color.r or 1, self.cc.color.g or 1, self.cc.color.b or 1, self.cc.opacity or 1)
--		love.graphics.setColor(self.cc.color.r or 255, self.cc.color.g or 255, self.cc.color.b or 255, self.cc.opacity or 255)
		
		local	drawSpace = self:getDrawSpace(offset)
		local	xPos, yPos = drawSpace.x, drawSpace.y
		
		-- めんどいので、日本語非対応・・；
		local	len = string.len(self.cc.stringValue)
		for i = 1, len do
			local	char = string.sub(self.cc.stringValue, i, i)
			local	textureRect = self.cc.charTextureRects[char]
			
			if textureRect then
				love.graphics.draw(
					self.cc.texture,
					textureRect,
					math.floor(xPos),
					math.floor(yPos)
				)
--				self.cc.texture:drawrect(
--					xPos,
--					yPos,
--					self.cc.itemWidth,
--					self.cc.itemHeight,
--					textureRect.x,
--					textureRect.y,
--					255
--				)
			end
			
			xPos = xPos + self.cc.itemWidth + self.cc.gap
		end
		love.graphics.setColor(r, g, b, a)
	end
	
	
	Node.draw(self, offset)
end

return TextAtlas