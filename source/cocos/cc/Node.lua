-- 疑似ノード

local	Bump = import("..lib.bump")

local	Node = {}
Node = class("cc.Node")


function Node:ctor()
	-- 基本情報を構築
	self.cc.parent = nil
	self.cc.director = nil
	self.cc.scene = nil
	self.cc.visible = true
	self.cc.tag = nil
	self.cc.name = nil
	self.cc.x = 0
	self.cc.y = 0
	self.cc.anchorPoint = cc.p(0, 0)
	self.cc.contentSize = cc.size(0, 0)
	self.cc.eventMouseListener = nil
	self.cc.localZOrder = 0
	self.cc.rowid = 0
	
	self.cc.running = false
	
	self.cc.drawOrder = 0
	self.cc.drawSpace = cc.p(0, 0)
	self.cc.shader = nil
	
	self.cc.batchEnabled = false
	
	
	self.cc.color = cc.c3b(1, 1, 1)
--	self.cc.color = cc.c3b(255, 255, 255)
	self.cc.opacity = 1
--	self.cc.opacity = 255
	
	self.cc.debugDraw = false
	
	self.cc.canvas = nil
	self.cc.drawRequest = false
	self.cc.drawOnce = false
	
--	self.cc.bumpWorld = Bump.newWorld()
	
	-- 登録情報
	self.cc.entries = {}
	
	self.cc.children = {}
	self.cc.rowidForChildren = 0
end


function Node:setShader(shader)
	self.cc.shader = shader
end


function Node:getShader()
	return self.cc.shader
end


function Node:isVisible()
	local	visible = self.cc.visible
	local	node = self.cc.parent
	while visible == true and node do
		visible = node.cc.visible
		node = node.cc.parent
	end
	return visible
end


function Node:setDrawOnce(drawOnce)
	self.cc.drawOnce = drawOnce
	self.cc.drawRequest = true
end


--function Node:createCanvas()
--	self.cc.canvas = self:getDirector().cc.canvasPoolManager:createCanvas(self)
--	self.cc.drawRequest = true
--end


--function Node:createCanvas()
--	local	director = self:getDirector()
--	if director then
--		self.cc.canvas = director:createCanvas()
--		self.cc.drawRequest = true
--	end
--end


function Node:setDrawRequest(drawRequest)
	drawRequest = drawRequest or true
	self.cc.drawRequest = drawRequest
end


function Node:getDrawRequest()
	local	node = self
	while node do
		if node.cc.drawRequest then return true end
		node = node.cc.parent
	end
	return false
end


function Node:setVisible(
	visible
	)
	self.cc.visible = visible
end


function Node:getLocalZOrder()
	return self.cc.localZOrder
end


function Node:setLocalZOrder(
	localZOrder
	)
--	if self:getParent() then
--		-- 再オーダーを要求（仮）
--		self:getParent().cc.reorder = true
--	end
	
	self:setDrawRequest()
	
	self.cc.localZOrder = localZOrder
end


function Node:setName(name)
	self.cc.name = name
end


function Node:getName()
	return self.cc.name
end


function Node:setTag(tag)
	self.cc.tag = tag
end


function Node:getTag()
	return self.cc.tag
end


function Node:getParent()
	return self.cc.parent
end


function Node:getContentSize()
	return self.cc.contentSize
end


function Node:bumpBoundingBox(offset)
	offset = offset or cc.p(0, 0)
	local	lt = cc.pSub(self:getPosition(), self:getAnchorPointInPoints())
	return lt.x + offset.x, lt.y + offset.y, math.max(self:getContentSize().width, 1), math.max(self:getContentSize().height, 1)
end


function Node:bumpUpdate()
	if self:getParent() and self:getParent().cc.bumpWorld then
		if self.cc.bumpAdd ~= true then
			self:getParent().cc.bumpWorld:add(self, self:bumpBoundingBox())
			self:getDirector():addCounter("bumpEnter")
			self.cc.bumpAdd = true
		else
			self:getParent().cc.bumpWorld:update(self, self:bumpBoundingBox())
		end
	end
end


function Node:bumpRemove()
	if self:getParent() and self:getParent().cc.bumpWorld then
		if self.cc.bumpAdd == true then
			self:getParent().cc.bumpWorld:remove(self)
			self:getDirector():addCounter("bumpExit")
			self.cc.bumpAdd = false
		end
	end
end


function Node:setContentSize(contentSize)
	self.cc.contentSize = contentSize
	self:bumpUpdate()
