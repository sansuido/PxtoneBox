
local	EaseElastic = import(".EaseElastic")


local	EaseElasticIn = {}
EaseElasticIn = class("cc.EaseElasticIn", EaseElastic)


function EaseElasticIn:update(dt)
	local	value = dt
	if dt ~= 0 or dt ~= 1 then
		local	s = self.cc.period / 4
		dt = dt - 1
		value = -math.pow(2, 10 * dt) * math.sin((dt - s) * math.pi * 2 / self.cc.period)
	end
	self.cc.inner:update(value)
end


return EaseElasticIn
