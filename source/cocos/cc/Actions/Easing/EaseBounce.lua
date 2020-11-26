local	ActionEase = import(".ActionEase")

local	EaseBounce = {}
EaseBounce = class("cc.EaseBounce", ActionEase)

function EaseBounce:bounceTime(time1)
	if (time1 < 1 / 2.75) then
		return 7.5625 * time1 * time1
	elseif (time1 < 2 / 2.75) then
		time1 = time1 - 1.5 / 2.75
		return 7.5625 * time1 * time1 + 0.75
	elseif (time1 < 2.5 / 2.75) then
		time1 = time1 - 2.25 / 2.75
		return 7.5625 * time1 * time1 + 0.9375
	end
	time1 = time1- 2.625 / 2.75
	return 7.5625 * time1 * time1 + 0.984375
end

return EaseBounce
