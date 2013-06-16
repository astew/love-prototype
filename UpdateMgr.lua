

local IfaceMgr = {}

IfaceMgr.items = {}
IfaceMgr.paused = true

	
	-----------List Management--------------
	function IfaceMgr:addItem(item)
		local n = table.getn(self.items)
		self.items[n+1] = item
	end
	
	function IfaceMgr:removeItem(item)
		for i, v in ipairs(self.items) do
			if (v == item) then
				self.items[i] = nil
			end
		end
		
		self:normalize()
	end
	
	function IfaceMgr:removeAll()
		self.items = {}
	end
	
	function pairsByKeys (t)
		local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a)
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1
			
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
		return iter
    end
	
	function IfaceMgr:normalize()
		local newTable = {}
		for index, value in pairsByKeys(self.items) do
			table.insert(newTable, value)
		end
		
		self.items = newTable
	end
	
	function IfaceMgr:getIterator()
		local i = 0
		local n = table.getn(self.items)
		return function ()
			i = i + 1
			if i <= n then return self.items[i] end
		end
	end
	
	function IfaceMgr:doIterate(func)
		for item in self:getIterator() do
			func(item)
		end
	end

	
	-------------Other----------------
	function IfaceMgr:pause()
		self.paused = true
	end
	
	function IfaceMgr:unpause()
		self.paused = false
	end
	
	function IfaceMgr:togglePause()
		self.paused = not self.paused
	end
	
	function IfaceMgr:isPaused()
		return self.paused
	end
	
	function IfaceMgr:update(dt)
		self:doIterate(function(item)
			if (self.paused) then return end
		
			if (item.update ~= nil) then item:update(dt) end
		end)
	end


return IfaceMgr