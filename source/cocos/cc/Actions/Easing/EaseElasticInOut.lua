
local	EaseElastic = import(".EaseElastic")


local	EaseElasticInOut = {}
EaseElasticInOut = class("cc.EaseElasticInOut", EaseElastic)


function EaseElasticInOut:update(dt)
	local	value = dt
	if dt ~= 0 or dt ~= 1 then
		dt = dt * 2
		local	s = self.cc.period / 4
		dt = dt - 1
		if dt < 0 then
			value = -0.5 * math.pow(2, 10 * dt) * math.sin((dt - s) * math.pi * 2 / self.cc.period)
		else
			value = math.pow(2, -10 * dt) * math.sin((dt - s) * math.pi * 2 / self.cc.period) * 0.5 + 1
		end
	end
	self.cc.inner:update(value)
end


return EaseElasticInOut
