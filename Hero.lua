
local Actor = require "class/Actor"

local Hero = Actor:new()

	function Hero:new(o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
    end

	function Hero:init(level, position)
		local image_info = {}
		image_info.key = "hero"
		Actor.init(self, level, image_info, position, {width=16, height=16})

		
		self.max_velocity.x = 500
		self.max_velocity.y = 3000
		self.acceleration.x = 300
		self.onDeath_callback = nil
		
		self:setMaxHealth(200)
		self:setHealth(200)
		self:setLives(4)
		
		self.coll_class = "hero"
	end
	
	------------HERO ACTIONS---------------
	
	-----------Jump stuff
	function Hero:jump()
		if (self:canJump()) then
			self:setYVelocity(-300 - 0.25 * math.abs(self:getXVelocity()))
		end
	end
	
	function Hero:canJump()
		local c = self.level:getCollider()
		local x,y = self:getPosition()
		local shapes = c:shapesAt(x,y+10)
		for _, shape in ipairs(shapes) do
			if (self.checkProp(shape, "solid")) then return true	end
		end
	end
	
	-------------Use stuff
	function Hero:canUse()
		local c = self.level:getCollider()
		local x,y = self:getPosition()
		local shapes = c:shapesAt(x,y)
		for _, shape in ipairs(shapes) do
			if (self.checkProp(shape, "usable")) then 
				return shape
			end
		end
		
		x = x + 16*self:getFacing()
		shapes = c:shapesAt(x,y)
		for _, shape in ipairs(shapes) do
			if (self.checkProp(shape, "usable")) then 
				return shape
			end
		end
	end
	
	function Hero:use()
		local shape = self:canUse()
		if (shape) then
			shape.properties.usable(self)
		end
	end
	
	-----------------HEALTH------------------
	
	function Hero:setLives(v)
		self.lives = v
	end
	
	function Hero:getLives()
		return self.lives
	end
	
	function Hero:onDeath()
		self:setHealth(self:getMaxHealth())
		self.lives = self.lives - 1
		
		if (self.lives == -1) then
			self:onNoLives()
		end
		
		if (self.onDeath_callback ~= nil) then
			self.onDeath_callback()
		end
	end
	
	function Hero:onNoLives()
		if (self.noLives_callback ~= nil) then
			self.noLives_callback()
		end
	end
	
	-----------------COLLISION-------------------

	function Hero:collide(dt, me, them, dx, dy)
		
		if (them.coll_class ~= nil and them.coll_class == "prop_tile") then
			if (them.properties.hurty) then self:ouch(dx,dy) end
		end
	
		Actor.collide(self, dt, me, them, dx, dy)
	
		if (them.coll_class == "met") then
			cx,cy = self.diff(me,them)
			self:setYVelocity(-200)
			if(cx > 0) then self:setXVelocity(-250)
			elseif (cx < 0) then self:setXVelocity(250) end
			self:damage(5)
			self:move(dx*1.1,dy*1.1)
		elseif (them.coll_class == "bullet") then
			cx,cy = self.diff(me,them)
			self:setYVelocity(-200)
			self:damage(5)
			self:move(dx*1.1,dy*1.1)
		end
	end
	
	function Hero:ouch(dx, dy)
		self:setYVelocity(-150)
		self:damage(17)
		self:move(dx*1.1,dy*1.1)
	end
return Hero
