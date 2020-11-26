--[[

Copyright (c) 2011-2015 chukong-incc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

cc = cc or {}
ccui = ccui or {}

require "cocos.cocos2d.Cocos2d"
require "cocos.cocos2d.functions"
require "cocos.ui.GuiConstants"

cc.log = function(format, ...)
	print(string.format(format, ...))
end

cc.application = "love2d"
nscr2 = nscr2 or {}
for key, value in pairs(_G) do
	nscr2[key] = value
end
if nscr2.nmv then
	require "cocos.nscr2.init"
	cc.application = "nscr2"
end

-- cc
cc.Node = import(".cc.Node")
cc.Director = import(".cc.Director")
cc.Scene = import(".cc.Scene")
cc.Layer = import(".cc.Layer")
cc.LayerColor = import(".cc.LayerColor")
cc.Sprite = import(".cc.Sprite")
cc.SpriteBatchNode = import(".cc.SpriteBatchNode")
cc.SpriteFrame = import(".cc.SpriteFrame")
cc.Animation = import(".cc.Animation")
cc.EventMouse = import(".cc.EventMouse")
cc.EventKeyboard = import(".cc.EventKeyboard")
cc.Label = import(".cc.Label")

-- cc.actions
cc.MoveBy = import(".cc.Actions.MoveBy")
cc.MoveTo = import(".cc.Actions.MoveTo")
cc.Sequence = import(".cc.Actions.Sequence")
cc.CallFunc = import(".cc.Actions.CallFunc")
cc.RepeatForever = import(".cc.Actions.RepeatForever")
cc.Animate = import(".cc.Actions.Animate")
cc.DelayTime = import(".cc.Actions.DelayTime")
cc.ScaleBy = import(".cc.Actions.ScaleBy")
cc.ScaleTo = import(".cc.Actions.ScaleTo")
cc.TintTo = import(".cc.Actions.TintTo")
cc.RemoveSelf = import(".cc.Actions.RemoveSelf")
cc.FadeTo = import(".cc.Actions.FadeTo")
cc.FadeOut = import(".cc.Actions.FadeOut")
cc.Blink = import(".cc.Actions.Blink")

cc.EaseIn = import(".cc.Actions.Easing.EaseIn")
cc.EaseOut = import(".cc.Actions.Easing.EaseOut")
cc.EaseInOut = import(".cc.Actions.Easing.EaseInOut")
cc.EaseExponentialIn = import(".cc.Actions.Easing.EaseExponentialIn")
cc.EaseExponentialOut = import(".cc.Actions.Easing.EaseExponentialOut")
cc.EaseExponentialInOut = import(".cc.Actions.Easing.EaseExponentialInOut")
cc.EaseSineIn = import(".cc.Actions.Easing.EaseSineIn")
cc.EaseSineOut = import(".cc.Actions.Easing.EaseSineOut")
cc.EaseSineInOut = import(".cc.Actions.Easing.EaseSineInOut")
cc.EaseElasticIn = import(".cc.Actions.Easing.EaseElasticIn")
cc.EaseElasticOut = import(".cc.Actions.Easing.EaseElasticOut")
cc.EaseElasticInOut = import(".cc.Actions.Easing.EaseElasticInOut")
cc.EaseBounceIn = import(".cc.Actions.Easing.EaseBounceIn")
cc.EaseBounceOut = import(".cc.Actions.Easing.EaseBounceOut")
cc.EaseBounceInOut = import(".cc.Actions.Easing.EaseBounceInOut")
cc.EaseBackIn = import(".cc.Actions.Easing.EaseBackIn")
cc.EaseBackOut = import(".cc.Actions.Easing.EaseBackOut")
cc.EaseBackInOut = import(".cc.Actions.Easing.EaseBackInOut")


-- ccui
ccui.Layout = import(".ccui.Layout")
ccui.Button = import(".ccui.Button")
ccui.TextAtlas = import(".ccui.TextAtlas")
ccui.ListView = import(".ccui.ListView")
ccui.ScrollView = import(".ccui.ScrollView")

