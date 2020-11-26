


-- trianglefan
-- point
-- linestrip
-- triangle
-- bezier
-- pointlist
-- trianglelist
-- line
-- trianglestrip
-- linelist

local	bit = bit or import(".lib.bit")


local	Quad = import(".Quad")

local	Graphics = {}

local	g_color = cc.c3b(0xff, 0xff, 0xff)
local	g_font = nscr2.font.create({width = 16, height = 16, name = ""})
local	g_rotate = 0


local	color_conv = function(love2d_color)
	love2d_color = love2d_color or cc.c3b(0xff, 0xff, 0xff)
	
	local	nscr2_color = 0x00000000
	
	nscr2_color = nscr2_color + bit.lshift(love2d_color.a or 0xff, 24)
	nscr2_color = nscr2_color + bit.lshift(love2d_color.r, 16)
	nscr2_color = nscr2_color + bit.lshift(love2d_color.g,  8)
	nscr2_color = nscr2_color + bit.lshift(love2d_color.b,  0)
	
	return nscr2_color
end


Graphics.setColor = function(r, g, b, a)
	g_color = cc.c4b(r, g, b, a)
end


Graphics.getColor = function()
	return g_color.r, g_color.g, g_color.b, g_color.a
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

Graphics.print = function(string, x, y)
	local	tbl = nscr2.encoding.utf8_to_utf16(string)
	local	count = #tbl
	local	width, height = g_font:getinfo()
	local	color = color_conv(g_color)
	if count > 0 then
		local	left = 0
		local	texture = nscr2.texture.create(width * count, height)
		for i, utf16code in ipairs(tbl) do
			local	code_width = width
			
			if is_han(utf16code) then
				code_width = width * 0.5
			end
			g_font:put(texture, utf16code, left, 0, color)
			left = left + code_width
		end
		
		-- なぜかずれちゃうので、-4しとく
		texture:draw(x - 4, y, 255)
		texture:delete()
	end
end


Graphics.setFont = function(font)
	g_font = font
end


Graphics.getFont = function()
	return g_font
end


Graphics.getWidth = function()
	local	width, height = nscr2.gui.getsize()
	return width
end


Graphics.getHeight = function()
	local	width, height = nscr2.gui.getsize()
	return height
end


Graphics.newImage = function(filename)
	return nscr2.texture.load(filename)
end


Graphics.newQuad = function(x, y, width, height, sw, sh)
	return Quad:create(x, y, width, height, sw, sh)
end


Graphics.pop = function() g_rotate = 0 end
Graphics.push = function() end
Graphics.origin = function() end
Graphics.translate = function() end
Graphics.rotate = function(rotate) g_rotate = rotate end

Graphics.draw = function(...)
	local	args = { ... }
	local	texture, quad
	local	x, y, r, sx, sy, ox, oy, kx, ky
	if type(args[2]) == "number" then
		texture = args[1]
		x = args[2]
		y = args[3]
		r = args[4] or 0
		sx = args[ 5] or 1
		sy = args[ 6] or sx
		ox = args[ 7] or 0
		oy = args[ 8] or 0
		kx = args[ 9] or 0
		ky = args[10] or 0
	else
		texture = args[1]
		quad = args[2]
		x = args[3]
		y = args[4]
		r = args[5] or 0
		sx = args[ 6] or 1
		sy = args[ 7] or sx
		ox = args[ 8] or 0
		oy = args[ 9] or 0
		kx = args[10] or 0
		ky = args[11] or 0
	end
	
	if texture then
		
		local	vx, vy, w, h
		if quad then
			vx, vy, w, h = quad:getViewport()
			if sx < 0 then
				x = x - w
			end
			if sy < 0 then
				y = y - h
			end
			
			texture:drawrectlt(math.floor(x + (w * 0.5 * math.abs(sx)) - 1), math.floor(y + h * 0.5 * math.abs(sy) - 1), vx, vy, w, h, sx, sy, r - g_rotate, g_color.a or 255)
		else
			w, h = texture:getsize()
			if sx < 0 then
				x = x - w
			end
			if sy < 0 then
				y = y - h
			end
			
			texture:drawlt(math.floor(x + (w * 0.5 * math.abs(sx)) - 1), math.floor(y + h * 0.5 * math.abs(sy) - 1), sx, sy, r - g_rotate, g_color.a or 255)
			-- 回転されない不具合の為上に変更
--			texture:drawrect(math.floor(x), math.floor(y), w, h, sx, sy, g_color.a)
		end
		
	end
end

Graphics.setDefaultFilter = function() end
Graphics.newCanvas = function() end
Graphics.setCanvas = function() end
Graphics.clear = function() end
Graphics.setScissor = function() end

Graphics.newFont = function(filePath, fontSize)
	
	local	font = nscr2.font.create({
		width = fontSize,
		height = fontSize,
		name = filePath
	})
	return font
	
end

return Graphics
