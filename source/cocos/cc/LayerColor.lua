local	Layer = import(".Layer")

local	LayerColor = {}

LayerColor = class("cc.LayerColor", Layer)


function LayerColor:ctor(
	color,
	width,
	height,
	...
	)
	Layer.ctor(self, color, width, height, ...)
	
--	self.cc.backGroundColorType = 2
--	self.cc.backGroundColor = color or cc.c3b(0xff, 0xff, 0xff)
	self:setColor(color or cc.c3b(0, 0, 0))
	
	if width and height then
		self:setContentSize(cc.size(width, height))
	end
end


function LayerColor:draw(offset)
	
	do
		local	backupColor = { love.graphics.getColor() }
		love.graphics.setColor(self.cc.color.r, self.cc.color.g, self.cc.color.b, self.cc.opacity)
		
		local	mode = {
			"line",
			"fill"
		}
		local	drawSpace = self:getDrawSpace(offset)
		local	x, y = drawSpace.x, drawSpace.y
		local	width, height = self:getContentSize().width, self:getContentSize().height
		
		love.graphics.polygon(
			mode[2],
			x, y,
			x + width, y,
			x + width, y + height,
			x, y + height
		)
		love.graphics.setColor(unpack(backupColor))
	end
	
	Layer.draw(self, offset)
end

return LayerColor

