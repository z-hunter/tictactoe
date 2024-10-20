-- tictactoe game (c) Michael.Voitovich@gmail.com, 2018, 2024
require("tools")
require("map")
os.execute("chcp 65001 >nul") -- for MS Windows console

T_Player = {
	name = "Player #1",
	score = 0,
	controller = 0, -- 0=user,1=AI1,2=AI2
	token = 1,
}

Game = {

	--.mapSize
	--.minLine			       -- minimal lenght of cells row with same tokens to become a line
	--.CurrentPlayer
	-- .endCondition
	--
	init = function(S)
		print("Welcome to TicTacToe Extended. Options is:")

		Player1 = createNew(T_Player)
		Player2 = createNew(T_Player)
		Player2.token = 2
		Player2.name = "Player #2"

		local optionsIsOk
		repeat
			O = getOptions({
				[1] = { nam = "Player#1 (0=Human, 1=AI)", curval = Player1.controller, minval = 0, maxval = 1 },
				[2] = { nam = "Player#2 (0=Human, 1=AI)", curval = Player2.controller, minval = 0, maxval = 1 },
				[3] = { nam = "Map size", curval = Game.mapSize, minval = 3, maxval = 100 },
				[4] = { nam = "Min. line (0=Same as Map size)", curval = 0, minval = 0, maxval = 100 },
				[5] = {
					nam = "Game ending (0=first line made, 1=no free cells left)",
					curval = 0,
					minval = 0,
					maxval = 1,
				},
			})

			if O[4].curval > O[3].curval then
				optionsIsOk = false
				print("WRONG OPTION: Min. line cannot be greater than Map size.")
			else
				optionsIsOk = true
			end
		until optionsIsOk

		S.mapSize = O[3].curval
		Map:init(S.mapSize)
		if O[4].curval == 0 then
			S.minLine = S.mapSize
		else
			S.minLine = O[4].curval
		end
		S.endCondition = O[5].curval
		Player1.controller = O[1].curval
		Player2.controller = O[2].curval
		S.CurrentPlayer = Player1
	end,

	--
	play = function(S)
		local curController, command, x, y, result

		Map:draw()
		repeat
			if S.CurrentPlayer.controller == 0 then
				curController = ControllerHuman
			elseif S.CurrentPlayer.controller == 1 then
				curController = ControllerAI
			else
				error("Unknown controller type.")
			end

			print(S.CurrentPlayer.name .. " turn.")
			repeat -- stay with the player until they makes the correct move
				command, x, y = curController.retMove()

				if command == "exit" then
					break
				else
					result, err = Map:makeMove(S.CurrentPlayer.token, x, y)
					if err then
						curController.handleError(x, y, err)
					end
				end
			until result

			if command == "exit" then
				S.CurrentPlayer.score = -1
				break
			end

			S.CurrentPlayer.score = S.CurrentPlayer.score + result
			print(
				S.CurrentPlayer.name
				.. " moves to "
				.. x
				.. ","
				.. y
				.. " and made "
				.. result
				.. " score. Total is "
				.. S.CurrentPlayer.score
			)
			Map:draw()
			Map:endMove()

			S.CurrentPlayer = S.CurrentPlayer == Player1 and Player2 or Player1 -- switch next player

			-- local R = Map:getHitMovesList(Game.CurrentPlayer.token, 3)
			--[[print("__",Game.CurrentPlayer.token)
			for k, V in pairs(R) do
				table.dump(V)
			end]]
			--until table.maxkey(R)==nil

			local theEnd
			if S.endCondition == 1 then
				theEnd = (#(Map:getCellsList(0)) == 0)
			else
				theEnd = (result > 0)
			end
		until theEnd
	end,
}

ControllerHuman = {
	retMove = function()
		return inputCommand()
	end,
	handleError = function(_, _, err)
		print("BAD MOVE: " .. err .. ".")
	end,
}

-- Start

Game:init()
if Game.endCondition == 1 and (Game.minLine == Game.mapSize) then
	print(string.format("Warning: line size %d does't make much sense in this configuration", Game.minLine))
end

Map[2][1] = 1
Map[2][3] = 1

Game:play()

if Player1.score > Player2.score then
	print("Player#1 won.")
elseif Player2.score > Player1.score then
	print("Player#2 won.")
else
	print("Draw!")
end
