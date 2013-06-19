

local TiledLevelLib = {}

----------------------------------------------
function TiledLevelLib.hero_spawn(level, x, y, tile)
	local KeyMgr = level:getKeyMgr()
	local IfaceMgr = level:getIfaceMgr()
	local UpdateMgr = level:getUpdateMgr()
	local collider = level:getCollider()
	
	x,y = x*16,y*16
	
	local hero = require("Hero")
	hero:init(collider,x,y)

	hero.onDeath_callback = function()	hero:setPosition(x,y)	end
	hero.noLives_callback = nil

--	hud:init(Hero)
	
	--add hero to the world
	UpdateMgr:addItem(hero)
	IfaceMgr:addItem(hero)
	
	
	-- Set up keys to move hero
	local leftkeys = {left=0,a=0}
	local rightkeys = {right=0,d=0}
	KeyMgr:setPressBinding({up=0,w=0}, 	function() hero:jump() end)
	KeyMgr:setPressBinding(leftkeys, 	function() hero:moveDir(-1) end)
	KeyMgr:setPressBinding(rightkeys, 	function() hero:moveDir(1) end)

	KeyMgr:setReleaseBinding(leftkeys, function() 
					if (hero:getMoveDir() == -1) then hero:moveDir(0) end end)
	KeyMgr:setReleaseBinding(rightkeys, function() 
					if (hero:getMoveDir() == 1) then hero:moveDir(0) end end)
					
	level:getEntityTable().hero = hero
end
-----------------------------------------------



return TiledLevelLib