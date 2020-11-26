local	Quad = {}
Quad = class("Quad")

function Quad:ctor(x, y, width, height, sw, sh)
	--self.cc = self.cc or {}
	self.cc.x = x
	self.cc.y = y
	self.cc.width = width
	self.cc.height = height
	self.cc.sw = sw
	self.cc.sh = sh
end


function Quad:getViewport()
	return self.cc.x, self.cc.y, self.cc.width, self.cc.height
end


function Quad:setViewport(x, y, width, height)
	self.cc.x = x
	self.cc.y = y
	self.cc.width = width
	self.cc.height = height
end


return Quad
