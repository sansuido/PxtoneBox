
local	ScrollView = import(".ScrollView")


local	ListView = {}
ListView = class("ccui.ListView", ScrollView)

function ListView:ctor(...)
	
	ScrollView.ctor(self, ...)
	
	--self.cc = self.cc or {}
	self.cc.direction = nil
	self.cc.bounceEnabled = false
	self.cc.backGroundImage = nil
	
	-- コンテナ用レイアウトを用意
--	self.cc.innerContainer = self:addChild(Layout:create())
	self.cc.items = {}
	
	self.cc.clippingType = 1
end


--function ListView:getInnerContainer()
--	return self.cc.innerContainer
--end
--
--
--function ListView:setInnerContainerSize(
--	size
--	)
--	self:getInnerContainer():setContentSize(size)
--end
--
--
--function ListView:getInnerContainerSize()
--	return self:getInnerContainer():getContentSize()
--end
--
--
--function ListView:jumpToBottom()
--	local	size = self:getContentSize()
--	local	innerSize = self:getInnerContainerSize()
--	if innerSize.height > size.height then
--		self:getInnerContainer():setPosition(self:getInnerContainer():getPosition().x, size.height - innerSize.height)
--	end
--end
--
--function ListView:jumpToTop()
--	self:getInnerContainer():setPosition(self:getInnerContainer():getPosition().x, 0)
--end
--
--function ListView:jumpToLeft()
--	self:getInnerContainer():setPosition(0, self:getInnerContainer():getPosition().y)
--end
--
--function ListView:jumpToRight()
--	local	size = self:getContentSize()
--	local	innerSize = self:getInnerContainerSize()
--	if innerSize.width > size.width then
--		self:getInnerContainer():setPosition(size.widh - innerSize.width, self:getInnerContainer():getPosition().y)
--	end
--end
--
--function ListView:jumpToTopLeft()
--	self:jumpToLeft()
--	self:jumpToTop()
--end
--
--function ListView:jumpToTopRight()
--	self:jumpToRight()
--	self:jumpToTop()
--end
--
--function ListView:jumpToBottomLeft()
--	self:jumpToLeft()
--	self:jumpToBottom()
--end
--
--function ListView:jumpToBottomRight()
--	self:jumpToRight()
--	self:jumpToBottom()
--end
--
--function ListView:jumpToPercentVertical(
--	percent
--	)
--	local	size = self:getContentSize()
--	local	innerSize = self:getInnerContainerSize()
--	if innerSize.height > size.height then
--		self:getInnerContainer():setPosition(self:getInnerContainer():getPosition().x, (size.height - innerSize.height) * percent)
--	else
--		self:getInnerContainer():setPosition(self:getInnerContainer():getPosition().x, 0)
--	end
--end
--
--function ListView:jumpToPercentHorizontal(
--	percent
--	)
--	local	size = self:getContentSize()
--	local	innerSize = self:getInnerContainerSize()
--	if innerSize.width > size.width then
--		self:getInnerContainer():setPosition((size.width - innerSize.width) * percent, self:getInnerContainer():getPosition().y)
--	else
--		self:getInnerContainer():setPosition(0, self:getInnerContainer():getPosition().y)
--	end
--end
--
--function ListView:jumpToPercentBothDirection(
--	percent
--	)
--	self:jumpToPercentVertical(percent.x)
--	self:jumpToPercentHorizontal(percent.y)
--end

function ListView:refreshView()
	-- リフレッシュ
	local	position = cc.p(0, 0)
	for i, item in ipairs(self.cc.items) do
		local	itemSize = item:getContentSize()
		-- 自動でタグを付加しておく
		item:setTag(i)
		item:setPosition(position.x, position.y)
		position.y = position.y + itemSize.height
		-- リサイズ
		if self:getInnerContainer():getContentSize().width < itemSize.width then
			self:getInnerContainer():setContentSize(cc.size(itemSize.width, self:getInnerContainer():getContentSize().height))
		end
		if self:getInnerContainer():getContentSize().height < position.y then
			self:getInnerContainer():setContentSize(cc.size(self:getInnerContainer():getContentSize().width, position.y))
		end
	end
end


function ListView:pushBackCustomItem(item)
	table.insert(self.cc.items, item)
	self:getInnerContainer():addChild(item)
	self:refreshView()
end


function ListView:removeItem(index)
	table.remove(self.cc.items, index)
	self:removeChildByTag(index)
	self:refreshView()
end


function ListView:insertCustomItem(item, index)
	table.insert(self.cc.items, index)
	self:removeChildByTag(index)
	self:refreshView()
end


function ListView:removeLastItem()
	local	index = #self.cc.items
	table.remove(self.cc.items)
	self:removeChildByTag(index)
	self:refreshView()
end


function ListView:removeAllItems()
	self.cc.items = {}
	self:getInnerContainer():removeAllChildren()
	self:getInnerContainer():cleanup()
	self:getInnerContainer():setContentSize(cc.size(self:getInnerContainer():getContentSize().width, 0))
	self:refreshView()
end

function ListView:getItem(index)
	return self.cc.items[index]
end


function ListView:getItems()
	return self.cc.items
end


return ListView
