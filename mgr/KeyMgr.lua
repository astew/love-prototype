

local KeyMgr = {}

KeyMgr.press_bindings = {}
KeyMgr.release_bindings = {}
	
	
	function KeyMgr:setPressBinding(key, callback)
		if (type(key) == "table") then
			for k, v in pairs(key) do
				self.press_bindings[k] = callback
			end
		else
			self.press_bindings[key] = callback
		end
	end
	
	function KeyMgr:removePressBinding(key)
		if (type(key) == "table") then
			for k,v in ipairs(key) do
				self.press_bindings[k] = nil
			end
		else
			self.press_bindings[key] = nil
		end
	end
	
	function KeyMgr:setReleaseBinding(key, callback)
		if (type(key) == "table") then
			for k, v in pairs(key) do
				self.release_bindings[k] = callback
			end
		else
			self.release_bindings[key] = callback
		end
	end
	
	function KeyMgr:removeReleaseBinding(key)
		if (type(key) == "table") then
			for k,v in ipairs(key) do
				self.release_bindings[k] = nil
			end
		else
			self.release_bindings[key] = nil
		end
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