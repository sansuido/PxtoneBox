
local	EaseElastic = import(".EaseElastic")


local	EaseElasticOut = {}
EaseElasticOut = class("cc.EaseElasticOut", EaseElastic)


function EaseElasticOut:update(dt)
	local	value = dt
	if dt ~= 0 or dt ~= 1 then
		local	s = self.cc.period / 4
		value = math.pow(2, -10 * dt) * math.sin((dt - s) * math.pi * 2 / self.cc.period) + 1
	end
	self.cc.inner:update(value)
end


return EaseElasticOut
