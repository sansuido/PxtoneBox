local	ScaleTo = import(".ScaleTo")

local	ScaleBy = {}
ScaleBy = class("cc.ScaleBy", ScaleTo)

function ScaleBy:ctor(...)
	ScaleTo.ctor(self, ...)
end

function ScaleBy:startWithTarget(target)
	ScaleTo.startWithTarget(self, target)
	self.cc.deltaX = self.cc.startScaleX * self.cc.endScaleX - self.cc.startScaleX
	self.cc.deltaY = self.cc.startScaleY * self.cc.endScaleY - self.cc.startScaleY
end

return ScaleBy
