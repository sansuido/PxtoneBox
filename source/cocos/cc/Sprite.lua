-- 疑似スプライト

local	Node = import(".Node")

local	Sprite = {}
Sprite = class("cc.Sprite", Node)


function Sprite:ctor(...)
	
	Node.ctor(self, ...)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	
	local	args = { ... }
	local	filename = nil
	local	rect = nil
	
	self.cc.texture = nil
	self.cc.textureRect = nil
	self.cc.textureQuad = nil
	self.cc.rotation = 0
	self.cc.scaleX = 1
	self.cc.scaleY = 1
	self.cc.flippedX = false
	self.cc.flippedY = false
	
--	self.cc.color = cc.c3b(255, 255, 255)
--	self.cc.opacity = 255
	
	self.cc.batchEnabled = false
	
	if type(args[1]) == "string" then filename = args[1] end
	if type(args[2]) == "table" then rect = args[2] end
	
	if filename then
		self:initWithFile(filename, rect)
	end
end

function Sprite:initWithFile(
	filename,
	rect
	)
	local	width, height
	if type(filename) == "string" then
		self:setTexture(self:getDirector():loadSource("image", filename))
		if type(self.cc.texture.getsize) == "function" then
			width, height = self.cc.texture:getsize()
		else
			width, height = self.cc.texture:getWidth(), self.cc.texture:getHeight()
		end
		
		if rect and rect.width and rect.height then
			self.cc.contentSize = cc.size(rect.width, rect.height)
		else
			self.cc.contentSize = cc.size(width, height)
		end
		
	end
	if type(rect) == "table" then
		self:setTextureRect(rect, true)
	end
end


function Sprite:getTexture()
	return self.cc.texture
end


function Sprite:setTexture(
	texture
	)
	if type(texture) == "string" then
		self:setTexture(self:getDirector():loadSource("image", texture))
	else
		self.cc.texture = texture
		
		-- これを入れてみたけど都合悪い時があるかどうか……
		if self.cc.texture and self:getContentSize().width == 0 and self:getContentSize().height == 0 then
			local	width, height
			if type(self.cc.texture.getsize) == "function" then
				width, height = self.cc.texture:getsize()
			else
				width, height = self.cc.texture:getWidth(), self.cc.texture:getHeight()
			end
			self:setContentSize(cc.size(width, height))
		end
	end
--	if self.cc.texture then
--		self.cc.texture:setFilter("nearest", "nearest")
--	end
end

function Sprite:setSpriteFrame(spriteFrame)
	
	self:setTexture(spriteFrame.cc.texture)
	self:setTextureRect(spriteFrame.cc.rect)
end


function Sprite:setFlippedX(flippedX)
	self.cc.flippedX = flippedX
end


function Sprite:setFlippedY(flippedY)
	self.cc.flippedY = flippedY
end

function Sprite:isFlippedX()
	return self.cc.flippedX
end


function Sprite:isFlippedY()
	return self.cc.flippedY
end


function Sprite:setRotation(
	-- 角度をセット（angleで指定してね）
	rotation
	)
	self.cc.rotation = rotation
end


function Sprite:getRotation()
	return self.cc.rotation
end


function Sprite:getTextureRect()
	return self.cc.textureRect
end


function Sprite:setScale(
	scale
	)
	self.cc.scaleX = scale
	self.cc.scaleY = scale
end


function Sprite:setScaleX(
	scaleX
	)
	self.cc.scaleX = scaleX
end


function Sprite:setScaleY(
	scaleY
	)
	self.cc.scaleY = scaleY
end


function Sprite:getColor()
	return self.cc.color
end


function Sprite:setColor(color)
	self.cc.color = color
end



function Sprite:setTextureRect(
	rect,
	resize
	)
	resize = resize or true
	
	if self.cc.texture then
		
		local	width, height
		if type(self.cc.texture.getsize) == "function" then
			width, height = self.cc.texture:getsize()
		else
			width, height = self.cc.texture:getWidth(), self.cc.texture:getHeight()
		end
		
		self.cc.textureRect = rect
		self.cc.textureQuad = love.graphics.newQuad(rect.x, rect.y, rect.width, rect.height, width, height)
		
		if resize or (self:getContentSize().width == 0 and self:getContentSize().height == 0) then
			self.cc.contentSize = cc.size(rect.width or width, rect.height or height)
		end
	end
end


function Sprite:draw(offset)
	
	if self.cc.texture then
		local	r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(self.cc.color.r or 1, self.cc.color.g or 1, self.cc.color.b or 1, self.cc.opacity or 1)
