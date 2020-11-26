-- 疑似ディレクター・・・ちょっと強引につくっとる感じ

local	Node = import(".Node")
local	SourceManager = import(".SourceManager")
local	ActionManager = import(".ActionManager")
local	AnimationCache = import(".AnimationCache")
local	CanvasPoolManager = import(".CanvasPoolManager")

local	Director = {}
Director = class("cc.Director", Node)

Director.cc = Director.cc or {}
Director.cc.instance = nil

function Director:ctor(width, height, ...)
	Node.ctor(self, width, height, ...)
	
	width  = width  or love.graphics.getWidth()
	height = height or love.graphics.getHeight()
	
	self:setContentSize(cc.size(width, height))

	self.cc.director = self
	self.cc.runScene = nil
	self.cc.debugDraw = false
	
	self.cc.add = {}
	self.cc.remove = {}
	
--	self.cc.stencilList = {}
	self.cc.scissorList = {}
	self.cc.canvasList = {}
	self.cc.shaderList = {}
	self.cc.colorList = {}
	
	self.cc.totalDrawOrder = 0
	
	-- ソースマネージャー
	self.cc.sourceManager = SourceManager:create()
	-- アクションマネージャー
	self.cc.actionManager = ActionManager:create()
	-- アニメーションキャッシュ
	self.cc.animationCache = AnimationCache:create()
	-- キャンバスプールマネージャー
	self.cc.canvasPoolManager = CanvasPoolManager:create(width, height)
	
	-- インスタンスを生成
	Director.cc.instance = self
	
	-- 初期は画面と同じ
--	self:setContentSize(cc.size(love.graphics.getWidth(), love.graphics.getHeight()))
	
	self.cc.counters = {}
	
	-- モバイルだったらフルスクリーンに挿げ替える処理（暫定）
	self:createCanvas()
	self:resize()
	if self:isMobile() then
		love.window.setFullscreen(true)
	end
end


function Director:createCanvas()
	self.cc.canvas = self.cc.canvasPoolManager:createCanvas(self)
	self.cc.drawRequest = true
end


function Director:addCounter(key, value)
	value = value or 1
	self.cc.counters[key] = self.cc.counters[key] or 0
	self.cc.counters[key] = self.cc.counters[key] + value
end
function Director:clearCounter(key)
	self.cc.counters[key] = 0
end
function Director:getCounter(key)
	return self.cc.counters[key] or 0
end
function Director:setCounter(key, value)
	self.cc.counters[key] = value
end

function Director:isMobile()
	-- モバイルかどうかの判定（仮）
	
	local	os = love.system.getOS()
	local	bl = false
	if os == "Android" or os == "iOS" then
		bl = true
	end
	return bl
end

--function Director:setContentSize(size)
--	
--	-- 外してみた
----	love.graphics.setDefaultFilter("nearest", "nearest")
--	if cc.application == "love2d" then
--		self.cc.contentSize = size
--	else
--		self.cc.contentSize = cc.size(love.graphics.getWidth(), love.graphics.getHeight())
--	end
--	self.cc.mainCanvas = love.graphics.newCanvas(size.width, size.height)
----	self.cc.canvas:setFilter("nearest", "nearest")
--	self:resize(size.width, size.height)
--end


function Director:getInstance(...)
	return self.cc.director or Director.cc.instance
end


function Director:loadSource(type, ...)
	return self.cc.sourceManager:loadSource(type, ...)
end


function Director:getAnimationCache()
	return self.cc.animationCache
end


function Director:getDebugDraw()
	return self.cc.debugDraw
end


function Director:setDebugDraw(
	debugDraw
	)
	self.cc.debugDraw = debugDraw
end


function Director:runWithScene(
	scene
	)
	self:addChild(scene)
	self.cc.runScene = scene
end


function Director:getRunScene()
	return self.cc.runScene
end


function Director:cleanup(parent_node)
	-- 削除処理
	do
		local	i, max = 1, #self.cc.remove
		while i <= max do
			child = self.cc.remove[i]
			
			local	parent = child:getParent()
			if parent_node == nil or parent_node == parent then
				if type(child.onExit) == "function" then
					child:onExit()
				end
				-- 子要素削除処理
				child:stopAllActions()
				child:removeAllChildren()
				child:bumpRemove()
				-- 削除カウント（仮）
				self:addCounter("exit", 1)
--				cc.onExitCount = cc.onExitCount + 1
				-- 削除してあげる（仮）
				if child:getScene() then
					child:getScene():removeSchedule(child)
					child:getScene():removeEventMouseListener(child)
					child:getScene():removeEventKeyboardListener(child)
				end
				
				table.removebyvalue(parent:getChildren(), child)
				
				table.remove(self.cc.remove, i)
				max = max - 1
			else
				i = i + 1
			end
		end
	end
	-- 追加処理
	do
		local	i, max = 1, #self.cc.add
		while i <= max do
			local	child = self.cc.add[i]
			local	parent = child:getParent()
			if parent_node == nil or parent_node == parent then
				if type(child.onEnter) == "function" then
					-- 実行
					child:onEnter()
				end
				child:registerEntries()
				child.cc.running = true
				child:redume()
				-- 登録カウント（仮）
				self:addCounter("enter")
				child:registerEntries()
				table.insert(parent:getChildren(), child)
				
				table.remove(self.cc.add, i)
				max = max - 1
			else
				i = i + 1
			end
		end
	end
