
local Actor = require "class/Actor"

local Hero = Actor:new()
local ImgMgr = require("mgr/ImgMgr")


	function Hero:init(...)
		self.collider = arg[1]
		
		local x = arg[2]
		local y = arg[3]
		self.shape = self.collider:addRectangle(x,y,16,16)
		ImgMgr:loadImage("hero", "res/graphics/ogmo.png")
		
		self.velocity = {x = 0, y = 1}
		
		
		self.max_speed_x = 500
		self.gravity = 512
		self.ax = 300
		self.onDeath_callback = nil
		
		self:setMaxHealth(200)
		self:setHealth(200)
		
		self:setLives(4)
		
		--the direction the *user* is telling the
		--hero to move
		self.move_dir = 0
		
		
		self.shape.coll_class = "hero"
		self.shape.collide = function(a,b,c,d,e,f) self:collide(b,c,d,e,f) end
	end
	
	function Hero:draw()
		local x,y = self.shape:center()
		ImgMgr:draw("hero", x,y,0,1,1,8,8)
	--	self.shape:draw("fill")
	end
	
	function Hero:update(dt)
	
				local dx = 0
				local dy = 0
				
				if (self.move_dir == -1 or self.move_dir == 1) then
					self:accelerate(self.move_dir * self.ax*dt,0)
				else
					if  ( self:getXVelocity() == 0 ) then
					elseif (math.abs(self:getXVelocity()) < self.ax*dt) then
						self:setXVelocity(0)
					else 
						self:accelerate(-1 * self:xDir() * (self.ax * dt),0)
					end
				end
				
				self:capXSpeed()
				
				dx = self:getXVelocity() * dt

		--		if self:getYVelocity() ~= 0 then
					dy = self:getYVelocity()*dt
					self:accelerate(0,self.gravity*dt)
		--		end

				self:move(dx, dy)
				
	end
	
	
	function Hero:jump()
		if (self.can_jump) then
			self:setYVelocity(-300 - 0.25 * math.abs(self:getXVelocity()))
			self.can_jump = false
		end
	end
	
	function Hero:moveDir(dir)
		self.move_dir = dir
	end
	
	function Hero:getMoveDir()
		return self.move_dir
	end
	
	---------------POSITION/VELOCITY----------------
	
	function Hero:getXPosition()
		local x,y = self.shape:center()
		return x
	end
	
	function Hero:getYPosition()
		local x,y = self.shape:center()
		return y
	end
	
	function Hero:getXVelocity()
		return self.velocity.x
	end
	
	function Hero:getYVelocity()
		return self.velocity.y
	end
	
	function Hero:move(dx, dy)
		self.shape:move(dx,dy)
	end
	
	
	function Hero:setXPosition(x)
		local xx,yy = self:getPosition()
		self.shape:moveTo(x,yy)
	end
	function Hero:setYPosition(y)	
		local xx,yy = self:getPosition()
		self.shape:moveTo(xx,y)
	end
	
	function Hero:setPosition(x,y)
		self.shape:moveTo(x,y)
	end
	
	function Hero:xDir()
		if (self.velocity.x == 0) then
			return 0
		elseif (self.velocity.x > 0) then
			return 1
		else
			return -1
		end
	end
	
	function Hero:accelerate(dvx,dvy)
		self.velocity.x = self.velocity.x + dvx
		self.velocity.y = self.velocity.y + dvy
		self:capXSpeed()
	end
	
	
	function Hero:setXVelocity(vx)
		self.velocity.x = vx
		self:capXSpeed()
	end
	
	function Hero:setYVelocity(vy)
		self.velocity.y = vy
	end
	
	function Hero:capXSpeed()
		if ( math.abs(self.velocity.x) > self.max_speed_x) then
			self.velocity.x = self:xDir() * self.max_speed_x
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
	function Hero:collideWithSolid(dt, shape_a, shape_b, dx, dy)
		
        if (shape_a == self.shape) then
		elseif (shape_b == self.shape) then
			shape_a, shape_b = shape_b, shape_a
			dx, dy = -1*dx, -1*dy
        else
            return
		end
		
		
		-- collision hero entites with level geometry
		shape_a:move(dx*1.1, dy*1.1)

		if (dx ~= 0) then
			self:setXVelocity(0)
		end
		
		if (dy ~= 0) then
			self:setYVelocity(0)
			self.can_jump = (dy < 0)
		end
		
		
		if (shape_b.hurty) then	self:ouch() end
		
	end
	
	function Hero:collide(dt, me, them, dx, dy)
		if (self.checkProp(them, "solid")) then
			self:collideWithSolid(dt, me, them, dx, dy)
		end
	end
	
			function Hero.checkProp(them, prop)
				return	((them.properties ~= nil) and (them.properties[prop]))
			end
			
	function Hero:endCollideWithSolid(dt, shape_a, shape_b)
		if self:getYVelocity() == 0 then
			--self:setYVelocity(1)
		end
	end
	
	function Hero:ouch()
		self:setYVelocity(-150)
		self:damage(17)
	end
return Hero
