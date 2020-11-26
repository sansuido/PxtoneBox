local	KeyboardManager = {}
KeyboardManager = class("KeyboardManager")

--  英文字（例："A")もしくは数字キー……その文字の表すキー（数字はフルキーのほう）。大文字小文字は区別されない
--  + - * / . =……その文字の表すキー。
--  " "もしくは"SPACE"……スペースキー
--  "CTRL"……コントロールキー
--  "UP"……カーソルキー上
--  "DOWN"……カーソルキー下
--  "LEFT"……カーソルキー左
--  "RIGHT"……カーソルキー右
--  "F1"～"F12"……ファンクションキー
--  "RETURN" もしくは "ENTER"……ENTERキー
--  "PAGEUP"……ページアップキー
--  "PAGEDOWN"……ページダウンキー
--  "SHIFT"……シフトキー
--  "SCROLLLOCK"……スクロールロックキー（ランプ付き状態なら1）
--  "NUMLOCK"……ナムロックキー（ランプ付き状態なら1）
--  "CAPSLOCK"……キャプスロックキー（ランプ付き状態なら1）
--  "LBUTTON"……マウス左ボタン
--  "RBUTTON"……マウス右ボタン
--  "MBUTTON"……マウス中ボタン
--  "NUM0"～"NUM9"……テンキーの0～9 

local	g_keys = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"+",
	"-",
	"*",
	"/",
	".",
	" ",
	"space",
	"ctrl",
	"up",
	"down",
	"left",
	"right",
	"f1",
	"f2",
	"f3",
	"f4",
	"f5",
	"f6",
	"f7",
	"f8",
	"f9",
	"f10",
	"f11",
	"f12",
	"return",
	"pageup",
	"pagedown",
	"shift",
--	"scrolllock",	-- ここら辺は面倒なのでやめた
--	"numlock",
--	"capslock",
	"num0",
	"num1",
	"num2",
	"num3",
	"num4",
	"num5",
	"num6",
	"num7",
	"num8",
	"num9",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
	"esc"
}

function KeyboardManager:ctor(...)
	--self.cc = self.cc or {}
	self.cc.inputs = {}
end


-- ret=gui.getkey(code) これだけなので、どうしよう

-- love.keypressed( key, scancode, isrepeat )
-- love.keyreleased( key, scancode )


function KeyboardManager:keyPressed(dt, key)
	if self.cc.inputs[key] == nil then
		love.keypressed(key, key, true)
		
		self.cc.inputs[key] = {
			count = 1,
			dt = dt
		}
	else
		self.cc.inputs[key].dt = self.cc.inputs[key].dt + dt
		
		if self.cc.inputs[key].count == 1 then
			if self.cc.inputs[key].dt >= 0.5 then
				love.keypressed(key, key, false)
				self.cc.inputs[key].count = self.cc.inputs[key].count + 1
				self.cc.inputs[key].dt = 0
			end
		else
			if self.cc.inputs[key].dt >= 0.05 then
				love.keypressed(key, key, false)
				self.cc.inputs[key].count = self.cc.inputs[key].count + 1
				self.cc.inputs[key].dt = 0
			end
		end
	end
end


function KeyboardManager:keyReleased(dt, key)
	if self.cc.inputs[key] ~= nil then
		love.keyreleased(key, key)
		self.cc.inputs[key] = nil
	end
end

function KeyboardManager:update(dt)
	for i, key in ipairs(g_keys) do
		if gui.getkey(key) then
			self:keyPressed(dt, key)
		else
			self:keyReleased(dt, key)
		end
	end
end


return KeyboardManager
