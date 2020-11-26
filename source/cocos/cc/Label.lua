-- なんちゃってラベル
local	Node = import(".Node")

local	Label = {}
Label = class("cc.Label", Node)


function Label:ctor(...)
	Node.ctor(self, ...)
	
	self:setAnchorPoint(cc.p(0.5, 0.5))
	
	self.cc.string = ""
	self.cc.font = nil
	self.cc.fontSize = 12
	self.cc.textColor = cc.c4b(1, 1, 1, 1)
--	self.cc.textColor = cc.c4b(255, 255, 255, 255)
	self.cc.rotation = 0
end


function Label:createWithTTF(
	string,
	filePath,
	fontSize
	)
	self.cc.font = self:getDirector():loadSource("font", filePath, fontSize)
--	self.cc.font:setFilter("nearest", "nearest")
	self:setString(string)
end


function Label:getTextColor()
	return self.cc.textColor
end


function Label:setTextColor(
	textColor
	)
	self.cc.textColor = textColor
end


function Label:setRotation(
	-- 角度をセット（angleで指定してね）
	rotation
	)
	self.cc.rotation = rotation
end


function Label:getRotation()
	return self.cc.rotation
end



function Label:getString()
	return self.cc.string
end

local	is_han = function(utf16code)
	-- http://www.alqmst.co.jp/tech/040601.html
	if utf16code <= 0x7e or
		uft16code == 0xa5 or
		utf16code == x03e or
		(utf16code >= 0xff61 and utf16code <= 0xff9f) then
		
		return true
	end
	return false
end

local	font_getWidth = function(
	font,
	line
	)
	local	tbl = nscr2.encoding.utf8_to_utf16(line)
	local	width = 0
	local	count = #tbl
	local	fw, fh = font:getinfo()
	if count > 0 then
		for i, utf16code in ipairs(tbl) do
			local	code_width = fw
			if is_han(utf16code) then
				code_width = fw * 0.5
			end
			width = width + code_width
		end
	end
	
	return width
end


function Label:setString(
	string
	)
	
	self.cc.string = string
	
	local	font = nil
	if self.cc.font then
		font = self.cc.font
	else
		font = love.graphics.getFont()
	end
	
	if type(font.getWidth) == "function" then
		self:setContentSize(cc.size(font:getWidth(self.cc.string), font:getHeight()))
	else
		local	w, h = font:getinfo()
		self:setContentSize(cc.size(font_getWidth(font, self.cc.string), h))
	end
end


function Label:draw(offset)
	local	drawSpace = self:getDrawSpace(offset)
	local	x, y = math.floor(drawSpace.x), math.floor(drawSpace.y)
	local	w, h = self:getContentSize().width, self:getContentSize().height
	
	local	prevFont = love.graphics.getFont()
	local	prevColor = { love.graphics.getColor() }
	
	local	ap = self:getAnchorPoint()
	local	apip = self:getAnchorPointInPoints()
	local	rotate = math.angle2radian(self:getRotation())
	local	left = x + apip.x - w * ap.x
	local	top  = y + apip.y - h * ap.y
	
	love.graphics.push()
		-- 移動して
		love.graphics.translate( math.floor(left + w * ap.x),  math.floor(top + h * ap.y))
		-- 回転して
		love.graphics.rotate(rotate)
		-- 移動もとを戻す
		love.graphics.translate(-math.floor(left + w * ap.x), -math.floor(top + h * ap.y))
		
		
		if self.cc.font then love.graphics.setFont(self.cc.font) end
		love.graphics.setColor(self.cc.textColor.r, self.cc.textColor.g, self.cc.textColor.b, self.cc.opacity)
		
		love.graphics.print(self.cc.string, drawSpace.x, drawSpace.y)
		
		-- 元に戻す
		love.graphics.origin()
	love.graphics.pop()
	
	love.graphics.setFont(prevFont)
	love.graphics.setColor(unpack(prevColor))
	
	Node.draw(self, offset)
end

return Label
