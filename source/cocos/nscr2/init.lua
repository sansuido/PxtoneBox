-- NScripter2でLove2D、Cocos2d-xを疑似的に行うスクリプト
-- http://www.nscripter.com/
-- http://love2d.org/
-- http://www.cocos2d-x.org/

local	File = import(".File")

cc = cc or {}

cc.log = function(format, ...)
	console.print(string.format(format, ...))
end

love = love or {}
love.graphics = love.graphics or import(".Graphics")
love.mouse = love.mouse or import(".Mouse")
love.keyboard = love.keyboard or import(".Keyboard")
love.filesystem = love.filesystem or import(".Filesystem")
love.system = love.system or import(".System")
love.window = love.window or import(".Window")

bit = bit or import(".lib.bit")

local	FpsManager = import(".FpsManager")
local	MouseManager = import(".MouseManager")
local	KeyboardManager = import(".KeyboardManager")

-- FPSマネージャを作成
local	fpsManager = FpsManager:create()
love.timer = love.timer or {}
love.timer.getDelta = function() return fpsManager:getDeltaTime() end
love.timer.getFPS = function() return fpsManager:getFPS() end
love.timer.setFPS = function(fps) fpsManager:setFPS(fps) end
love.keypressed = function(key, scancode, isrepeat) end
love.keyreleased = function(key, scancode) end
love.filedropped = function(filename) end

function love.conf(t) end
function love.load() end
function love.update(dt) end
function love.draw() end
function love.quit() end
function love.mousemoved(x, y, dx, dy, istouch) end
function love.mousepressed(x, y, button, istouch) end
function love.mousereleased(x, y, button, istouch) end

function love.run()
	local	file_exists = function(path)
	    local fh = io.open(path, "rb")
	    if fh then fh:close() end
	    return fh ~= nil
	end
	if file_exists("conf.lua") then
		require("conf")
	end
	local	mouseManager = MouseManager:create()
	local	keyboardManager = KeyboardManager:create()
	
	-- コンフィグを読み込む
	local	config = {}
	config.console = false
	config.window = {}
	config.window.title = "Untitled"
	config.window.width = 800
	config.window.height = 600
	config.window.fullscreen = false
	if type(love.conf) == "function" then love.conf(config) end
	
	if config.console == true then console.open() end
	do
		local	width = config.window.width
		local	height = config.window.height
		if type(width) ~= "number" then width = 800 end
		if type(height) ~= "number" then height = 600 end
		gui.create(width, height)
	end
	if type(config.window.title) == "string" then gui.caption(config.window.title) end
	if config.window.fullscreen then gui.setscreenmode(1) end
	if type(love.load) == "function" then love.load() end
	
	fpsManager:init()
	while true do
		
		local	dtbl = gui.getdropfilelist()
		if dtbl then
			for i, path in ipairs(dtbl) do
				local	file = File:create(path)
				if file:open("r") then
					
					love.filedropped(file)
					file:close()
				end
			end
		end
		
		fpsManager:prev()
		mouseManager:update(fpsManager:getDeltaTime())
		keyboardManager:update(fpsManager:getDeltaTime())
		
		gui.doevents()
		draw.beginscene()
		if type(love.draw) == "function" then
			love.draw()
		end
		
--		fpsManager:draw()
		
		draw.endscene()
		if type(love.update) == "function" then
			love.update(fpsManager:getDeltaTime())
		end
		
		fpsManager:post()
		
		fpsManager:wait()
	end
	if type(love.quit) == "function" then love.quit() end
	if config.console == true then console.close() end
end
