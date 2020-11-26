-- spriteのフレームを生成

local	Director = import(".Director")

local	SpriteFrame = {}
SpriteFrame = class("cc.SpriteFrame")

function SpriteFrame:ctor(
	texture,
	rect
	)
	
	if texture then
		self:initWithTexture(texture, rect)
	end
end


function SpriteFrame:initWithTexture(
	texture,
	rect
	)
	if type(texture) == "string" then
		self.cc.texture = Director:getInstance():loadSource("image", texture)
	else
		self.cc.texture = texture
	end
	
	self.cc.rect = rect
end

return SpriteFrame

