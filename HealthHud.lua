
local HUD = require "HUD"

local HealthHud = HUD:new()

function HealthHud:init(...)
	HUD:init()
	self.hero = arg[1]
	self.life_image = arg[2]
	
	self.doDraw = true
	
	self.healthup = {}
	self.healthup.x = 30
	self.healthup.y = self.height - 40
	self.healthup.width = 65
	self.healthup.height = 20
end

function HealthHud:draw()
	if (not self.doDraw) then return end

	love.graphics.rectangle("fill", 20,20,200,15)
	love.graphics.setColor(250, 30, 0, 255)
	love.graphics.rectangle("fill", 20, 20, 200 * (self.hero:getHealth() / self.hero:getMaxHealth()), 15)
	love.graphics.setColor(255,255,255,255)
	
	for i=1, self.hero:getLives(), 1 do
		local xloc = self.width - 40 - i*20
		love.graphics.draw(self.life_image, xloc, 20)
	end
	
	love.graphics.setColor(5,200,5,255)
	love.graphics.rectangle("fill", self.healthup.x, self.healthup.y, 
					self.healthup.width, self.healthup.height)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Add a life!", self.healthup.x, self.healthup.y+5)
end

	function HUD:mousePressed(x, y, button)
		if(button == "r") then
			self.doDraw = not self.doDraw
			return true
		end
		return false
	end
	
	function HUD:mouseReleased(x ,y ,button)
		if(x >= self.healthup.x and y >= self.healthup.y 
			and x < self.healthup.x + self.healthup.width
			and y < self.healthup.y + self.healthup.height
			and button == "l") then
		
			self.hero:setLives(self.hero:getLives() + 1)
			return true
		end
		return false
	end

return HealthHud