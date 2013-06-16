

local KeyMgr = {}

KeyMgr.press_bindings = {}
KeyMgr.release_bindings = {}
	
	
	function KeyMgr:setPressBinding(key, callback)
		self.press_bindings[key] = callback
	end
	
	function KeyMgr:removePressBinding(key)
		self.bindings[key] = nil
	end
	
	function KeyMgr:setReleaseBinding(key, callback)
		self.release_bindings[key] = callback
	end
	
	function KeyMgr:removeReleaseBinding(key)
		self.release_bindings[key] = nil
	end
	
	function KeyMgr:removeAllBindings()
		self.press_bindings = {}
		self.release_bindings = {}
	end
	
	function KeyMgr:keyPressed(key)
		local callback = self.press_bindings[key]
		
		if(callback ~= nil) then
			callback()
		end
	end
	
	function KeyMgr:keyReleased(key)
		local callback = self.release_bindings[key]
		if(callback ~= nil) then
			callback()
		end
	end

return KeyMgr