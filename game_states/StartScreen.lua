
local GameState = require "class/GameState"


local ImgMgr = require "mgr/ImgMgr"
local UpdateMgr = require "mgr/UpdateMgr"
local IfaceMgr = require "mgr/IfaceMgr"
local KeyMgr = require "mgr/KeyMgr"
local CollisionMgr = require "mgr/CollisionMgr"



local StartScreen = GameState:new()

function StartScreen:load(...)
	print("StartScreen engaged")
	self.end_func = arg[1]
	
	self:setupIfaceMgr()
	self:setupUpdateMgr()
	self:setupKeyMgr()
end

function StartScreen:unload()
	ImgMgr:unloadAll()
	IfaceMgr:removeAll()
	KeyMgr:removeAllBindings()
	UpdateMgr:removeAll()
end


function StartScreen:setupIfaceMgr() 
	love.graphics.setBackgroundColor(0,0,0)
	love.graphics.setColor(255,255,255,255)
	love.draw = function() IfaceMgr:draw() end
	love.mousepressed = function(x,y,button) IfaceMgr:mousePressed(x,y,button) end
	love.mousereleased = function(x,y,button) IfaceMgr:mouseReleased(x,y,button) end
	
	IfaceMgr:addItem(self)
end

function StartScreen:setupUpdateMgr() 
	love.update = function(dt) UpdateMgr:update(dt) end
end

function StartScreen:setupKeyMgr() 
	love.keypressed = function(key, unicode)	KeyMgr:keyPressed(key)	end
	love.keyreleased = function(key, unicode)	KeyMgr:keyReleased(key)	end

	KeyMgr:setPressBinding(" ", self.end_func)
end

function StartScreen:draw()
	love.graphics.clear()
	love.graphics.print("Start Game",100,100)
end

return StartScreen