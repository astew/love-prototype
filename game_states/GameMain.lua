
local GameState = require "class/GameState"

local HC = require("lib/HardonCollider")

local hud = require("HealthHud")
local IfaceMgr = require("mgr/IfaceMgr")
local UpdateMgr = require("mgr/UpdateMgr")
local KeyMgr = require("mgr/KeyMgr")
local CollisionMgr = require("mgr/CollisionMgr")
local ImgMgr = require("mgr/ImgMgr")
local MapMgr = require("mgr/MapMgr")

local collider
local allSolidTiles
local heart_icon
local b_count = 0

local GameMain = GameState:new()

function GameMain:load(...)

	self.done_callback = arg[1]

    print("Started")
    MapMgr:loadMap("level2.tmx")
    collider = HC(64, on_collide, collision_stop)
    allSolidTiles = self:findSolidTiles(map)

	ImgMgr:loadImage("bullet", 	"res/graphics/bullet.png")

    self:positionActors()

	self:setupIfaceMgr()
	self:setupUpdateMgr()
	self:setupKeyMgr()
	self:setupCollisionMgr()

	self:create_bullet_factory()
end

function GameMain:setupMet(x,y)
	Met = require("Met")
	Met:init(collider,x,y)

	Met.onDeath_callback = function()	Met:setPosition(x,y)	end
	Met.noLives_callback = self.done_callback
end

function GameMain:setupHero(x, y)
	Hero = require("Hero")
	Hero:init(collider,x,y)

	Hero.onDeath_callback = function()	Hero:setPosition(x,y)	end
	Hero.noLives_callback = self.done_callback

	hud:init(Hero)
end


function GameMain:setupIfaceMgr()
	IfaceMgr:addItem(MapMgr.map)
	IfaceMgr:addItem(collider)
	IfaceMgr:addItem(Hero)
    IfaceMgr:addItem(Met)
	IfaceMgr:addItem(hud)
	love.draw = function() IfaceMgr:draw() end
	love.mousepressed = function(x,y,button) IfaceMgr:mousePressed(x,y,button) end
	love.mousereleased = function(x,y,button) IfaceMgr:mouseReleased(x,y,button) end
end

function GameMain:setupUpdateMgr()
	love.update = function(dt) UpdateMgr:update(dt) end
	love.focus = function(f)
		if (not f) then	UpdateMgr:pause()	end
	end


	UpdateMgr:addItem(Hero)
    UpdateMgr:addItem(Met)
	UpdateMgr:addItem(collider)

	UpdateMgr:unpause()
end

function GameMain:setupKeyMgr()
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

function GameMain:setupCollisionMgr()
	CollisionMgr:init(collider)

	local coll = function(dt,a,b,dx,dy)	self:on_collide(dt,a,b,dx,dy) end
	local uncoll = function(dt,a,b)	self:collision_stop(dt,a,b) end

	CollisionMgr:setCallbacks("hero", "tile", coll, uncoll)
	CollisionMgr:setCallbacks("met", "tile", coll, uncoll)
end

function GameMain:findSolidTiles()
    local collidable_tiles = {}
    MapMgr:iterateLayerTilesByType("ground", "solid", function(x, y, tile)
        local ctile = collider:addRectangle(x*16, y*16, 16, 16)
        ctile.coll_class = "tile"
        collider:addToGroup("tiles", ctile)
        collider:setPassive(ctile)
        if tile.properties.hurty then
            ctile.hurty = true
        end
        table.insert(collidable_tiles, ctile)
    end)
    return collidable_tiles
end

function GameMain:positionActors()
    local entity_tiles = {}
    MapMgr:iterateLayerTilesByType("entities", "actor", function(x, y, tile)
        if tile.properties.hero then
            GameMain:setupHero(x*16, y*16)
        end

        if tile.properties.met then
            GameMain:setupMet(x*16, y*16)
        end
    end)
    return entity_tiles
end

function GameMain:add_bullet()
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

function GameMain:create_bullet_factory()
	local factory = {}
	local time_delta = 0
	local sself = self
	factory.update = function(self, dt)
		time_delta = time_delta + dt

		if(time_delta > 0.5) then
			sself:add_bullet()
			time_delta = 0
		end
	end

	UpdateMgr:addItem(factory)
end


function GameMain:on_collide(dt, shape_a, shape_b, dx, dy)
	Hero:collideWithSolid(dt, shape_a, shape_b, dx, dy)
    Met:collideWithSolid(dt, shape_a, shape_b, dx, dy)
end


function GameMain:get_diff(shape_a, shape_b)
	local ax, ay = shape_a:center()
    local bx, by = shape_b:center()
	return ax - bx, ay - by
end


function GameMain:collision_stop()
    Hero:endCollideWithSolid()
end


function GameMain:unload()
	ImgMgr:unloadAll()
	IfaceMgr:removeAll()
	KeyMgr:removeAllBindings()
	UpdateMgr:removeAll()
end

return GameMain
