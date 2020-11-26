local	File = {}
File = class("File")

function File:ctor(fileName)
	--self.cc = self.cc or {}
	self.cc.fileName = fileName
	self.cc.handle = nil
end

function File:getFilename()
	return self.cc.fileName
end


function File:open(mode)
	self.cc.handle = io.open(self.cc.fileName, mode .. "b")
	if self.cc.handle then
		return true
	end
end

function File:read()
	local	res = nil
	if self.cc.handle then
		res = self.cc.handle:read("*a")
	end
	return res
end


function File:write(data, size)
	local	res = nil
	if self.cc.handle then
		res = self.cc.handle:write(string.sub(data, 1, size))
	end
	return res
end


function File:close()
	if self.cc.handle then
		self.cc.handle:close()
		self.cc.handle = nil
		self.cc.fileName = nil
	end
end

return File

