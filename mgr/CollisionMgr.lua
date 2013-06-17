

local HC = require("lib/HardonCollider")

local CollisionMgr = {}

CollisionMgr.coll_callbacks = {}
CollisionMgr.uncoll_callbacks = {}

	
	
	function CollisionMgr:init(cldr)
		self.collider = cldr
		
		local coll_function = function(dt, shape_a, shape_b, dx, dy) 
			if( shape_a.coll_class == nil or shape_b.coll_class == nil) then
				error("shape_a and shape_b must have a defined coll_class")
			end
			
			local tmp = {}
			tmp[#tmp+1] = shape_a.coll_class
			tmp[#tmp+1] = shape_b.coll_class
			table.sort(tmp)
			
			local key = tmp[1] .. "..." .. tmp[2]
			
			local cb = self.coll_callbacks[key]
			
			if( cb ~= nil) then
				cb(dt, shape_a, shape_b, dx, dy)
			end
		end
		
		local uncoll_function = function(dt, shape_a, shape_b)
			if( shape_a.coll_class == nil or shape_b.coll_class == nil) then
				error("shape_a and shape_b must have a defined coll_class")
			end
			
			local tmp = {}
			tmp[#tmp+1] = shape_a.coll_class
			tmp[#tmp+1] = shape_b.coll_class
			table.sort(tmp)
			
			local key = tmp[1] .. "..." .. tmp[2]
			
			local cb = self.uncoll_callbacks[key]
			
			if( cb ~= nil) then
				cb(dt, shape_a, shape_b)
			end
		end
		
		
		self.collider:setCallbacks(coll_function, uncoll_function)
	end
	
	function CollisionMgr:setCallbacks(class1, class2, coll_func, uncoll_func)
		local tmp = {}
			tmp[#tmp+1] = class1
			tmp[#tmp+1] = class2
			table.sort(tmp)
			
			local key = tmp[1] .. "..." .. tmp[2]
			
			self.coll_callbacks[key] = coll_func
			self.uncoll_callbacks[key] = uncoll_func
	end
	
	function CollisionMgr:clearCallbacks()
		self.coll_callbacks = {}
		self.uncoll_callbacks = {}
	end
	
	

return CollisionMgr