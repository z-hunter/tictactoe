Map = {
	NewLines = { -- list of all cells, turned into lines on previous move. Used for highlihting in .draw()
		key = function(x, y)
			return tostring(x) .. tostring(y)
		end,
		add = function(S, x, y)
			S.List[S.key(x, y)] = { x, y }
		end,
		find = function(S, x, y)
			return S.List[S.key(x, y)]
		end,
		clear = function(S)
			S.List = {}
		end,
	},

	--
	clear = function(S)
		table.clearIndexed(S)
	end,
	--
	init = function(S, size) --> void
		S.NewLines:clear()
		S.LastMove = {}
		S:clear()
		for y = 1, size do
			S[y] = createNew("array", size, 0)
		end
	end,

	--
	draw = function(S) --> void
		for y = #S, 1, -1 do
			io.write(string.format("%2u· ", y)) -- map Y-labels
			for x = 1, #S do
				local char
				if S.NewLines:find(x, y) then
					char = "x" -- new lines, created on last move, highlighted as scpecial characters
				else
					char = S[x][y]
				end
				if S.LastMove[1] == x and S.LastMove[2] == y then
					char = "X"
				end
				io.write(char .. " ")
			end
			print()
		end
		io.write("   ")
		for i = 1, #S do
			io.write(" ·")
		end
		io.write("\n   ")
		for i = 1, #S do
			io.write(string.format("%2u", i)) -- map X-labels
		end
		print()
	end,

	--
	isOutOfRange = function(S, x, y)
		if x < 1 or x > #S or y < 1 or y > #S then
			return true
		end
	end,

	--
	makeMove = function(S, p, x, y) -- p:player's token; x,y:coordinates --> hits or nil
		local function makeNewLine(x, y, x2, y2)
			local function calcDelta(v1, v2)
				if v1 > v2 then
					return -1
				elseif v1 < v2 then
					return 1
				else
					return 0
				end
			end

			local function proceedCell(x, y)
				if S[x][y] == 0 then
					error("Map.makeMove() -> makeNewLine(): Zero-cell in line!")
				elseif S[x][y] < 3 then
					S[x][y] = S[x][y] + 2
				end
				S.NewLines:add(x, y)
			end

			repeat
				proceedCell(x, y)
				x = calcDelta(x, x2) + x
				y = calcDelta(y, y2) + y
			until x == x2 and y == y2
			proceedCell(x, y)
		end

		local function neightborByDirection(x, y, dir) --> new x,y for neightbor cell in direction dir from cell x,y
			if dir == 1 then
				y = y + 1
			elseif dir == 2 then
				x = x + 1
				y = y + 1
			elseif dir == 3 then
				x = x + 1
			elseif dir == 4 then
				x = x + 1
				y = y - 1
			elseif dir == 5 then
				y = y - 1
			elseif dir == 6 then
				y = y - 1
				x = x - 1
			elseif dir == 7 then
				x = x - 1
			elseif dir == 8 then
				y = y + 1
				x = x - 1
			else
				return nil
			end
			return x, y
		end

		local function invertDirection(dir) --> direction opposite to dir
			dir = dir + 4
			if dir > 8 then
				dir = dir - 8
			end
			return dir
		end

		local function calcLine(x, y, p, dir) --> ~x,y of last p token on line in direction dir, ~lenght of line (at least 1)
			local count = 1
			local x1, y1
			while true do
				x1, y1 = neightborByDirection(x, y, dir)
				if not S:isOutOfRange(x1, y1) and S[x1][y1] == p then
					x, y = x1, y1
					count = count + 1
				else
					break
				end
			end
			return x, y, count
		end

		--------->
		if S:isOutOfRange(x, y) then
			return nil, "coordinates is out of range"
		elseif S[x][y] ~= 0 then
			return nil, "cell is not empty"
		end -- check for bad moves

		S.LastMove = { x, y }
		S[x][y] = p -- place token on Map
		local lines = 0
		for dir = 1, 4 do
			local x1, y1, h1 = calcLine(x, y, p, dir)
			local x2, y2, h2 = calcLine(x, y, p, invertDirection(dir))
			local h = h1 + h2 - 1
			if h >= Game.minLine then
				--print(" ",h)
				makeNewLine(x1, y1, x2, y2)
				lines = (lines + 1)
			end
		end
		return lines
	end,

	endMove = function(S)
		S.NewLines:clear()
		S.LastMove = {}
	end,
	--
	getCellsList = function(S, p) --> array {x,y} with val of p
		local Res = {}
		for x = 1, #S do
			for y = 1, #S do
				if S[x][y] == p then
					table.insert(Res, { x, y })
				end
			end
		end
		return Res
	end,
	--

	getHitMovesList = function(S, p, deep) --> array of {x,y,h} with val is hits score
		local function invertP(p) --> p (Map token) of another player
			if p == 1 then
				p = 2
			else
				p = 1
			end
			return p == 1 and 2 or 1 
		end

		local H, h = {}, nil
		local L = S:getCellsList(0) -- list of free cells
		for _, V in pairs(L) do
			local TempMap = createNew(S)
			TempMap.NewLines:add(V[1], V[2])
			TempMap:draw()
			h = TempMap:makeMove(p, V[1], V[2])
			if h > 0 then
				table.insert(H, { V[1], V[2], h })
				print(V[1], V[2], h)
			end
		end
		return H
	end,

	--
	retHitMovesList = function(S, p, deep, origp)
		local function retMaxHit(R, p1)
			local ret1, ret2, deep1, deep2 = 0, 0, -1, -1
			local p2
			if p1 == 1 then
				p2 = 2
			else
				p2 = 1
			end
			for _, V in ipairs(R) do
				if V[p1] > ret1 then
					ret1 = V[p1]
					deep1 = V[5]
				end
				if V[p2] > ret2 then
					ret2 = V[p2]
					deep2 = V[5]
				end
			end
			return ret1, ret2, deep1, deep2
		end

		--print("deep="..deep)
		local Res = {}
		local hits, hits2, th1, th2, td1, td2, edeep1, edeep2
		deep = deep or 0
		origp = origp or p
		local p2
		if p == 1 then
			p2 = 2
		else
			p2 = 1
		end
		local Cells = S:getCellsList(0)
		for _, V in ipairs(Cells) do
			local TempMap = createNew(S)
			hits = TempMap:makeMove(p, V[1], V[2])
			hits2 = 0
			edeep1, edeep2 = deep, deep
			if deep > 0 then
				local Res2 = TempMap:retHitMovesList(p2, deep - 1, origp)
				if #Res2 > 0 then
					th1, th2, td1, td2 = retMaxHit(Res2, p)
					if th1 < hits then
						edeep1 = td1
						edeep2 = td2
					else
						edeep1, edeep2 = deep, deep
					end
					hits = hits + th1
					hits2 = hits2 + th2
				end
			end

			if hits > 0 or hits2 > 0 then
				--print("hits", hits, p, hits2 )
				--TempMap:draw()
				local Ins = {}
				Ins[p] = hits
				Ins[p2] = hits2
				Ins[3], Ins[4] = V[1], V[2]
				Ins[5] = edeep1
				Ins[6] = edeep2
				table.insert(Res, Ins)
				--table.dump(Res)
			end
		end
		return Res
	end,
}