--	if self:getParent() and self:getParent().cc.bumpWorld then
--		self:getParent().cc.bumpWorld:update(self, self:bumpBoundingBox())
--	end
end


function Node:setPosition(x, y)
	if type(x) == "number" then
		self.cc.x = x
		self.cc.y = y
	elseif type(x) == "table" then
		self.cc.x = x.x
		self.cc.y = x.y
	end
	
	self:bumpUpdate()
--	if self:getParent() and self:getParent().cc.bumpWorld then
--		self:getParent().cc.bumpWorld:update(self, self:bumpBoundingBox())
--	end
	
	self:setDrawRequest()
end


function Node:getPosition()
	return cc.p(self.cc.x, self.cc.y)
end



function Node:getPositionX()
	return self.cc.x
end

function Node:getPositionY()
	return self.cc.y
end


function Node:setAnchorPoint(
	anchorPoint
	)
	self.cc.anchorPoint = anchorPoint
end


function Node:getAnchorPoint()
	return self.cc.anchorPoint
end


function Node:cleanup()
	local	director = self:getDirector()
	if director then
		director:cleanup(self)
	end
end


function Node:getAnchorPointInPoints()
	-- アンカーポイントの加算値をpixelに変換
	local	contentSize = self:getContentSize()
	local	anchorPoint = self:getAnchorPoint()
	return cc.p(contentSize.width * anchorPoint.x, contentSize.height * anchorPoint.y)
end


function Node:convertToWorldSpace(
	-- ワールド座標に変換（左上座標）
	point
	)
	point = point or cc.p(0, 0)
	
	local	node = self
	while node do
		local	lt = cc.pSub(node:getPosition(), node:getAnchorPointInPoints())
		point = cc.p(point.x + lt.x, point.y + lt.y)
		node = node:getParent()
	end
	return point
end


function Node:convertToWorldSpaceAR(
	-- ワールド座標に変換（アンカーポイントに従う）
	point
	)
	point = point or cc.p(0, 0)
	local	apip = self:getAnchorPointInPoints()
	return self:convertToWorldSpace(cc.p(apip.x + point.x, apip.y + point.y))
end


function Node:convertToNodeSpace(
	-- ローカル座標に変換（左上）
	point
	)
	point = point or cc.p(0, 0)
	
	local	node = self
	while node do
		local	lt = cc.pSub(node:getPosition(), node:getAnchorPointInPoints())
		point = cc.p(point.x - lt.x, point.y - lt.y)
		node = node:getParent()
	end
	return point
end


function Node:convertToNodeSpaceAR(
	-- ローカル座標に変換（アンカーポイントに従う）
	point
	)
	point = point or cc.p(0, 0)
	local	apip = self:getAnchorPointInPoints()
	return self:convertToNodeSpace(cc.p(-apip.x + point.x, -apip.y + point.y))
end


function Node:getBoundingBox(calc)
	local	lt = self:convertToWorldSpace(cc.p(0, 0))
	calc = calc or cc.p(0, 0)
	local	contentSize = self:getContentSize()
	-- 重複しないように-1してみた……
	return cc.rect(lt.x, lt.y, contentSize.width + calc.x, contentSize.height + calc.y)
	-- 記述ミス？の可能性があるので上に変更
--	return cc.rect(lt.x, lt.y, contentSize.width - calc.x, contentSize.height - calc.y)
end


function Node:getDrawSpace(p)
	-- 描画位置を取得（drawとかで使用）
	p = p or cc.p(0, 0)
	return cc.pAdd(self.cc.drawSpace, p)
end


function Node:getDrawRect(p)
	local	drawSpace = self:getDrawSpace(p)
	return cc.rect(drawSpace.x, drawSpace.y, self:getContentSize().width, self:getContentSize().height)
end


function Node:getWorldDrawableArea()
	-- ステンシル描画エリアを取得
	local	selfDrawArea = self:getBoundingBox()
	local	node = self:getParent()
	local	director = node:getDirector()
	while node do
		if node == director then break end
		local	nodeDrawArea = node:getBoundingBox()
		selfDrawArea = cc.rectIntersection(selfDrawArea, nodeDrawArea)
		if selfDrawArea.width < 0 or selfDrawArea.height < 0 then break end
		node = node:getParent()
	end
	return selfDrawArea
end

