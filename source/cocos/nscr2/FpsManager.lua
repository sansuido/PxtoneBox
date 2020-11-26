-- FPSを保つ為のあれ

FpsManager = {}
FpsManager = class("FpsManager")

function FpsManager:ctor()
	--self.cc = self.cc or {}
	self.cc.fps_rate = 60
	
	self.cc.count = 0
	self.cc.fps = 0
	self.cc.request_fps = 0
	self.cc.keep_count = 0
	self.cc.delta_time = 0
	
--	self.cc.label = cc.Label:create()
end

function FpsManager:init()
	self.cc.request_fps = 1000 / self.cc.fps_rate
	self.cc.keep_count = 0
end

function FpsManager:prev()
	-- 開始
	
	if self.cc.count == 0 then
		self.cc.begin = gui.gettimer()
	end
end

function FpsManager:post()
	
	if (gui.gettimer() - self.cc.begin) >= 1000 then
		self.cc.fps = self.cc.count
		self.cc.count = 0
	else
		self.cc.count = self.cc.count + 1
	end
end


--function FpsManager:draw()
--	self.cc.label:setString(string.format("%.1f", self.cc.fps))
--	local	size = self.cc.label:getContentSize()
--	local	width, height = gui.getsize()
--	self.cc.label.cc.drawSpace = cc.p(width - size.width, 0)
--	self.cc.label:draw()
--end


function FpsManager:wait()
	local	time
	time = self.cc.request_fps - (gui.gettimer() - self.cc.keep_count)
	if time > 0 then
		gui.sleep(time)
		self.cc.delta_time = self.cc.request_fps
	else
		self.cc.delta_time = gui.gettimer() - self.cc.keep_count
	end
	self.cc.keep_count = gui.gettimer()
end


function FpsManager:getDeltaTime()
	return math.min(self.cc.delta_time / 1000, 0.1)
end


function FpsManager:getFPS()
	return self.cc.fps
end


function FpsManager:setFPS(fps)
	self.cc.fps_rate = fps
	self.cc.request_fps = 1000 / self.cc.fps_rate
end

return FpsManager
