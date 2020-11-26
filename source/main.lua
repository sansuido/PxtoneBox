-- main.lua
require("cocos.init")

local	m_director = nil

local	Director = import(".PxtoneBox.Director")

function love.load()
	m_director = Director:create()
end


function love.update(...)
	m_director:update(...)
end


function love.draw(...)
	m_director:draw(...)
end


function love.mousemoved(...)
	m_director:mousemoved(...)
end


function love.mousepressed(...)
	m_director:mousepressed(...)
end


function love.mousereleased(...)
	m_director:mousereleased(...)
end


function love.keypressed(...)
	m_director:keypressed(...)
end


function love.keyreleased(...)
	m_director:keyreleased(...)
end


function love.wheelmoved(...)
	m_director:wheelmoved(...)
end


function love.filedropped(...)
	if type(m_director:getRunScene().filedropped) == "function" then
		m_director:getRunScene():filedropped(...)
	end
end


function love.resize(...)
	m_director:resize(...)
end

