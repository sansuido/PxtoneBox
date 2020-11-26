--
-- cc.Node -> ccui.Layout
--

local	Bump = import("..lib.bump")
local	Sprite = import("..cc.Sprite")
local	Node = import("..cc.Node")
local	Layout = {}
Layout = class("ccui.Layout", Node)


function Layout:ctor(...)
	Node.ctor(self, ...)
	--self.cc = self.cc or {}
	self.cc.backGroundColorType = ccui.LayoutBackGroundColorType.none
	self.cc.backGroundColor = cc.c3b(1, 1, 1)
--	self.cc.backGroundColor = cc.c3b(255, 255, 255)
	
	-- とりあえずはゼロ
	self.cc.clippingType = 0
	
	self.cc.bumpWorld = Bump.newWorld()
	
--	self:createCanvas()
end


function Layout:getClippingType()
	return self.cc.clippingType
end


function Layout:setClippingType(
	clippingType
	)
	self.cc.clippingType = clippingType
end


function Layout:setBackGroundColorType(
	backGroundColorType
	)
	self.cc.backGroundColorType = backGroundColorType
end


function Layout:setBackGroundColor(
	backGroundColor
	)
	self.cc.backGroundColor = backGroundColor
end


function Layout:setBackGroundImage(
	fileName
	)
	
	local	image = self:getChildByName("image")
	
	if image == nil then
		image = Sprite:create()
		image:setName("image")
		self:addChild(image)
	end
	if image then
		image:initWithFile(fileName)
		image:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5)
	end
end


function Layout:draw(offset)
	if self.cc.backGroundColorType ~= ccui.LayoutBackGroundColorType.none then
		
		local	backupColor = { love.graphics.getColor() }
		
		love.graphics.setColor(self.cc.backGroundColor.r, self.cc.backGroundColor.g, self.cc.backGroundColor.b, self.cc.backGroundColor.a)
		
		local	mode = {
			"line",
			"fill"
		}
		local	drawSpace = self:getDrawSpace(offset)
		local	x, y = drawSpace.x, drawSpace.y
		local	width, height = self:getContentSize().width, self:getContentSize().height
		
		if type(love.graphics.polygon) == "function" then
			love.graphics.polygon(
				mode[self.cc.backGroundColorType],
				x, y,
				x + width, y,
				x + width, y + height,
				x, y + height
			)
		end
		love.graphics.setColor(unpack(backupColor))
	end
	
	Node.draw(self, offset)
end


return Layout