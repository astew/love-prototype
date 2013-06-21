
local Actor = require "class/Actor"

local Met = Actor:new()

	function Met:new(o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
    end

	function Met:init(level, position)
		local image_info = {}
		image_info.key = "met"
		Actor.init(self, level, image_info, position, {width=16, height=16})

		self.max_velocity = {x=100,y=3000}
		self.acceleration.x = 10000

		self.onDeath_callback = nil

		self:setMaxHealth(50)
		self:setHealth(50)

		self:moveDir(-1)

		self.coll_class = "met"
	end


	function Met:update(dt)
		Actor.update(self, dt)
		
		local floor_continues = false
        local ax,ay = self:getPosition()
        ax = ax + (8*self:getMoveDir())
        ay = ay + 16
        for _, shape in ipairs(self.level:getCollider():shapesAt(ax,ay)) do
			if (self.checkProp(shape, "solid")) then
				floor_continues = true
			end
        end

        if (not floor_continues) then
            self:moveDir(self:getMoveDir()*-1)
        end
		
	end
	
	-----------------HEALTH------------------

	function Met:onDeath()
		--Remove from level
		Actor.removeFromLevel(self)
	end

	-----------------COLLISION-------------------
	function Met:collideWithSolid(dt, me, them, dx, dy)
		-- collision hero entites with level geometry
		me:move(dx*1.1, dy*1.1)
		if (dx ~= 0) then
			self:moveDir(self:getMoveDir()*-1)
			return
		end

		if (dy ~= 0) then
			self:setYVelocity(0)
		end
	end
	
	function Met:collide(dt, me, them, dx, dy)
		
		Actor.collide(self, dt, me, them, dx, dy)
	
		if (them.coll_class) then
			if (them.coll_class == "prop_tile") then
				if (them.properties.hurty) then self:ouch() end
			elseif (them.coll_class == "bullet") then
				self:ouch()
			end
		end
	end

	function Met:ouch()
		self:setYVelocity(-150)
		self:damage(17)
	end
return Met
