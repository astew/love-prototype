
local StartScreen = require "game_states/StartScreen"
local GameMain = require "game_states/GameMain"

function love.load()
	
	StartScreen:load(endFunc)
end

endFunc = function()
	print("Moving to game...")
	StartScreen:unload()
	GameMain:load(gameDone)
end

gameDone = function()
	GameMain:unload()
	print("Game over.")
end
