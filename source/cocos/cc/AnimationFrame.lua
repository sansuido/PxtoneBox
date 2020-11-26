local	AnimationFrame = {}
AnimationFrame = class("cc.AnimationFrame")


function AnimationFrame:ctor(spriteFrame, delayPerUnits, userInfo)
	self.cc.spriteFrame = spriteFrame
	self.cc.delayPerUnits = delayPerUnits
	self.cc.userInfo = userInfo
end


function AnimationFrame:initWithSpriteFrame(spriteFrame, delayPerUnits, userInfo)
	self.cc.spriteFrame = spriteFrame
	self.cc.delayPerUnits = delayPerUnits
	self.cc.userInfo = userInfo
end


function AnimationFrame:getSpriteFrame()
	return self.cc.spriteFrame
end


function AnimationFrame:setSpriteFrame(spriteFrame)
	self.cc.spriteFrame = spriteFrame
end


function AnimationFrame:getDelayPerUnits()
	return self.cc.delayPerUnits
end


function AnimationFrame:setDelayPerUnits(delayPerUnits)
	self.cc.delayPerUnits = delayPerUnits
end


function AnimationFrame:getUserInfo()
	return self.cc.userInfo
end


function AnimationFrame:setUserInfo(userInfo)
	self.cc.userInfo = userInfo
end


return AnimationFrame
