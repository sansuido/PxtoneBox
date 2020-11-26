local	MainLayer = import(".MainLayer")

local	MainScene = {}
MainScene = class("MainScene", cc.Scene)

function MainScene:ctor(...)
	cc.Scene.ctor(self, ...)
	do
		local	layer = MainLayer:create()
		layer:setName("mainLayer")
		self:addChild(layer)
	end
end

function MainScene:filedropped(file)
	local	mainLayer = self:getChildByName("mainLayer")
	if mainLayer then
		mainLayer:filedropped(file)
	end
end


return MainScene
