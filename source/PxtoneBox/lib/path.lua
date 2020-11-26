local	Path = {}
Path = class("Path")


local	g_backslash = "\\"


function Path:addBackslash(path)
	-- バックスラッシュを付加
	if string.sub(path, #path, #path) ~= g_backslash then
		path = path .. g_backslash
	end
	return path
end


function Path:createDirectory(path)
	-- ディレクトリ生成（ちょっと強引）
	if self:isDirectory(path) == false then
		os.execute(string.format("mkdir \"%s\"", path))
	end
end


function Path:canonicalize(path)
	-- 正規化
	local	retry
	repeat
		retry = false
		local	fp, lp = string.find(path, '.', 1, true)
		if fp ~= nil then
			if string.sub(path, fp + 1, fp + 1) == "." then
				-- ..だった場合、/を見つけたら展開
				for i = fp - 2, 1, -1 do
					local	s = string.sub(path, i, i)
					if s == g_backslash then
						path = string.sub(path, 1, i) .. string.sub(path, fp + 3)
						retry = true
						break
					end
				end
			elseif string.sub(path, fp + 1, fp + 1) == g_backslash then
				-- .だった場合、すぐ後ろが/だったら展開
				path = string.sub(path, 1, fp - 1) .. string.sub(path, fp + 2)
				retry = true
			end
		end
	until retry == false
	return path
end


function Path:fileExists(path)
	-- ファイルが存在するかどうか
	local	bl = false
	local	file = io.open(path, "r")
	if file then
		bl = true
		file:close()
	end
	return bl
end


function Path:isDirectory(path)
	-- ディレクトリかどうか
	local	bl = false
	if self:fileExists(path) then return false end
	local	fullpath = self:addBackslash(path) .. os.tmpname()
	local	file = io.open(fullpath, "w")
	if file then
		bl = true
		file:close()
		os.remove(fullpath)
	end
	return bl
end


function Path:removeExtension(path)
	-- 拡張子を取り除く
	return string.gsub(path, "(.*)%.(.+)$", "%1")
end


function Path:getExtension(path)
	-- 拡張子を取得
	return string.gsub(path, "(.*)%.(.+)$", "%2")
end


function Path:stripPath(path)
	return string.gsub(path, "(.*)%\\(.+)$", "%2")
end


function Path:removeFileSpec(path)
	return string.gsub(path, "(.*)%\\(.+)$", "%1") .. "\\"
end


return Path
