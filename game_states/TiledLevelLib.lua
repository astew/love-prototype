

local TiledLevelLib = {}

----------------------------------------------
function TiledLevelLib.hero_spawn(level, x, y, tile)
	local KeyMgr = level:getKeyMgr()
	local IfaceMgr = level:getIfaceMgr()
	local UpdateMgr = level:getUpdateMgr()
	local collider = level:getCollider()
	
	x,y = x*16,y*16
	
	local herolib = require("Hero")
	local hero = herolib:new()
	hero:init(collider,x,y)

	hero.onDeath_callback = function()	hero:setPosition(x,y)	end
	hero.noLives_callback = nil

	local hud = require("HealthHud")
	hud:init(hero)
	level.hud = hud
	
	--add hero to the world
	UpdateMgr:addItem(hero)
	IfaceMgr:addItem(hero)
	
	
	-- Set up keys to move hero
	local leftkeys = {left=0,a=0}
	local rightkeys = {right=0,d=0}
	KeyMgr:setPressBinding({up=0,w=0}, 	function() hero:jump() end)
	KeyMgr:setPressBinding(leftkeys, 	function() hero:moveDir(-1) end)
	KeyMgr:setPressBinding(rightkeys, 	function() hero:moveDir(1) end)
	
	KeyMgr:setPressBinding("s", function() TiledLevelLib.add_bullet(level,hero:getXPosition() + 16, hero:getYPosition()) end)

	KeyMgr:setReleaseBinding(leftkeys, function() 
					if (hero:getMoveDir() == -1) then hero:moveDir(0) end end)
	KeyMgr:setReleaseBinding(rightkeys, function() 
					if (hero:getMoveDir() == 1) then hero:moveDir(0) end end)
					
	level:getEntityTable().hero = hero
end
-----------------------------------------------

function TiledLevelLib.met_spawn(level, x, y, tile)
	local IfaceMgr = level:getIfaceMgr()
	local UpdateMgr = level:getUpdateMgr()
	local collider = level:getCollider()
	
	x,y = x*16,y*16
	local metlib = require("Met")
	local met = metlib:new()
	met:init(collider,x,y)
	
	UpdateMgr:addItem(met)
	IfaceMgr:addItem(met)
	
	met.onDeath_callback = function()
		UpdateMgr:removeItem(met)
		IfaceMgr:removeItem(met)
		collider:remove(met.shape)
	end
	
	table.insert(level.entities,met)
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
			TiledLevelLib.add_bullet(level, x*16+16,y*16+8)
			time_delta = 0
		end
	end

	UpdateMgr:addItem(factory)
end

-----------------------------------------------------
function TiledLevelLib.add_bullet(level, x, y) 
	local IfaceMgr = level:getIfaceMgr()
	local UpdateMgr = level:getUpdateMgr()
	local collider = level:getCollider()
	local ImgMgr = level:getImgMgr()
	
	local bullet = collider:addRectangle(x,y,16,2)

	bullet.speed = 100
	bullet.coll_class = "bullet"
	collider:addToGroup("bullets", bullet)

	bullet.update = function(self, dt)
		self:move(dt*100,0)
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


return TiledLevelLib