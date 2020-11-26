
local	Bump = import("..lib.bump")
local	Layout = import(".Layout")


local	ScrollView = {}
ScrollView = class("ccui.ScrollView", Layout)

function ScrollView:ctor(...)
	
	Layout.ctor(self, ...)
	
	-- コンテナ用レイアウトを用意
	--self.cc = self.cc or {}
	self.cc.innerContainer = Layout.addChild(self, Layout:create())
	
	-- 保留中
--	self.cc.innerContainer.cc.bumpWorld = Bump.newWorld()
	
	self.cc.clippingType = 1
end


function ScrollView:addChild(widget)
	self.cc.innerContainer:addChild(widget)
end


function ScrollView:getInnerContainer()
	return self.cc.innerContainer
end


function ScrollView:setInnerContainerSize(size)
	self:getInnerContainer():setContentSize(size)
end


function ScrollView:getInnerContainerSize()
	return self:getInnerContainer():getContentSize()
end


function ScrollView:jumpToBottom()
	local	size = self:getContentSize()
	local	innerSize = self:getInnerContainerSize()
	if innerSize.height > size.height then
		self:getInnerContainer():setPosition(self:getInnerContainer():getPosition().x, size.height - innerSize.height)
	end
	self:setDrawRequest()
end


function ScrollView:jumpToTop()
	self:getInnerContainer():setPosition(self:getInnerContainer():getPosition().x, 0)
	self:setDrawRequest()
end


function ScrollView:jumpToLeft()
	self:getInnerContainer():setPosition(0, self:getInnerContainer():getPosition().y)
	self:setDrawRequest()
end


function ScrollView:jumpToRight()
	local	size = self:getContentSize()
	local	innerSize = self:getInnerContainerSize()
	if innerSize.width > size.width then
		self:getInnerContainer():setPosition(size.width - innerSize.width, self:getInnerContainer():getPosition().y)
		self:setDrawRequest()
	end
end


function ScrollView:jumpToTopLeft()
	self:jumpToLeft()
	self:jumpToTop()
end


function ScrollView:jumpToTopRight()
	self:jumpToRight()
	self:jumpToTop()
end


function ScrollView:jumpToBottomLeft()
	self:jumpToLeft()
	self:jumpToBottom()
end


function ScrollView:jumpToBottomRight()
	self:jumpToRight()
	self:jumpToBottom()
end


function ScrollView:jumpToPercentVertical(percent)
	if percent > 1 then percent = 1 end
	if percent < 0 then percent = 0 end
	
	local	size = self:getContentSize()
	local	innerSize = self:getInnerContainerSize()
	if innerSize.height > size.height then
		self:getInnerContainer():setPosition(self:getInnerContainer():getPosition().x, (size.height - innerSize.height) * percent)
	else
		self:getInnerContainer():setPosition(self:getInnerContainer():getPosition().x, 0)
	end
	self:setDrawRequest()
end


function ScrollView:jumpToPercentHorizontal(percent)
	if percent > 1 then percent = 1 end
	if percent < 0 then percent = 0 end
	
	local	size = self:getContentSize()
	local	innerSize = self:getInnerContainerSize()
	if innerSize.width > size.width then
		self:getInnerContainer():setPosition((size.width - innerSize.width) * percent, self:getInnerContainer():getPosition().y)
	else
		self:getInnerContainer():setPosition(0, self:getInnerContainer():getPosition().y)
	end
	self:setDrawRequest()
end


function ScrollView:jumpToPercentBothDirection(percent)
	self:jumpToPercentVertical(percent.y)
	self:jumpToPercentHorizontal(percent.x)
end


function ScrollView:getSizePercent()
	local	percent = cc.size(0, 0)
	local	size = self:getContentSize()
	local	innerSize = self:getInnerContainerSize()
	if innerSize.width >= size.width then
		percent.width = size.width / innerSize.width
	end
	if innerSize.height >= size.height then
		percent.height = size.height / innerSize.height
	end
	return percent
end


function ScrollView:getPositionPercent()
	local	percent = cc.p(0, 0)
	local	size = self:getContentSize()
	local	innerSize = self:getInnerContainerSize()
	local	innerPos = self:getInnerContainer():getPosition()
	
	if innerSize.width >= size.width then
		local	width = size.width - innerSize.width
		percent.x = innerPos.x / width
	end
	if innerSize.height >= size.height then
		local	height = size.height - innerSize.height
		percent.y = innerPos.y / height
	end
	percent.x = math.min(percent.x, 1)
	percent.x = math.max(percent.x, 0)
	percent.y = math.min(percent.y, 1)
	percent.y = math.max(percent.y, 0)
	return percent
end


function ScrollView:getCamera()
	local	percent = self:getPositionPercent()
	local	size = self:getContentSize()
	local	innerSize = self:getInnerContainerSize()
	local	camera = cc.rect((innerSize.width - size.width) * percent.x, (innerSize.height - size.height) * percent.y, size.width, size.height)
	return camera
end


function ScrollView:setInnerContainerPosition(pos)
	self:getInnerContainer():setPosition(pos)
	self:setDrawRequest()
end


function ScrollView:getInnerContainerPosition()
	return self:getInnerContainer():getPosition()
end


function ScrollView:_clampNumber(v, min, max)
	if max < min then return 0 end -- this happens when viewport is bigger than boundary
	return v < min and min or (v > max and max or v)
end


function ScrollView:_clampCamera(viewport)
	local	viewportSize = self:getContentSize()
	local	boundarySize = self:getInnerContainerSize()
	local	boundaryPosition = cc.p(0, 0)
	viewport.x = self:_clampNumber(viewport.x, boundaryPosition.x, boundaryPosition.x + boundarySize.width  - viewportSize.width )
	viewport.y = self:_clampNumber(viewport.y, boundaryPosition.y, boundaryPosition.y + boundarySize.height - viewportSize.height)
end


function ScrollView:lookAt(x, y)
	local	viewportSize = self:getContentSize()
	local	viewport = cc.p(math.floor(x - viewportSize.width * 0.5), math.floor(y -  viewportSize.height * 0.5))
	self:_clampCamera(viewport)
	self:setInnerContainerPosition(cc.p(-viewport.x, -viewport.y))
end


function ScrollView:getViewport()
	local	pos = self:getInnerContainerPosition()
	local	rect = cc.rect(-pos.x, -pos.y, self:getContentSize().width, self:getContentSize().height)
	return rect
end


return ScrollView
