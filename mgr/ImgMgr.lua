

local ImgMgr = {}

ImgMgr.images = {}
	
	
	function ImgMgr:loadImage(key, file)
		self.images[key] = love.graphics.newImage(file)
	end
	
	function ImgMgr:unloadImage(key)
		self.images[key] = nil
	end
	
	function ImgMgr:getImage(key)
		return self.images[key]
	end
	
	function ImgMgr:draw(key, x, y, r, sx, sy, ox, oy)
		if (r == nil) then r = 0 end
		if (sx == nil) then sx = 1 end
		if (sy == nil) then sy = sx end
		if (ox == nil) then ox = 0 end
		if (oy == nil) then oy = 0 end
		love.graphics.draw(self:getImage(key), x, y, r, sx, sy, ox, oy)
	end
	

return ImgMgr