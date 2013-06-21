


local TiledLevelLib = {}

----------------------------------------------
function TiledLevelLib.hero_spawn(level, x, y, tile)
	local KeyMgr = level:getKeyMgr()
	local imgr = level:getImgMgr()
	
	imgr:loadImage("hero", "res/graphics/ogmo.png")
	imgr:loadImage("bullet", "res/graphics/bullet.png")
	local herolib = require("Hero")
	local hero = herolib:new()
	
	hero:init(level,{x=x,y=y})

	hero.onDeath_callback = function()	hero:setPosition(x,y)	end
	hero.noLives_callback = nil

	local hud = require("HealthHud")
	hud:init(hero)
	level.hud = hud
	
	--add hero to the world
	hero:addToLevel()
	
	-- Set up keys to move hero
	local leftkeys = {left=0,a=0}
	local rightkeys = {right=0,d=0}
	KeyMgr:setPressBinding({up=0,w=0}, 	function() hero:jump() end)
	KeyMgr:setPressBinding(leftkeys, 	function() hero:moveDir(-1) end)
	KeyMgr:setPressBinding(rightkeys, 	function() hero:moveDir(1) end)
	
 	KeyMgr:setPressBinding("s", function() 
		local x,y = hero:getPosition()
		--x needs to be +16 if facing right, -32 if facing left
		if (hero:getFacing() == -1) then x = x - 48 end
		TiledLevelLib.add_bullet(level, x + 16, y, hero:getFacing()) 
	end)
 	KeyMgr:setPressBinding("e", function() hero:use() end)

	KeyMgr:setReleaseBinding(leftkeys, function() 
					if (hero:getMoveDir() == -1) then hero:moveDir(0) end end)
	KeyMgr:setReleaseBinding(rightkeys, function() 
					if (hero:getMoveDir() == 1) then hero:moveDir(0) end end)
					
	level:getEntityTable().hero = hero
end
-----------------------------------------------

function TiledLevelLib.met_spawn(level, x, y, tile)
	local imgr = level:getImgMgr()
	
	imgr:loadImage("met", "res/graphics/met.png")
	local metlib = require("Met")
	local met = metlib:new()
	met:init(level,{x=x,y=y})
	
	met:addToLevel()
	
	--table.insert(level.entities,met)
end

--------------------------------------------------

function TiledLevelLib.bullet_spawn(level, x, y, tile)
	local IfaceMgr = level:getIfaceMgr()
	local UpdateMgr = level:getUpdateMgr()
	local collider = level:getCollider()
	local ImgMgr = level:getImgMgr()
	
	ImgMgr:loadImage("bullet","res/graphics/bullet.png")
	
	local factory = {}
	local time_delta = 0
	
	
	
	factory.update = function(self, dt)
		time_delta = time_delta + dt

		if(time_delta > 0.5) then 
			TiledLevelLib.add_bullet(level, x+16,y+8, 1)
			time_delta = 0
		end
	end

	UpdateMgr:addItem(factory)
end

---------------------------------------------------
function TiledLevelLib.bullet_spawn2(level, x, y, tile)
	local IfaceMgr = level:getIfaceMgr()
	local collider = level:getCollider()
	local ImgMgr = level:getImgMgr()
	
	ImgMgr:loadImage("bullet","res/graphics/bullet.png")
	
	local cannon = collider:addRectangle(x,y,16,16)
	cannon.coll_class = "prop_tile"
	cannon.properties = tile.properties
	cannon.properties.solid = true
	collider:addToGroup("prop_tiles", ctile)
	collider:setPassive(ctile)
	
	cannon.properties.usable = function(hero)
		TiledLevelLib.add_bullet(level, x+18,y+8, 1)
	end

	IfaceMgr:addItem(cannon)
end

-----------------------------------------------------
function TiledLevelLib.add_bullet(level, x, y, dir) 
	local IfaceMgr = level:getIfaceMgr()
	local UpdateMgr = level:getUpdateMgr()
	local collider = level:getCollider()
	local ImgMgr = level:getImgMgr()
	
	local bullet = collider:addRectangle(x,y,16,2)

	bullet.speed = 100 * dir
	bullet.coll_class = "bullet"
	collider:addToGroup("bullets", bullet)

	bullet.update = function(self, dt)
		self:move(dt*self.speed,0)
	end

	bullet.draw = function(self)
		local xx,yy = self:center()
		--self.shape:draw("fill")
		ImgMgr:draw("bullet", xx-8,yy-8)
	end


	bullet.collide = function(self, dt, shape_a, shape_b, dx, dy)
		UpdateMgr:removeItem(self)
		IfaceMgr:removeItem(self)
		collider:remove(self)
	end

	UpdateMgr:addItem(bullet)
	IfaceMgr:addItem(bullet)
end

-------------------------------------------------
function TiledLevelLib.shoot_up(level, x, y, tile)
	local IfaceMgr = level:getIfaceMgr()
	local collider = level:getCollider()
	
	local cannon = collider:addRectangle(x,y,16,16)
	cannon.properties = tile.properties
	collider:setGhost(ctile)
	
	cannon.properties.usable = function(hero)
		hero:setYVelocity(-500)
	end

	IfaceMgr:addItem(cannon)
end
--------------------------------------------------
function TiledLevelLib.changeLevel(level, x, y, tile)
	local IfaceMgr = level:getIfaceMgr()
	local collider = level:getCollider()
	
	local cannon = collider:addRectangle(x,y-16,16,32)
	cannon.properties = tile.properties
	collider:setGhost(ctile)
	
	cannon.properties.usable = function(hero)
		local levelName = tile.properties.level
		
		level:unload()
		local newLevel = level.getTiledLevel():new()
		newLevel:load(levelName)
	end

	IfaceMgr:addItem(cannon)
end

return TiledLevelLib