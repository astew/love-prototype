

local HUD = { }

   function HUD:new(o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
    end

	--Take any necessary steps to initialize the HUD
	function HUD:init(...)
		self.width = love.graphics.getWidth()
		self.height = love.graphics.getHeight()
	end
	
	--Take any necessary steps to draw the HUD on the display
	function HUD:draw()
	
	end
	
	
	function HUD:mousePressed(x, y, button)	return false	end
	function HUD:mouseReleased(x,y,button)	return false	end
	
	
return HUD