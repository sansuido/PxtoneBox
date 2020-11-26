require("cocos.init")
--local	CONST = require("PxtoneBox.pxtone.pxtnConst")
local	PxtnDescriptor = require("PxtoneBox.pxtone.pxtnDescriptor")
local	PxtnService = require("PxtoneBox.pxtone.pxtnService")
local	SmfDescriptor = require("PxtoneBox.smf.smfDescriptor")
local	SmfService = require("PxtoneBox.smf.smfService")
local	Path = require("PxtoneBox.lib.path")
local	pxtnDesc = PxtnDescriptor:create()
local	pxtn = PxtnService:create()
--local	smfDesc = SmfDescriptor:create()
local	smf = SmfService:create()
local	start_ch = love.thread.getChannel("pxtone2smf:start")
local	result = start_ch:demand()
result.write_file = Path:removeExtension(Path:stripPath(result.read_file)) .. "_PB.mid"

local	bl, err = pcall(
	function()
		
		pxtnDesc:set_file_r(result.read_file)
		
		local	err = pxtn:read(pxtnDesc)
		
		pxtnDesc:commit()
		
		smf:read_PXTN(pxtn)
		
		local	path = Path:removeFileSpec(result.read_file)
		local	read_byte = 0
		local	pool_byte = 0
		local	unit = 1024
		do
			local	desc = SmfDescriptor:create()
			local	read_ch = love.thread.getChannel("pxtone2smf:read")
			
			desc:set_file_w(path .. result.write_file)
			
			local	callback = function(byte)
				read_byte = read_byte + byte
				pool_byte = pool_byte + byte
				if pool_byte >= unit then
					result.byte = unit
					read_ch:push(result)
					pool_byte = pool_byte - unit
				end
			end
			if smf:write(desc, callback) == true then
				result.byte = pool_byte
				read_ch:supply(result)
				
				local	write_ch = love.thread.getChannel("pxtone2smf:write")
				desc:commit(unit,
					function(byte)
						result.byte = byte
						write_ch:push(result)
					end
				)
				result.byte = 0
				write_ch:supply(result)
			end
		end
		local	end_ch = love.thread.getChannel("pxtone2smf:end")
		result.byte = read_byte
		end_ch:supply(result)
	end
)
if bl == false then
	local	fpos, lpos, str = string.find(err, ".*: (.*)$")
	local	error_ch = love.thread.getChannel("pxtone2smf:error")
	result.byte = 0
	result.err = str or err
	error_ch:supply(result)
end