--		love.graphics.setColor(self.cc.color.r or 255, self.cc.color.g or 255, self.cc.color.b or 255, self.cc.opacity or 255)
		
		local	drawSpace = self:getDrawSpace(offset)
		
		local	x, y = math.floor(drawSpace.x), math.floor(drawSpace.y)
		local	width, height = self:getContentSize().width, self:getContentSize().height
		local	vx, vy, w, h
		if self.cc.textureQuad then
			vx, vy, w, h = self.cc.textureQuad:getViewport()
		else
			if type(self.cc.texture.getsize) == "function" then
				w, h = self.cc.texture:getsize()
			else
				w, h = self.cc.texture:getWidth(), self.cc.texture:getHeight()
			end
		end
		local	ap = self:getAnchorPoint()
		local	apip = self:getAnchorPointInPoints()
		local	rotate = math.angle2radian(self:getRotation())
		local	left = x + apip.x - w * self.cc.scaleX * ap.x
		local	top  = y + apip.y - h * self.cc.scaleY * ap.y
		local	scaleX = self.cc.scaleX
		local	scaleY = self.cc.scaleY
		
		love.graphics.push()
			-- 移動して
			love.graphics.translate( math.floor(left + w * ap.x * scaleX),  math.floor(top + h * ap.y * scaleY))
			-- 回転して
			love.graphics.rotate(rotate)
			-- 移動もとを戻す
			love.graphics.translate(-math.floor(left + w * ap.x * scaleX), -math.floor(top + h * ap.y * scaleY))
			
			-- flippedをチェック
			if self:isFlippedX() then
				-- 左右反転
				left = left + w * scaleY
				scaleX = scaleX * -1
			end
			if self:isFlippedY() then
				-- 上下反転
				top = top + h * scaleY
				scaleY = scaleY * -1
			end
			
			if self.cc.textureQuad then
				love.graphics.draw(self.cc.texture,
					self.cc.textureQuad,
					left,
					top,
					0,
					scaleX,
					scaleY
				)
			else
				love.graphics.draw(self.cc.texture,
					left,
					top,
					0,
					scaleX,
					scaleY
				)
			end
			
			-- 元に戻す
			love.graphics.origin()
		love.graphics.pop()
		
		love.graphics.setColor(r, g, b, a)
	end
	
	Node.draw(self, offset)
end


function Sprite:batchEnabled(enabled)
	self.cc.batchEnabled = enabled
end


return Sprite


--function draw_rota_graph(
--	-- グラフィック描画
--	img,	--  イメージデータ
--	...
--	-- (quad)	（分割データ）
--	-- x		中央X座標
--	-- y		中央Y座標
--	-- scale	スケール
--	-- rotate	回転（ラジアン指定）
--	-- xturn	左右反転
--	-- yturn	上下反転
--	)
--	local	argv = { ... }
--	local	shift = 0
--	local	quad = nil
--	if type(argv[1]) == "userdata" and type(argv[1].type) == "function" and argv[1]:type() == "Quad" then
--		quad = argv[1]
--		shift = 1
--	end
--	local	x = argv[1 + shift] or 0
--	local	y = argv[2 + shift] or 0
--	local	scale = argv[3 + shift] or 1.0
--	local	rotate = argv[4 + shift] or 0
--	local	xturn = argv[5 + shift] or false
--	local	yturn = argv[6 + shift] or false
--	local	left, top
--	local	vx, vy, w, h
--	local	sx = scale
--	local	sy = scale
--	
--	-- グラフィックサイズを取得
--	if quad then
--		vx, vy, w, h = quad:getViewport()
--	else
--		w, h = img:getDimensions()
--	end
--	-- サイズより左上を算出
--	left = x - w * sx * 0.5
--	top  = y - h * sy * 0.5
--	
--	-- 描画を開始
--	love.graphics.push()
--	do
--		if rotate ~= 0 then
--			-- 回転させる
--			love.graphics.translate( math.floor(left + w * sx * 0.5),  math.floor(top + h * sy * 0.5))
--			love.graphics.rotate(rotate)
--			love.graphics.translate(-math.floor(left + w * sx * 0.5), -math.floor(top + h * sy * 0.5))
--		end
--		if xturn then
--			-- 左右反転
--			left = left + w * sx
--			sx = sx * -1
--		end
--		if yturn then
--			-- 上下反転
--			top = top + h * sy
--			sy = sy * -1
--		end
--		if quad then
--			-- 分割用描画
--			love.graphics.draw(img, quad, left, top, 0, sx, sy)
--		else
--			-- 非分割描画
--			love.graphics.draw(img, left, top, 0, sx, sy)
--		end
--	end
--	love.graphics.pop()
--end