function Node:getWorldDrawableAreaPrint()
	-- ステンシル描画エリアを取得
	local	selfDrawArea = self:getBoundingBox()
	local	node = self:getParent()
	local	director = node:getDirector()
	while node do
		if node == director then break end
		local	nodeDrawArea = node:getBoundingBox()

		print("SELF", self.cc.name or "", selfDrawArea.x, selfDrawArea.y, selfDrawArea.width, selfDrawArea.height)
		print("NODE", node.cc.name or "", nodeDrawArea.x, nodeDrawArea.y, nodeDrawArea.width, nodeDrawArea.height)

		selfDrawArea = cc.rectIntersection(selfDrawArea, nodeDrawArea)
		if selfDrawArea.width < 0 or selfDrawArea.height < 0 then break end
		node = node:getParent()
	end
	return selfDrawArea
end



function Node:getNodeDrawableArea()
	local	drawArea = self:getWorldDrawableArea()
	local	nodeSpace = self:convertToNodeSpace(cc.p(drawArea.x, drawArea.y))
	drawArea.x = nodeSpace.x
	drawArea.y = nodeSpace.y
	return drawArea
end


function Node:getDrawOrder()
	-- 描画順を取得（マウスの前後関係とかで使用）
	return self.cc.drawOrder
end


function Node:getDirector()
	-- なければさがしちゃうっ
	if self.cc.director == nil then
		local	node = self.cc.parent
		while node do
			self.cc.director = node.cc.director
			if self.cc.director then break end
			node = node.cc.parent
		end
	end
	return self.cc.director or cc.Director:getInstance()
end


function Node:getScene()
	-- なければさがしちゃうっ
	if self.cc.scene == nil then
		local	node = self.cc.parent
		while node do
			self.cc.scene = node.cc.scene
			if self.cc.scene then break end
			node = node.cc.parent
		end
	end
	
--	if self.cc.scene == nil and self:getDirector() then
--		self.cc.scene = self:getDirector():getRunScene()
--	end
	
	return self.cc.scene
end


function Node:onEnter() end
function Node:onExit() end
function Node:update() end


function Node:addTo(parent)
	parent:addChild(self)
end


function Node:getChildren()
	-- 子要素をがっと取得
	return self.cc.children
end


function Node:getChildrenCount()
	-- 子要素の数を取得
	return #self.cc.children
end


function Node:addEntries(
	mode,
	entry
	)
	
	table.insert(
		self.cc.entries,
		{
			mode,
			entry
		}
	)
end


function Node:registerEntries()
	if self:getScene() and #self.cc.entries > 0 then
		
		for i, entry in ipairs(self.cc.entries) do
			if entry[1] == "schedule" then
				self:getScene():registerSchedule(self, entry[2])
			elseif entry[1] == "event" then
				if iskindof(entry[2], "cc.EventMouse") then
					self:getScene():registerEventMouseListener(self, entry[2])
				elseif iskindof(entry[2], "cc.EventKeyboard") then
					self:getScene():registerEventKeyboardListener(self, entry[2])
				end
			end
		end
		self.cc.entries = {}
	end
end


function Node:scheduleUpdate(schedule)
	schedule = schedule or self.update
	self:addEntries("schedule", schedule)
end


function Node:addEventListener(
	event
	)
	
	self:addEntries("event", event)
end


function Node:isHover(
	-- ホバー状態かどうか（仮）
	location
	)
	local	parent = self:getParent()
	if parent == nil then return true end
	if cc.rectContainsPoint(self:getBoundingBox(cc.p(-1, -1)), location) == false then return false end
	local	children = parent:getChildren()
	for i = #children, 1, -1 do
		local	node = children[i]
		if node == self then
			-- 親がホバーかを検証
			return parent:isHover(location)
		elseif node:isVisible() then
			local	boundingBox = node:getBoundingBox(cc.p(-1, -1))
			if cc.rectContainsPoint(boundingBox, location) then
				return false
			end
		end
	end
	return true
end


function Node:isLocalZOrderForeground(
	-- 親に対して最前面に居るか（仮）
	)
	local	parent = self:getParent()
	if parent then
		local	children = parent:getChildren()
		for i = #children, 1, -1 do
			local	node = children[i]
			if node:isVisible() then
				return self == node
			end
		end
	end
end


function Node:setLocalZOrderForeground(
	-- 最前面に移動（仮）
	)
	if self:isLocalZOrderForeground() ~= true then
		if self:getParent() then
			local	children = self:getParent():getChildren()
			local	localZOrder = 0
			for i, child in ipairs(children) do
				if child:getLocalZOrder() > localZOrder then
					localZOrder = child:getLocalZOrder()
				end
			end
			self:setLocalZOrder(localZOrder + 1)
		end
	end
