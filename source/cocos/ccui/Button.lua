-- 疑似ＵＩボタン

--local	Node = import("..cc.Node")
local	Sprite = import("..cc.Sprite")
local	EventMouse = import("..cc.EventMouse")

local	Button = {}

Button = class("ccui.Button", Sprite)


function Button:ctor(...)
	Sprite.ctor(self)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	local	args = { ... }
	
	local	normalimage = nil
	local	normalrect = nil
	local	selectedimage = nil
	local	selectedrect = nil
	
	--self.cc = self.cc or {}
	self.cc.textures = {}
	self.cc.onClick = nil
	self.cc.onEnter = nil
	self.cc.onLeave = nil
	self.cc.onUp = nil
	self.cc.onDown = nil
	
	-- 引数解析
	if type(args[1]) == "table" then
		if type(args[1][1]) == "string" then
			normalimage = args[1][1]
		end
		if type(args[1][2]) ~= "nil" then
			normalrect = args[1][2]
		end
	elseif type(args[1]) == "string" then
		normalimage = args[1]
	end
	if type(args[2]) == "table" then
		if type(args[2][1]) == "string" then
			selectedimage = args[2][1]
		end
		if type(args[2][2]) ~= "nil" then
			selectedrect = args[2][2]
		end
	elseif type(args[2]) == "string" then
		selectedimage = args[1]
	end
	
	if normalimage then
		self:loadTextureNormal(normalimage, normalrect)
	end
	if selectedimage then
		self:loadTextureSelected(selectedimage, selectedrect)
	end
end

function Button:loadTextureNormal(
	filename,
	rect
	)
	local	texture
	
	if type(filename) == "string" then
		texture = self:getDirector():loadSource("image", filename)
--		texture = love.graphics.newImage(filename)
	end
	
	self.cc.textures.normal = {
		texture = texture,
		rect = rect
	}
	
	self:swapTexture("normal")
	
--	if texture then
--		self.cc.texture = texture
--		self.cc.textureRect = rect
--	end
end


function Button:loadTextureSelected(
	filename,
	rect
	)
	local	texture
	if type(filename) == "string" then
		texture = self:getDirector():loadSource("image", filename)
--		texture = love.graphics.newImage(filename)
	end
	
	self.cc.textures.selected = {
		texture = texture,
		rect = rect
	}
end


function Button:swapTexture(
	-- テキスチャをすげかえる
	mode	-- normal
			-- selected
	)
	
	if self.cc.textures.normal then
		self:setTexture(nil)
		if mode == "normal" then
			if type(self.cc.textures.normal) == "table" then
				self:setTexture(self.cc.textures.normal.texture)
				if self.cc.textures.normal.rect then self:setTextureRect(self.cc.textures.normal.rect) end
			end
		elseif mode == "selected" then
			if type(self.cc.textures.selected) == "table" then
				self:setTexture(self.cc.textures.selected.texture)
				if self.cc.textures.selected.rect then self:setTextureRect(self.cc.textures.selected.rect) end
			end
		end
	end
end

function Button:setMouseEnabled(
	-- マウスを有効にする→自動でListenerへ登録
	mouseEnabled,
	argv
	)
	
	local	eventMouse = EventMouse:create()
	eventMouse.onMouseMove = self.onMouseMove
	eventMouse.onMouseUp = self.onMouseUp
	eventMouse.onMouseDown = self.onMouseDown
	
	if mouseEnabled then
		self:addEventListener(
			eventMouse
		)
	end
	
	if type(argv) == "function" then
		self.cc.onClick = argv
	elseif type(argv) == "table" then
		if type(argv.onClick) == "function" then
			self.cc.onClick = argv.onClick
		end
		if type(argv.onEnter) == "function" then
			self.cc.onEnter = argv.onEnter
		end
		if type(argv.onLeave) == "function" then
			self.cc.onLeave = argv.onLeave
		end
		if type(argv.onUp) == "function" then
			self.cc.onUp = argv.onUp
		end
		if type(argv.onDown) == "function" then
			self.cc.onDown = argv.onDown
		end
	end
end


function Button:onMouseMove(
	event
	)
	local	boundingBox = self:getBoundingBox(cc.p(-1, -1))
	if self:isHover(event:getLocation()) and event:getStartLocation() then
		self:swapTexture("selected")
		if type(self.cc.onEnter) == "function" then
			self.cc.onEnter(self, event)
		end
	else
		self:swapTexture("normal")
		if type(self.cc.onLeave) == "function" then
			self.cc.onLeave(self, event)
		end
	end
end


function Button:onMouseUp(
	event
	)
	local	boundingBox = self:getBoundingBox(cc.p(-1, -1))
	if self:isHover(event:getLocation()) then
		self:swapTexture("normal")
		if type(self.cc.onLeave) == "function" then
			self.cc.onLeave(self, event)
		end
		if type(self.cc.onUp) == "function" then
			self.cc.onUp(self, event)
		end
		if type(self.cc.onClick) == "function" then
			self.cc.onClick(self, event)
		end
		return true
	end
end

function Button:onMouseDown(
	event
	)
	local	boundingBox = self:getBoundingBox(cc.p(-1, -1))
	if self:isHover(event:getLocation()) then
		self:swapTexture("selected")
		if type(self.cc.onDown) == "function" then
			self.cc.onDown(self, event)
		end
		if type(self.cc.onEnter) == "function" then
			self.cc.onEnter(self, event)
		end
		return true
	end
end



return Button