

local MapMgr = {}

MapMgr.loader = require("lib/Advanced-Tiled-Loader/Loader")
MapMgr.loader.path = "res/maps/"
MapMgr.map = {}
MapMgr.SolidTiles = {}

	function MapMgr:loadMap(map_file)
        self.map = self.loader.load(map_file)
	end

    function MapMgr:iterateLayerTilesByType(layer, tileType, callback)
        for x, y, tile in self.map(layer):iterate() do
            if tile and tile.properties[tileType] then
                callback(x, y, tile)
            end
        end
    end
	
	function MapMgr:iterateLayerObjectsByType(layer, objectType, callback)
		local objects = self.map(layer).objects
		for k,v in pairs(objects) do
			if(v.type == objectType) then
				callback(v)
			end
		end 
    end
	
	function MapMgr:iterateLayerObjects(layer, callback)
		local objects = self.map(layer).objects
		for k,v in pairs(objects) do
			callback(v)
		end 
    end

return MapMgr
