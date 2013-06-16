local loader = require("lib/Advanced-Tiled-Loader/Loader")
loader.path = "res/maps/"

local HC = require("lib/HardonCollider")

local hud = require("HealthHud")
local IfaceMgr = require("mgr/IfaceMgr")
local UpdateMgr = require("mgr/UpdateMgr")
local KeyMgr = require("mgr/KeyMgr")

local hero
local collider
local allSolidTiles
local heart_icon

function love.load() 

    print("Started")
    map = loader.load("level.tmx")
    collider = HC(64, on_collide, collision_stop)
    allSolidTiles = findSolidTiles(map)
	heart_icon = love.graphics.newImage("res/graphics/heart.png")
    setupHero(32,32)
	hud:init(Hero, heart_icon)
	
	setupIfaceMgr()
	setupUpdateMgr()
	setupKeyMgr()
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
	UpdateMgr:addItem(collider)
	UpdateMgr:addItem(Hero)
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
	
	local stopMv = function() Hero:moveDir(0)	end
	KeyMgr:setReleaseBinding(leftkeys, stopMv)
	KeyMgr:setReleaseBinding(rightkeys, stopMv)
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
            ctile.type = "tile"
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



function on_collide(dt, shape_a, shape_b, dx, dy)
    if (shape_a == Hero.shape or shape_b == Hero.shape) then
        collideHeroWithTile(dt, shape_a, shape_b, dx, dy)
    end
end

function collideHeroWithTile(dt, shape_a, shape_b, dx, dy)
	
	if (shape_b == Hero.shape) then
		shape_a, shape_b = shape_b, shape_a
		dx, dy = -1*dx, -1*dy
	end
	
    -- collision hero entites with level geometry
    if shape_b.type == "tile" then
	
        if shape_b.hurty then
			ouch(dt, shape_a, shape_b, dx, dy)
        end
		
        shape_a:move(dx, dy)
		
        diff_x, diff_y = get_diff(shape_a, shape_b)

        if math.abs(dy) > math.abs(dx) then
            if dy < 0 then
                Hero:setYVelocity(0)
            else
				Hero:setYVelocity(1)
            end
        end

        if Hero:getYVelocity() ~= 0 or math.abs(diff_y) <= 0 then
            if diff_x > 0 then
                Hero.bound_left = true
            elseif diff_x < 0 then
                Hero.bound_right = true
            end
        end
    else
        return
    end
end

function get_diff(shape_a, shape_b)
	local ax, ay = shape_a:center()
    local bx, by = shape_b:center()
	return ax - bx, ay - by
end

function ouch(dt, player, block, dx, dy)
	print("ouchy!")
	Hero:setYVelocity(-150)
	Hero:damage(17)
end


function collision_stop()
    if Hero:getYVelocity() == 0 then
        Hero:setYVelocity(1)
    end
end
