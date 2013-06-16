
local Actor = require "class/Actor"

local Hero = Actor:new()



	function Hero:init(...)
		self.collider = arg[1]
		
		local x = arg[2]
		local y = arg[3]
		self.shape = self.collider:addRectangle(x,y,16,16)
		self.velocity = {x = 0, y = 1}
		
		
		self.max_speed_x = 500
		self.gravity = 512
		self.ax = 300
		self.bound_left = false
		self.bound_right = false
		self.onDeath_callback = nil
		
		self:setMaxHealth(200)
		self:setHealth(200)
		
		self:setLives(4)
	end
	
	function Hero:draw()
		self.shape:draw("fill")
	end
	
	
	
	function Hero:update(dt)
				self.bound_left = false
				self.bound_right = false
	
				local dx = 0
				local dy = 0
				
				if love.keyboard.isDown("left") and self.bound_left == false then
					self:accelerate(-1 * self.ax*dt,0)
				elseif love.keyboard.isDown("right") and self.bound_right == false then
					self:accelerate(self.ax*dt,0)
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

				if self:getYVelocity() ~= 0 then
					dy = self:getYVelocity()*dt
					self:accelerate(0,self.gravity*dt)
				end

				self:move(dx, dy)
	end
	
	
	function Hero:jump()
		local vx,vy = self:getVelocity()
		if vy == 0 then
			self:setYVelocity(-300 - 0.25*math.abs(vx))
		end
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
	
	
	function Actor:setXPosition(x)
		local xx,yy = self:getPosition()
		self.shape:moveTo(x,yy)
	end
	function Actor:setYPosition(y)	
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
	
	
	function Actor:setXVelocity(vx)
		self.velocity.x = vx
		self:capXSpeed()
	end
	
	function Actor:setYVelocity(vy)
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
		love.event.push('quit') -- Quit the game.
	end
	
return Hero