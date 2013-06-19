
local StartScreen = require "game_states/StartScreen"
--local GameMain = require "game_states/GameMain"
local TiledLevel = require "game_states/TiledLevel"

function love.load()
	
	StartScreen:load(endFunc)
end

endFunc = function()
	print("Moving to game...")
	StartScreen:unload()
	
	local newLevel = TiledLevel:new()
	
	newLevel:load("level4.tmx")
	
	--GameMain:load(gameDone)
end

gameDone = function()
	--GameMain:unload()
	print("Game over.")
end
