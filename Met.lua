
local Actor = require "class/Actor"

local Met = Actor:new()
local ImgMgr = require("mgr/ImgMgr")


	function Met:init(...)
		self.collider = arg[1]

		local x = arg[2]
		local y = arg[3]
		self.shape = self.collider:addRectangle(x,y,16,16)
		ImgMgr:loadImage("met", "res/graphics/met.png")

		self.velocity = {x = 100, y = 1}
        self.gravity = 512

		self.max_speed_x = 100
		self.onDeath_callback = nil

		self:setMaxHealth(50)
		self:setHealth(50)

		self:setLives(1)

		self.move_dir = -1

		self.shape.coll_class = "met"
	end

	function Met:draw()
		local x,y = self.shape:center()
		ImgMgr:draw("met", x,y,0,1,1,8,8)
	--	self.shape:draw("fill")
	end

	function Met:update(dt)

        local dx = 0
        local dy = 0

        if (self:getMoveDir() ~= 0) then
            self:setXVelocity(self:getMoveDir() * self.max_speed_x)
        end

        self:capXSpeed()

        dx = self:getXVelocity()*dt
        dy = self:getYVelocity()*dt
        self:accelerate(0,self.gravity*dt)

        self:move(dx, dy)

	end


	function Met:moveDir(dir)
		self.move_dir = dir
	end

	function Met:getMoveDir()
		return self.move_dir
	end

	---------------POSITION/VELOCITY----------------

	function Met:getXPosition()
		local x,y = self.shape:center()
		return x
	end

	function Met:getYPosition()
		local x,y = self.shape:center()
		return y
	end

	function Met:getXVelocity()
		return self.velocity.x
	end

	function Met:getYVelocity()
		return self.velocity.y
	end

	function Met:move(dx, dy)
		self.shape:move(dx,dy)
	end


	function Met:setXPosition(x)
		local xx,yy = self:getPosition()
		self.shape:moveTo(x,yy)
	end
	function Met:setYPosition(y)
		local xx,yy = self:getPosition()
		self.shape:moveTo(xx,y)
	end

	function Met:setPosition(x,y)
		self.shape:moveTo(x,y)
	end

	function Met:xDir()
		if (self.velocity.x == 0) then
			return 0
		elseif (self.velocity.x > 0) then
			return 1
		else
			return -1
		end
	end

	function Met:accelerate(dvx,dvy)
		self.velocity.x = self.velocity.x + dvx
		self.velocity.y = self.velocity.y + dvy
		self:capXSpeed()
	end

	function Met:setXVelocity(vx)
		self.velocity.x = vx
		self:capXSpeed()
	end

	function Met:setYVelocity(vy)
		self.velocity.y = vy
	end

	function Met:capXSpeed()
		if ( math.abs(self.velocity.x) > self.max_speed_x) then
			self.velocity.x = self:getMoveDir() * self.max_speed_x
		end
	end

	-----------------HEALTH------------------

	function Met:setLives(v)
		self.lives = v
	end

	function Met:getLives()
		return self.lives
	end

	function Met:onDeath()
		self:setHealth(self:getMaxHealth())
		self.lives = self.lives - 1

		if (self.lives == -1) then
			self:onNoLives()
		end

		if (self.onDeath_callback ~= nil) then
			self.onDeath_callback()
		end
	end

	function Met:onNoLives()
		if (self.noLives_callback ~= nil) then
			self.noLives_callback()
		end
	end

	-----------------COLLISION-------------------
	function Met:collideWithSolid(dt, shape_a, shape_b, dx, dy)

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
		end

        local floor_continues = false
        local ax,ay = shape_a:center()
        ax = ax + (8*self:getMoveDir())
        ay = ay + 16
        for _, shape in ipairs(self.collider:shapesAt(ax,ay)) do
            floor_continues = true
        end

        if floor_continues then
        else
            self:moveDir(self:getMoveDir()*-1)
        end


		if (shape_b.hurty) then	self:ouch() end

	--	if math.abs(dy) > math.abs(dx) then
	--		if dy < 0 then
	--			Hero:setYVelocity(0)
	--		else
	--			Hero:setYVelocity(1)
	--		end
	--	end
	end

	function Met:endCollideWithSolid(dt, shape_a, shape_b)
		if self:getYVelocity() == 0 then
			--self:setYVelocity(1)
		end
	end

	function Met:ouch()
		self:setYVelocity(-150)
		self:damage(17)
	end
return Met