end


function Node:removeFromParent()
	-- 自身を親から取り除く
	self:getParent():removeChild(self)
end


function Node:removeChildByTag(
	-- タグ付けたのを削除
	tag
	)
	local	child = self:getChildByTag(tag)
	if child then self:removeChild(child) end
end


function Node:removeChildByName(
	-- 名前付けたのを削除
	name
	)
	local	child = self:getChildByName(name)
	if child then self:removeChild(child) end
end


function Node:removeAllChildren()
	-- すべて削除
	local	children = self:getChildren()
	for i, child in ipairs(children) do
		self:removeChild(child)
	end
end


function Node:draw(offset)
	if (self:getDirector() and self:getDirector():getDebugDraw()) or self.cc.debugDraw then
		-- デバッグ描画
		local	drawSpace = self:getDrawSpace(offset)
		local	x, y = drawSpace.x, drawSpace.y
		local	width, height = self:getContentSize().width, self:getContentSize().height
		
		love.graphics.polygon(
			"line",
			x, y,
			x + width, y,
			x + width, y + height,
			x, y + height
		)
	end
end

function Node:getActionManager()
	if self.cc.actionManager then
		return self.cc.actionManager
	else
		local	director = self:getDirector()
		if director then
			self.cc.actionManager = director.cc.actionManager
			return director.cc.actionManager
		end
	end
end


function Node:runAction(action)
	-- アクションを動かす
	local	actionManager = self:getActionManager()
	if actionManager then
		actionManager:addAction(action, self, not(self.cc.running))
	end
end


function Node:stopAction(action)
	-- アクションを止める
	local	actionManager = self:getActionManager()
	if actionManager then
		actionManager:removeAction(action)
	end
end


function Node:stopAllActions()
	local	actionManager = self:getActionManager()
	if actionManager then
		actionManager:removeAllActionsFromTarget(self)
	end
end


function Node:stopActionByTag(tag)
	local	actionManager = self:getActionManager()
	if actionManager then
		actionManager:removeActionByTag(tag, self)
	end
end


function Node:redume()
	self:bumpUpdate()
--	if self:getParent() and self:getParent().cc.bumpWorld then
--		self:getParent().cc.bumpWorld:update(self, self:bumpBoundingBox())
--	end
	-- 起こす
	local	actionManager = self:getActionManager()
	if actionManager then
		actionManager:resumeTarget(self)
	end
end


function Node:setColor(color)
	self.cc.color = cc.c3b(color.r, color.g, color.b)
	if color.a and color.a ~= 1 then
--	if color.a and color.a ~= 255 then
		self.cc.opacity = color.a
	end
end


function Node:getColor()
	return cc.c4b(self.cc.color.r, self.cc.color.g, self.cc.color.b, self.cc.opacity)
end


function Node:getOpacity()
	return self.cc.opacity
end


function Node:setOpacity(opacity)
	self.cc.opacity = opacity
end


function Node:addChild(child)
	child.cc.parent = self
	self.cc.rowidForChildren = self.cc.rowidForChildren + 1
	child.cc.rowid = self.cc.rowidForChildren
	table.insert(self:getDirector().cc.add, child)
	child:bumpUpdate()
	return child
end


function Node:removeChild(child)
	table.insert(self:getDirector().cc.remove, child)
	child:bumpRemove()
	if child.cc.canvas then
		child:getDirector().cc.canvasPoolManager:removeCanvas(child.cc.canvas)
		child.cc.canvas = nil

--		child.cc.canvas:release()
--		child.cc.canvas = nil
	end
end


local	children_comp = function(a, b)
	if a.cc.localZOrder ~=  b.cc.localZOrder then
		return a.cc.localZOrder < b.cc.localZOrder
	end
	return a.cc.rowid < b.cc.rowid
end


function Node:getChildByTag(tag)
	-- タグ付けたやつをゲット
	for i, child in ipairs(self:getChildren()) do
		if child.cc.tag and child.cc.tag == tag then
			return child
		end
	end
end


function Node:getChildByName(
	-- 名前付けたやつをゲット
	name
	)
	for i, child in ipairs(self:getChildren()) do
		if child.cc.name and child.cc.name == name then
			return child
		end
	end
end




