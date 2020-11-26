local	File = import(".File")

local	Filesystem = {}

Filesystem.read = function(fileName)
	local	res = nil
	local	path = gui.getexedir()
	local	hFile, err = io.open(path .. fileName)
	if (not err) then
		res = hFile:read("*a")
		io.close(hFile)
	end
	return res
end

Filesystem.lines = function(fileName)
	local	path = gui.getexedir()
	return io.lines(path .. fileName)
end


Filesystem.newFile = function(fileName)
	return File:create(fileName)
end


return Filesystem

