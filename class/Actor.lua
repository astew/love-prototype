

local Actor = {}


Actor.health = {}
Actor.health.max = 1
Actor.health.current = 1

   function Actor:new(o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
    end

	--Take any necessary steps to initialize the Actor
	function Actor:init(...)	end
	
	--Take any necessary steps to draw the Actor on the display
	function Actor:draw()	end
	
	function Actor:update(dt)	end
	
------------POSITION/VELOCITY RELATED-----------

	function Actor:getXPosition()	return 0	end
	function Actor:getYPosition()	return 0	end
	function Actor:getPosition()
		return self:getXPosition(), self:getYPosition()
	end
	
	function Actor:getXVelocity()	return 0	end
	function Actor:getYVelocity()	return 0	end
	function Actor:getVelocity()
		return self:getXVelocity(), self:getYVelocity()
	end
	
	function Actor:move(dx, dy)	end
	function Actor:setXPosition(x)	end
	function Actor:setYPosition(y)	end
	function Actor:setPosition(x, y) 
		self:setXPosition(x)
		self:setYPosition(y)
	end
	
	function Actor:accelerate(dvx, dvy)	end
	function Actor:setXVelocity(vx)	end
	function Actor:setYVelocity(vy)	end
	function Actor:setVelocity(vx, vy) 
		self:setXVelocity(vx)
		self:setYVelocity(vy)
	end
	
	
---------------HEALTH RELATED-----------------
	function Actor:getHealth()
		return self.health.current
	end
	
	function Actor:getMaxHealth()
		return self.health.max
	end
	
	function Actor:setHealth(v)
		self.health.current = v
		
		if(Actor:getHealth() <= 0) then
			self:onDeath()
		end
	end
	
	function Actor:setMaxHealth(v)
		self.health.max = v
	end
	
	function Actor:damage(v)
		self:deltaHealth(-1*v)
		print("Damaged..")
	end
	function Actor:heal(v)
		self:deltaHealth(v)
	end
	function Actor:deltaHealth(v)
		self:setHealth(self:getHealth() + v)
	end
	
	function Actor:onDeath()	end
	
return Actor