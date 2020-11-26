
local	MainScene = import(".MainScene")

local	Director = {}
Director = class("Director", cc.Director)

function Director:ctor(...)
	cc.Director.ctor(self, 320, 128)
	
--	love.window.setTitle("PxtoneBox")
	
	-- 設計用サイズをセット
--	self:setContentSize(cc.size(320, 128))
	
	self:runWithScene(MainScene:create())
end

-- ピッチによるサウンドテスト
--for i = 1, 128 do
--	print(math.pow(2, (i - 1) / 12))
--end

return Director

