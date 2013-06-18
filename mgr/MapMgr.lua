

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

return MapMgr
