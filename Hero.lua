
local Actor = require "class/Actor"
local AnAL = require "lib/AnAL"
local ImgMgr = require "mgr/ImgMgr"

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
		Actor.init(self, level, image_info, position, {width=32, height=32})

		
		self.max_velocity.x = 200
		self.max_velocity.y = 3000
		self.acceleration.x = 3300
		self.onDeath_callback = nil
		
		self:setMaxHealth(200)
		self:setHealth(200)
		self:setLives(4)
		
		self.coll_class = "hero"
		
		local img = love.graphics.newImage("res/graphics/mmrun.png")
		self.anim = newAnimation(img, 44, 44, 0.1, 10)
		self.anim.scale = 32/44
	end
	
	-----------DRAW--------
	function Hero:draw()
		
		local img = self.level:getImgMgr()
		local x,y = self:getPosition()
		local w,h = self:getSize()
		
		if ( (not self:getFacingReverseDraw()) or self:getFacing() == -1 ) then
			self.anim:draw(x,y,0,self.anim.scale,self.anim.scale,22,22)
		else
			self.anim:draw(x,y,0,-self.anim.scale,self.anim.scale,22,22)
		end
	end
	
	function Hero:update(dt)
		local dx = 0
		local dy = 0
		local move_dir = self:getMoveDir()
		local xdir, ydir = self:getXYDir()
		
		if (move_dir == -1 or move_dir == 1) then
			self:accelerate(move_dir * self.acceleration.x*dt,0)
			self.anim:update(dt) 
		else
			if  ( self:getXVelocity() == 0 ) then
			elseif (math.abs(self:getXVelocity()) < self.acceleration.x*dt) then
				self:setXVelocity(0)
				self.anim:reset()
			else 
				self:accelerate(-1 * xdir * (self.acceleration.x * dt),0)
				self.anim:update(dt) 
			end
		end
		
		self:capVelocity()
		
		dx = self:getXVelocity() * dt
		dy = self:getYVelocity()*dt
		self:accelerate(0,self:levelGravity()*dt)

		self:move(dx, dy)
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
