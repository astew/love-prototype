local loader = require("lib/Advanced-Tiled-Loader/Loader")
loader.path = "res/maps/"

local HC = require("lib/HardonCollider")

local hud = require("HealthHud")
local IfaceMgr = require("mgr/IfaceMgr")
local UpdateMgr = require("mgr/UpdateMgr")
local KeyMgr = require("mgr/KeyMgr")
local CollisionMgr = require("mgr/CollisionMgr")
local ImgMgr = require("mgr/ImgMgr")

local hero
local collider
local allSolidTiles
local heart_icon
local b_count = 0

function love.load() 

    print("Started")
    map = loader.load("level.tmx")
    collider = HC(64, on_collide, collision_stop)
    allSolidTiles = findSolidTiles(map)
	
	ImgMgr:loadImage("bullet", 	"res/graphics/bullet.png")
	
    setupHero(32,32)
	hud:init(Hero)
	
	setupIfaceMgr()
	setupUpdateMgr()
	setupKeyMgr()
	setupCollisionMgr()
	
	create_bullet_factory()
end

function setupHero(x, y)
	Hero = require("Hero")
	Hero:init(collider,x,y)
	
	Hero.onDeath_callback = function()	Hero:setPosition(32,32)	end
end


function setupIfaceMgr()
	IfaceMgr:addItem(map)
	IfaceMgr:addItem(collider)
	IfaceMgr:addItem(Hero)
	IfaceMgr:addItem(hud)
	love.draw = function() IfaceMgr:draw() end
	love.mousepressed = function(x,y,button) IfaceMgr:mousePressed(x,y,button) end
	love.mousereleased = function(x,y,button) IfaceMgr:mouseReleased(x,y,button) end
end

function setupUpdateMgr()
	UpdateMgr:addItem(Hero)
	UpdateMgr:addItem(collider)
	love.update = function(dt) UpdateMgr:update(dt) end
	love.focus = function(f)
		if (not f) then	UpdateMgr:pause()	end
	end
	
	UpdateMgr:unpause()
end

function setupKeyMgr()
	love.keypressed = function(key, unicode)	KeyMgr:keyPressed(key)	end
	love.keyreleased = function(key, unicode)	KeyMgr:keyReleased(key)	end
	
	local leftkeys = {left=0,a=0}
	local rightkeys = {right=0,d=0}
	
	KeyMgr:setPressBinding({up=0,w=0}, function() Hero:jump() end)
	KeyMgr:setPressBinding(" ", function() UpdateMgr:togglePause() end)
	KeyMgr:setPressBinding(leftkeys, function() Hero:moveDir(-1) end)
	KeyMgr:setPressBinding(rightkeys, function() Hero:moveDir(1) end)
	
	KeyMgr:setReleaseBinding(leftkeys, function() if (Hero:getMoveDir() == -1) then Hero:moveDir(0) end end)
	KeyMgr:setReleaseBinding(rightkeys, function() if (Hero:getMoveDir() == 1) then Hero:moveDir(0) end end)
end

function setupCollisionMgr()
	CollisionMgr:init(collider)
	
	CollisionMgr:setCallbacks("hero", "tile", on_collide, collision_stop)
end

function love.quit()
    print("Ended")
end

function findSolidTiles(map)
    local collidable_tiles = {}
    local layer = map.layers["ground"]

    for x, y, tile in map("ground"):iterate() do
        if tile and tile.properties.solid then
            local ctile = collider:addRectangle(x*16, y*16, 16, 16)
         --   ctile.type = "tile"
			ctile.coll_class = "tile"
            collider:addToGroup("tiles", ctile)
            collider:setPassive(ctile)
            if tile.properties.hurty then
                ctile.hurty = true
            end
            table.insert(collidable_tiles, ctile)
        end
    end

    return collidable_tiles
end

function add_bullet()
	b_count = b_count + 1
	local bullet = {}
	
	bullet.speed = 100
	bullet.shape = collider:addPoint(32,200)
	bullet.shape.coll_class = "bullet" .. b_count
	
	bullet.update = function(self, dt)
		self.shape:move(dt*100,0)
	end
	
	bullet.draw = function(self)
		local x,y = self.shape:center()
		ImgMgr:draw("bullet", x-16,y)
	end
	
	
	local on_collide = function(dt, shape_a, shape_b, dx, dy)
		UpdateMgr:removeItem(bullet)
		IfaceMgr:removeItem(bullet)
		collider:remove(bullet.shape)
		CollisionMgr:setCallbacks(bullet.shape.coll_class, "tile", nil, nil)
		CollisionMgr:setCallbacks(bullet.shape.coll_class, "hero", nil, nil)
	end
	
	local hero_collide = function(dt, shape_a, shape_b, dx, dy)
		
		Hero:setYVelocity(-350)
		Hero:damage(45)
		UpdateMgr:removeItem(bullet)
		IfaceMgr:removeItem(bullet)
		collider:remove(bullet.shape)
		CollisionMgr:setCallbacks(bullet.shape.coll_class, "tile", nil, nil)
		CollisionMgr:setCallbacks(bullet.shape.coll_class, "hero", nil, nil)
	end
	
	
	UpdateMgr:addItem(bullet)
	IfaceMgr:addItem(bullet)
	CollisionMgr:setCallbacks(bullet.shape.coll_class, "tile", on_collide)
	CollisionMgr:setCallbacks(bullet.shape.coll_class, "hero", hero_collide)
end

function create_bullet_factory()
	local factory = {}
	local time_delta = 0
	factory.update = function(self, dt)
		time_delta = time_delta + dt
		
		if(time_delta > 0.5) then
			add_bullet()
			time_delta = 0
		end
	end
	
	UpdateMgr:addItem(factory)
end


function on_collide(dt, shape_a, shape_b, dx, dy)
	Hero:collideWithSolid(dt, shape_a, shape_b, dx, dy)
end


function get_diff(shape_a, shape_b)
	local ax, ay = shape_a:center()
    local bx, by = shape_b:center()
	return ax - bx, ay - by
end

function ouch()
	Hero:setYVelocity(-150)
	Hero:damage(17)
end


function collision_stop()
    Hero:endCollideWithSolid()
end
