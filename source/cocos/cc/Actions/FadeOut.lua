local	FadeTo = import(".FadeTo")

local	FadeOut = {}
FadeOut = class("cc.FadeOut", FadeTo)
function FadeOut:ctor(duration, ...)
	duration = duration or 0
	FadeTo.ctor(self)
	self:initWithDuration(duration, 0)
end

return FadeOut
