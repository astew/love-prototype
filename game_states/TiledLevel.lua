
local GameState = require "class/GameState"
local HC = require("lib/HardonCollider")

local IfaceMgr = require("mgr/IfaceMgr")
local UpdateMgr = require("mgr/UpdateMgr")
local KeyMgr = require("mgr/KeyMgr")
local CollisionMgr = require("mgr/CollisionMgr")
local ImgMgr = require("mgr/ImgMgr")
local MapMgr = require("mgr/MapMgr")
local TiledLevelLib = require("game_states/TiledLevelLib")

local TiledLevel = {}

--Tiled maps have the following properties associated with them...
----gravity

TiledLevel.collider = nil
TiledLevel.entities = {}

   function TiledLevel:new(o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
    end
	
	
	function TiledLevel:load(mapFile)
		print("Loading level: ", mapFile)
		MapMgr:loadMap(mapFile)
		
		print("Initializing level geometry")
		self:setupGeometry()
		
		print("Initializing interface")
		self:setupInterface()
		
		print("Initializing entities")
		self:setupEntities()
		
		
	end
	
	
	
	function TiledLevel:setupGeometry()
	
		local coll = 	function(a, b, c, d, e) self:on_collision(a, b, c, d, e) 		end
		local uncoll = 	function(a, b, c) 		self:collision_stop(a, b, c) 	end
		self.collider = HC(64, coll, uncoll)
		
		local addBarriers = function(object)
			local ctile = self.collider:addRectangle(object.x, object.y, 
												object.width, object.height)
			ctile.coll_class = "barrier"
			ctile.properties = {solid = true, jumpable=true}
			self.collider:addToGroup("level_geometry", ctile)
			self.collider:setPassive(ctile)
		end
		
		MapMgr:iterateLayerObjects("collision", addBarriers )
	end
	
	
	function TiledLevel:setupInterface()
	
		--Drawing stuff
		self:_addIfNotNil("background")
		self:_addIfNotNil("ground")
		
		love.draw = function() 
			love.graphics.push()
			love.graphics.scale(1,1)
			MapMgr.map:autoDrawRange(0,0,1)
			if(self.entities.hero) then
				local x,y = self.entities.hero.shape:center()
				x,y = x - love.graphics.getWidth() / 2,y - love.graphics.getHeight() / 2
				love.graphics.translate(-x,-y)
				MapMgr.map:autoDrawRange(-x,-y ,1)
			end
			MapMgr.map:_updateTileRange()
			IfaceMgr:draw() 
			love.graphics.pop()
			if(self.hud) then self.hud:draw() end
		end
		
		--Mouse stuff
		love.mousepressed = function(x,y,button) IfaceMgr:mousePressed(x,y,button) end
		love.mousereleased = function(x,y,button) IfaceMgr:mouseReleased(x,y,button) end
		
		
		--Keyboard stuff
		love.keypressed = function(key, unicode)	KeyMgr:keyPressed(key)	end
		love.keyreleased = function(key, unicode)	KeyMgr:keyReleased(key)	end

		KeyMgr:setPressBinding(" ", 		function() UpdateMgr:togglePause() end)
	end
	

	
	
	function TiledLevel:setupEntities()
		
		local spawnEnt = function(x, y, tile)
			if (tile.properties.entFunc ~= nil) then
				local func = TiledLevelLib[tile.properties.entFunc]
				func(self, x*16, y*16, tile)
			end
		end
		MapMgr:iterateLayerTiles("entities", spawnEnt)
		
		local tileCol = function(x, y, tile)
			local ctile = self.collider:addRectangle(x*16, y*16, 16,16)
			ctile.coll_class = "prop_tile"
			ctile.properties = tile.properties
			self.collider:addToGroup("prop_tiles", ctile)
			self.collider:setPassive(ctile)
		end
		MapMgr:iterateLayerTiles("collision_tiles", tileCol)
		
		self:_addIfNotNil("foreground")
		
		UpdateMgr:addItem(self.collider)
	end
	
	function TiledLevel:on_collision(dt, shape_a, shape_b, dx, dy)
		if(shape_a.parent) then shape_a = shape_a.parent end
		if(shape_b.parent) then shape_b = shape_b.parent end
		
		if (shape_a.collide) then shape_a:collide(dt, shape_a, shape_b,  dx,  dy)	end
		if (shape_b.collide) then shape_b:collide(dt, shape_b, shape_a, -dx, -dy)	end
	end
	
	function TiledLevel:collision_stop(dt, shape_a, shape_b)
		if(shape_a.parent) then shape_a = shape_a.parent end
		if(shape_b.parent) then shape_b = shape_b.parent end
		
		if (shape_a.uncollide) then shape_a:uncollide(dt, shape_a, shape_b)	end
		if (shape_b.uncollide) then shape_b:uncollide(dt, shape_b, shape_a)	end
	end
	
	
	function TiledLevel:unload()
		IfaceMgr:removeAll()
		UpdateMgr:removeAll()
		KeyMgr:removeAllBindings()
		ImgMgr:unloadAll()
		MapMgr:unload()
		
		self.entities = {}
		self.hero = {}
	end

					function TiledLevel:_addIfNotNil(layer)
						if (MapMgr.map(layer) ~= nil) then
							IfaceMgr:addItem(MapMgr.map(layer))
						end
					end
	
	
	------------------------------------------------
	--Most of the rest of these functions are just here
	--As a way of giving entity functions a way of interacting
	--With the level.
	------------------------------------------------
	
	function TiledLevel:getGravity()
		return	MapMgr.map.properties.gravity	
	end
	function TiledLevel:getEntityTable()	return 	self.entities	end
	function TiledLevel:getCollider()		return 	self.collider	end
	function TiledLevel:getMapMgr()			return 	MapMgr			end
	function TiledLevel:getKeyMgr()			return 	KeyMgr			end
	function TiledLevel:getUpdateMgr()		return 	UpdateMgr		end
	function TiledLevel:getIfaceMgr()		return 	IfaceMgr		end
	function TiledLevel:getImgMgr()			return 	ImgMgr			end
	
	function TiledLevel:getICU() return IfaceMgr, self.collider, UpdateMgr end

	function TiledLevel.getTiledLevel() return TiledLevel end
	
return TiledLevel