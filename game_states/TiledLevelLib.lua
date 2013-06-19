

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
	local b_count = 0
	local add_bullet = function() 
		b_count = b_count + 1
		local bullet = {}

		bullet.speed = 100
		bullet.shape = collider:addRectangle(x*16+16,y*16+8,16,2)
		bullet.shape.coll_class = "bullet"
		bullet.shape.parent = bullet

		bullet.update = function(self, dt)
			self.shape:move(dt*100,0)
		end

		bullet.draw = function(self)
			local x,y = self.shape:center()
			self.shape:draw("fill")
			ImgMgr:draw("bullet", x-8,y-8)
		end


		bullet.shape.collide = function(self, dt, shape_a, shape_b, dx, dy)
			local parent = self.parent
			UpdateMgr:removeItem(parent)
			IfaceMgr:removeItem(parent)
			collider:remove(self)
		end

		UpdateMgr:addItem(bullet)
		IfaceMgr:addItem(bullet)
	end
	
	
	factory.update = function(self, dt)
		time_delta = time_delta + dt

		if(time_delta > 0.5) then
			add_bullet()
			time_delta = 0
		end
	end

	UpdateMgr:addItem(factory)
end


return TiledLevelLib