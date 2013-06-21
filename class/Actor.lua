
--An Actor is an entity which moves around in a level, can be drawn,
--and has health
--
--There is no requirement on what causes the entity to move around,
--But this class will handle basic movement and drawing. Entities 
--wishing to draw or move in a different way need only override
--The appropriate functions.

local Actor = {}

	

   function Actor:new(o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
    end

	
	function Actor:init(level, image_info, position, size)
	
		self.level = level
		self.image_info = image_info
		self.size = size
	
		--Create the shape
		self.shape = level:getCollider():addRectangle(
				position.x, position.y, 
				size.width, size.height)
		--Now, get rid of it (wish it was easier to directly create a rect..)
		level:getCollider():remove(self.shape)
		self.shape.parent = self
		
	
		self.health = {}
		self.health.max = 1
		self.health.current = 1
		
		--max speed
		self.max_velocity = {x = 100, y = 300}
		
		--velocity
		self.velocity = {x=0,y=0}
		
		--acceleration
		self.acceleration = {x=100,y=0}
		
		--move_dir -- the direction the actor should be moving
		self:moveDir(0)
		
		--facing dir
		self:setFacing(1)  --facing right by default
		self:setFacingReverseDraw(true)
		
		--collision class
		self.coll_class = "actor"
		
	end
	
	function Actor:addToLevel()
		local i,c,u = self.level:getICU()
		
		c:addShape(self.shape)
		i:addItem(self)
		u:addItem(self)
	end
	
	function Actor:removeFromLevel()
		local i,c,u = self.level:getICU()
		
		c:remove(self.shape)
		i:removeItem(self)
		u:removeItem(self)
	end
	
	--Take any necessary steps to draw the Actor on the display
	function Actor:draw()
		local img = self.level:getImgMgr()
		local x,y = self:getPosition()
		local w,h = self:getSize()
		
		if ( (not self:getFacingReverseDraw()) or self:getFacing() == 1 ) then
			img:draw(self.image_info.key, x-w/2, y-h/2)
		else
			img:draw(self.image_info.key, (x+w/2), y-h/2, 0, -1, 1, 0, 0)
		end
		
	end
	
	--Update this actor. This will do basic movement.
	function Actor:update(dt)
		local dx = 0
		local dy = 0
		local move_dir = self:getMoveDir()
		local xdir, ydir = self:getXYDir()
		
		if (move_dir == -1 or move_dir == 1) then
			self:accelerate(move_dir * self.acceleration.x*dt,0)
		else
			if  ( self:getXVelocity() == 0 ) then
			elseif (math.abs(self:getXVelocity()) < self.acceleration.x*dt) then
				self:setXVelocity(0)
			else 
				self:accelerate(-1 * xdir * (self.acceleration.x * dt),0)
			end
		end
		
		self:capVelocity()
		
		dx = self:getXVelocity() * dt
		dy = self:getYVelocity()*dt
		self:accelerate(0,self:levelGravity()*dt)

		self:move(dx, dy)
	end
	

	
	
------------POSITION/VELOCITY RELATED-----------

	-----size
	function Actor:getWidth()
		return self.size.width
	end
	function Actor:getHeight()
		return self.size.height
	end
	function Actor:getSize()
		return self:getWidth(), self:getHeight()
	end

	-----position
	function Actor:center() return self:getPosition() end
	function Actor:getXPosition()
		local x,y = self:getPosition()
		return x
	end
	function Actor:getYPosition()	
		local x,y = self:getPosition()
		return y
	end
	function Actor:getPosition()
		return self.shape:center()
	end
	
	
	-----velocity
	function Actor:getXVelocity()
		return self.velocity.x
	end
	function Actor:getYVelocity()	
		return self.velocity.y
	end
	function Actor:getVelocity()
		return self:getXVelocity(), self:getYVelocity()
	end
	
	
	-----movement
	function Actor:move(dx, dy)
		self.shape:move(dx,dy)
	end
	function Actor:setXPosition(x)
		self.shape:moveTo(x, self:getYPosition())
	end
	function Actor:setYPosition(y)
		self.shape:moveTo(self:getXPosition(), y)
	end
	function Actor:setPosition(x, y) 
		self:setXPosition(x)
		self:setYPosition(y)
	end
	function Actor:getXYDir()
		local vx,vy= self:getVelocity()
		if(vx < 0) then vx = -1 elseif (vx > 0) then vx = 1 else vx = 0 end
		if(vy < 0) then vy = -1 elseif (vy > 0) then vy = 1 else vy = 0 end
		return vx, vy
	end
	
	function Actor:moveDir(dir)
		self.move_dir = dir
		if(dir ~= 0) then self:setFacing(dir) end
	end
	
	function Actor:getMoveDir()
		return self.move_dir
	end
	
	-----facing
	function Actor:setFacing(dir)
		self.facing = dir
	end
	
	function Actor:getFacing()
		return self.facing
	end
	
	function Actor:setFacingReverseDraw(bool)
		self.facing_draw = bool
	end
	
	function Actor:getFacingReverseDraw()
		return self.facing_draw
	end
	
	-----acceleration
	function Actor:accelerate(dvx, dvy)
		self:setXVelocity(self:getXVelocity() + dvx)
		self:setYVelocity(self:getYVelocity() + dvy)
	end
	function Actor:setXVelocity(vx)	self.velocity.x = vx	self:capVelocity()	end
	function Actor:setYVelocity(vy)	self.velocity.y = vy	self:capVelocity()	end
	function Actor:setVelocity(vx, vy) 
		self:setXVelocity(vx)
		self:setYVelocity(vy)
	end
	
	function Actor:capVelocity()
		local vx, vy = self:getVelocity()
		local xd, yd = self:getXYDir()
		if (math.abs(vx) > self.max_velocity.x) then
			self:setXVelocity(self.max_velocity.x * xd)
		end
		if( math.abs(vy) > self.max_velocity.y) then
			self:setYVelocity(self.max_velocity.y * yd)
		end
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
		
		if(self:getHealth() <= 0) then
			self:onDeath()
		end
	end
	
	function Actor:setMaxHealth(v)
		self.health.max = v
	end
	
	function Actor:damage(v)
		self:deltaHealth(-1*v)
	end
	function Actor:heal(v)
		self:deltaHealth(v)
	end
	function Actor:deltaHealth(v)
		self:setHealth(self:getHealth() + v)
	end
	
	-- No default behavior is defined
	function Actor:onDeath()	end
	
	
	---------COLLISION STUFF------------
	--Only default collision action is to not pass
	--through solids
	function Actor:collide(dt, me, them, dx, dy)
		if (self.checkProp(them, "solid")) then
			self:collideWithSolid(dt, me, them, dx, dy)
			return true
		end
	end
	
	function Actor:collideWithSolid(dt, me, them, dx, dy)
			me:move(dx*1.1, dy*1.1)
			if (dx ~= 0) then	self:setXVelocity(0)	end
			if (dy ~= 0) then	self:setYVelocity(0)	end
	end
	
	
	
	----------HELPER FUNCTIONS------------
	function Actor.diff(shape_a, shape_b)
		local ax,ay = shape_a:center()
		local bx,by = shape_b:center()
		return bx-ax,by-ay
	end
	
	function Actor:levelGravity()
		return self.level:getGravity()
	end
	
	function Actor.checkProp(them, prop)
		return	((them.properties ~= nil) and (them.properties[prop]))
	end
	
	
	
	
return Actor