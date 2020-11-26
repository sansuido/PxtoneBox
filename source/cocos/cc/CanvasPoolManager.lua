local CanvasPoolManager = {}
CanvasPoolManager = class("cc.CanvasPoolManager")

function CanvasPoolManager:ctor(width, height)
	self.cc.width  = width
	self.cc.height = height
	self.cc.pools = {}
end


function CanvasPoolManager:createCanvas(target)
	local	canvas = nil
	for i, pool in ipairs(self.cc.pools) do
		if pool.target == nil then
			canvas = pool.canvas
			pool.target = target
			break
		end
	end
	if canvas == nil then
		canvas = love.graphics.newCanvas(self.cc.width, self.cc.height)
		local	pool = {}
		pool.canvas = canvas
		pool.target = target
		table.insert(self.cc.pools, pool)
	end
	return canvas
end


function CanvasPoolManager:removeCanvas(target)
	for i, pool in ipairs(self.cc.pools) do
		if pool.target == target or pool.canvas == target then
			pool.target = nil
			break
		end
	end
end


return CanvasPoolManager
