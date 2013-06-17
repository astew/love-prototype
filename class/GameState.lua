

local GameState = { }

   function GameState:new(o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
    end

	--Take any necessary steps to initialize the Game's State
	function GameState:load(...)
	
	end
	
	--Take any necessary steps to unload this state
	function GameState:unload()
	
	end
	

	
return GameState