end


function Director:update(dt)
	
	self:cleanup()
	
	if self.cc.actionManager then
		self.cc.actionManager:update(dt)
	end
	
	if self.cc.runScene then
		self.cc.runScene:onUpdate(dt)
	end
end


function Director:draw()
	self.cc.canvasList = {}
	self.cc.drawCanvasList = {}
--	self.cc.stencilList = {}
	self.cc.scissorList = {}
	self.cc.shaderList = {}
	self.cc.colorList = {}
	
--	self:pushCanvas(self.cc.canvas)
--		love.graphics.clear()

		local	count = self:onDraw()
		
		self:setCounter("draw", count)
--	self:popCanvas()

--	for i, canvas in ipairs(self.cc.drawCanvasList) do
--		love.graphics.draw(self.cc.drawCanvasList[i], self.cc.offset.x, self.cc.offset.y, 0, self.cc.scaler, self.cc.scaler)
--	end
--	love.graphics.draw(self.cc.canvas, self.cc.offset.x, self.cc.offset.y, 0, self.cc.scaler, self.cc.scaler)
end

function Director:canvasDraw()
	love.graphics.draw(self.cc.canvas, self.cc.offset.x, self.cc.offset.y, 0, self.cc.scaler, self.cc.scaler)
end



--function Director:createCanvas()
--	local	canvas = love.graphics.newCanvas(self:getContentSize().width, self:getContentSize().height)
--	print("createCanvas", canvas, self:getContentSize().width, self:getContentSize().height)
--	return canvas
--end


function Director:pushCanvas(canvas)
	-- キャンバスを積み込む
	table.insert(self.cc.canvasList, canvas)
	love.graphics.setCanvas(canvas)
--	print(string.rep(" ", #self.cc.canvasList) .. "pushCanvas" .. #self.cc.canvasList)
end


function Director:popCanvas()
	-- キャンバスを取り除く
	table.insert(self.cc.drawCanvasList, self.cc.canvasList[#self.cc.canvasList])
	table.remove(self.cc.canvasList)
	local	canvas = self.cc.canvasList[#self.cc.canvasList]
--	print(string.rep(" ", #self.cc.canvasList) .. "popCanvas" .. #self.cc.canvasList)
	if canvas then
		love.graphics.setCanvas()
		love.graphics.setCanvas(canvas)
	else
		love.graphics.setCanvas()
	end
end

function Director:pushColor(color)
	-- カラーを積み込む
	if color == nil then
		local	r, g, b, a = love.graphics.getColor()
		color = cc.c4b(r, g, b, a)
	end
	table.insert(self.cc.colorList, color)
	self:setColor(color)
end


function Director:setColor(color)
	-- カラーをセット
	love.graphics.setColor(color.r, color.g, color.b, color.a)
end


function Director:popColor()
	-- カラーを取り除く
	local	color = self.cc.colorList[#self.cc.colorList]
	table.remove(self.cc.colorList)
	self:setColor(color)
end


function Director:pushScissor(area)
	table.insert(self.cc.scissorList, area)
	love.graphics.setScissor(area.x, area.y, area.width, area.height * 2)
end


function Director:popScissor()
	table.remove(self.cc.scissorList)
	local	area =  self.cc.scissorList[#self.cc.scissorList]
	if area then
		love.graphics.setScissor()
		love.graphics.setScissor(area.x, area.y, area.width, area.height)
	else
		love.graphics.setScissor()
	end
end


function Director:pushShader(
	shader
	)
	table.insert(self.cc.shaderList, shader)
	love.graphics.setShader(shader)
end


function Director:popShader()
	table.remove(self.cc.shaderList)
	local	shader = self.cc.shaderList[#self.cc.shaderList]
	if shader then
		love.graphics.setShader(shader)
	else
		love.graphics.setShader()
	end
end


function Director:mousemoved(...)
	if self.cc.runScene then
		self.cc.runScene:mousemoved(...)
	end
end


function Director:mousepressed(...)
	if self.cc.runScene then
		self.cc.runScene:mousepressed(...)
	end
end


function Director:mousereleased(...)
	if self.cc.runScene then
		self.cc.runScene:mousereleased(...)
	end
end


function Director:wheelmoved(...)
	if self.cc.runScene then
		self.cc.runScene:wheelmoved(...)
	end
end


function Director:keypressed(...)
	if self.cc.runScene then
		self.cc.runScene:keypressed(...)
	end
end


function Director:keyreleased(...)
	if self.cc.runScene then
		self.cc.runScene:keyreleased(...)
	end
end


function Director:resize(w, h)
	-- 比率をキープ
	local	size = self:getContentSize()
	
	if love.graphics.getHeight() / size.height < love.graphics.getWidth() / size.width then
		self.cc.scaler = love.graphics.getHeight() / size.height
	else
		self.cc.scaler = love.graphics.getWidth() / size.width
	end
	self.cc.offset = cc.p(
		math.floor(love.graphics.getWidth()  / 2 - (self.cc.scaler * (self:getContentSize().width  / 2))),
		math.floor(love.graphics.getHeight() / 2 - (self.cc.scaler * (self:getContentSize().height / 2)))
	)
end


return Director
