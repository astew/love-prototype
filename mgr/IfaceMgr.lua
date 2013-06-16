

local IfaceMgr = {}

IfaceMgr.items = {}
	
	
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
	
	function pairsByKey (t, f)
		if (f==nil) then f = function(a1,a2) return a1 < a2 end end
	
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
		for index, value in pairsByKey(self.items) do
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
	
	function IfaceMgr:getIteratorReverse()
		local i = table.getn(self.items)+1
		return function ()
			i = i - 1
			if i >= 1 then return self.items[i] end
		end
	end
	
	function IfaceMgr:doIterate(func)
		for item in self:getIterator() do
			func(item)
		end
	end

	------------Drawing-------------
	function IfaceMgr:draw()
		self:doIterate(function(item)
			if (item.draw ~= nil) then item:draw() end
		end)
	end
	
	-----------Mouse Stuff-------------
	
	function IfaceMgr:mousePressed(x, y, button)
		for item in self:getIteratorReverse() do
			if (item.mousePressed ~= nil) then 
				if(item:mousePressed(x, y, button)) then return end
			end
		end
	end
	
	function IfaceMgr:mouseReleased(x, y, button)
		for item in self:getIteratorReverse() do
			if (item.mouseReleased ~= nil) then 
				if(item:mouseReleased(x, y, button)) then return end
			end
		end
	end


return IfaceMgr