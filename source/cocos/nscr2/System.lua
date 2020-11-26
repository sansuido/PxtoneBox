local	System = {}


System.openURL = function(url)
	nscr2.gui.shell(url)
end

System.getOS = function()
	return "Windows"
end

return System