---- 描画（内部処理）
--function Node:_onDrawExecute(drawSpace, drawOrder)
--	
--	local	rectIntersectsRect = function( rect1, rect2 )
--		local intersect = not ( rect1.x >= rect2.x + rect2.width or
--			rect1.x + rect1.width <= rect2.x         or
--			rect1.y >= rect2.y + rect2.height        or
--			rect1.y + rect1.height <= rect2.y )
--		return intersect
--	end
--	
--	if self:isVisible() == true and self.cc.batchEnabled == false then
--		drawOrder = drawOrder + 1
--		self.cc.drawOrder = drawOrder
--		local	lt = cc.pSub(self:getPosition(), self:getAnchorPointInPoints())
--		self.cc.drawSpace = cc.pAdd(drawSpace, lt)
--		self.cc.clippingFlag = false
--		if self.cc.clippingType == 1 then
--			local	drawableArea = self:getWorldDrawableArea()
--			if drawableArea.width > 0 and drawableArea.height > 0 then
--				self:getDirector():pushScissor(drawableArea)
--				self.cc.clippingFlag = true
--			end
--		end
--		if self.cc.shader then
--			self:getDirector():pushShader(self.cc.shader)
--		end
--		
--		
--		
--		
--		if type(self.draw) == "function" and rectIntersectsRect(self:getDrawRect(), self:getDirector():getDrawRect()) then
--			self.draw(self)
--		end
--		if self.cc.shader then
--			self:getDirector():popShader()
--		end
--		if self.cc.clippingFlag == true then
--			self:getDirector():popScissor()
--		end
--	end
--	return drawOrder
--end


function Node:onDraw(drawOrder, drawSpace)
	drawOrder = drawOrder or 0
	drawSpace = drawSpace or cc.p(0, 0)
	
	local	rectIntersectsRect = function( rect1, rect2 )
		local intersect = not ( rect1.x >= rect2.x + rect2.width or
			rect1.x + rect1.width <= rect2.x         or
			rect1.y >= rect2.y + rect2.height        or
			rect1.y + rect1.height <= rect2.y )
		return intersect
	end
	
	local	drawing = false
	if self.cc.canvas then
		self:getDirector():pushCanvas(self.cc.canvas)
		if self.cc.drawOnce == false or self:getDrawRequest() then
			love.graphics.clear()
			drawing = true
		end
	else
		drawing = true
	end
	if drawing then
		if self.cc.drawRequest and type(self.onReorder) == "function" then
			self:cleanup()
			self:onReorder()
		end
		
		if self:isVisible() == true and self.cc.batchEnabled == false then
			drawOrder = drawOrder + 1
			self.cc.drawOrder = drawOrder
			local	lt = cc.pSub(self:getPosition(), self:getAnchorPointInPoints())
			self.cc.drawSpace = cc.pAdd(drawSpace, lt)
			
			self.cc.clippingFlag = false
			if self.cc.clippingType == 1 then
				local	drawableArea = self:getWorldDrawableArea()
				if drawableArea.width > 0 and drawableArea.height > 0 then
					self:getDirector():pushScissor(drawableArea)
					self.cc.clippingFlag = true
				end
			end
			
			if self:getDirector().draw ~= self.draw	then
				if type(self.draw) == "function" and rectIntersectsRect(self:getDrawRect(), self:getDirector():getDrawRect()) then
					self.draw(self)
				end
			end
			
			local	children = self:getChildren()
			if self.cc.bumpWorld and self:getParent() then
				-- ここがおかしいかも
				local	camera = self:getNodeDrawableArea()
				children = self.cc.bumpWorld:queryRect(camera.x, camera.y, camera.width, camera.height)
				table.sort(children, children_comp)
			else
				children = self:getChildren()
			end
			
			for i, child in ipairs(children) do
				drawOrder = child:onDraw(drawOrder, self.cc.drawSpace)
			end
			
			if self.cc.shader then
				self:getDirector():popShader()
			end
			if self.cc.clippingFlag == true then
				self:getDirector():popScissor()
			end
		end
	end
	if self.cc.canvas then
		self:getDirector():popCanvas()
		self:canvasDraw()
	end
	if self.cc.drawRequest then
		self.cc.drawRequest = false
	end
	return drawOrder
end


function Node:canvasDraw()
	love.graphics.draw(self.cc.canvas)
end
-- ベースの描画を開始
-- ベースが描画必要かどうか？
-- １．描画必要→子要素を開始
-- ２．描画不要→スキップ





return Node
