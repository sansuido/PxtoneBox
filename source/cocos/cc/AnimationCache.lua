local	AnimationCache = {}
AnimationCache = class("AnimationCache")


function AnimationCache:ctor(...)
	self.cc.animations = {}
end


function AnimationCache:addAnimation(animation, name)
	self.cc.animations[name] = animation
end


function AnimationCache:removeAnimation(name)
	self.cc.animations[name] = nil
end


function AnimationCache:getAnimation(name)
	return self.cc.animations[name]
end


return AnimationCache
