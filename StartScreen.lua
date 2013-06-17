
local GameState = require "class/GameState"
local ImgMgr = require "mgr/ImgMgr"
local UpdateMgr = require "mgr/UpdateMgr"
local IfaceMgr = require "mgr/IfaceMgr"
local KeyMgr = require "mgr/KeyMgr"
local CollisionMgr = require "mgr/CollisionMgr"



local StartScreen = GameState:new()

function StartScreen:load(...)
	
end

function StartScreen:unload()

end


return StartScreen