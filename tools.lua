-- unpack: global in Lua 3.1-5.1, table.unpack in Lua 5.2+
if not table.unpack then
	table.unpack = _G["unpack"]  -- Lua 3.1-5.1
end

function table.deepcopy(o, seen) --> recursively copies a table's contents, ensures that metatables are preserved
	-- Handle non-tables and previously-seen tables. |SRC: https://gist.github.com/tylerneylon/81333721109155b2d244#file-copy-lua-L84
	if type(o) ~= "table" then
		return o
	elseif seen and seen[o] then
		return seen[o]
	end
	-- New table; mark it as seen an copy recursively.
	local s = seen or {}
	s[o] = true
	local res = setmetatable({}, getmetatable(o))
	local k, v
	for k, v in pairs(o) do
		res[table.deepcopy(k, s)] = table.deepcopy(v, s)
	end
	return res
end

function table.clearIndexed(T)
	for k, _ in ipairs(T) do
		T[k] = nil
	end
end

function createNew(what, q, init)
	if what == "array" then
		local ret = {}
		for i = 1, q do
			table.insert(ret, init)
		end
		return ret
	else
		return table.deepcopy(what)
	end
end

function input(txt)
	io.write("\n" .. txt .. "> ")
	-- io.flush()
	local answer = io.read()
	return answer
end

function inputCommand() --> [command,] x, y
	local command, x, y
	repeat
		local str = input("Your move (x/y or e for exit)")
		str = str:gsub("%s+", "") -- remove spaces
		local pos, _ = str:find("/")
		if not pos and str == "e" then
			command = "exit"
		elseif pos then
			x = tonumber(str:sub(1, pos - 1))
			y = tonumber(str:sub(pos + 1))
			if x and y then
				command = "move"
			end
		end
		if not command then
			print("INCORRECT INPUT. Two digital value separated by '/' for corinates OR letter 'e' for exit expected.")
		end
	until command
	return command, x, y
end

function inputNumber(txt)
	local ret
	repeat
		ret = input(txt)
		if ret ~= "" then
			ret = tonumber(ret)
		end
		if not ret then
			print("INCORRECT INPUT. One digital value or blank line expected.")
		end
	until ret
	return ret
end

function table.retSerialized(T, indent)    --> string with Lua code of given table: { <code> }
	indent = indent or 1
	local iStr = string.rep("  ", indent) -- indent for formatting output
	local iStr1 = string.rep("  ", indent - 1)
	local ret = "{\n"
	for key, value in pairs(T) do
		local keyString
		if type(key) == "number" then
			keyString = "[" .. tostring(key) .. "]"
		else
			keyString = tostring(key)
		end
		if type(value) == "table" then
			-- file:write(indent .. keyString .. " = {\n")
			ret = ret .. iStr .. keyString .. " = "
			ret = ret .. table.retSerialized(value, indent + 1) -- recursive proceed nested tables
			-- file:write(indent .. "},\n")
			-- ret = ret .. indent .. "},\n"
		else
			local valueString = type(value) == "string" and string.format("%q", value) or tostring(value)
			--file:write(indent .. keyString .. " = " .. valueString .. ",\n")
			ret = ret .. iStr .. keyString .. " = " .. valueString .. ",\n"
		end
	end
	ret = ret .. iStr1 .. "},\n"
	return ret
end

function table.saveToFile(T, filename)	--> true/false, error message: Save serialized table to file
	local file = io.open(filename, "w") -- trying to open file for writing
	if not file then
		return false, "Cannot open file " .. filename .. " to write!"
	end

	--file:write("{\n")
	file:write(table.retSerialized(T)) --
	--file:write("}\n")
	file:close()
	return true
end

function table.retLoadedFromFile(filename)	--> table or nil, error message: Load serialized table and return it
	local file = io.open(filename, "r")

	if not file then
		return nil, "Cannot open file " .. filename .. " for read!"
	end

	local content = file:read("*all") -- read all file content
	file:close()

	-- add "return" wrapper to table content
	local luaCode = "return " .. content

	-- compile and execute this code
	local func, err
	local major, minor = _VERSION:match("Lua (%d+)%.(%d+)")
	major, minor = tonumber(major), tonumber(minor)

	if major > 5 or (major == 5 and minor >= 2) then -- for Lua 5.2 and greater use load
		func, err = load(luaCode)
	else                                            -- for Lua 5.1 and lower use loadstring
		func, err = loadstring(luaCode)
	end

	if not func then
		return nil, "Lua loadstring failed: " .. (err or "")
	end

	local status, result = pcall(func)

	if not status then
		return nil, "Lua pcall failed: " .. result
	end

	return result
end

function getOptions(O) -- O = { n.{nam,curval,minval,maxval}, .. }
	local filename = "options~"	

	function isNoErr(v, vmin, vmax)
		--print(v,vmin,vmax)
		if v == "" then
			return true
		elseif v < vmin or v > vmax then
			print("OUT OF RANGE. Value must be in the range of " .. vmin .. "--" .. vmax)
		else
			return true
		end
	end
	
	--local O2 = table.loadFromFile(filename)
	--O = O2 or O
	O = table.retLoadedFromFile(filename) or O

	while true do
		for k, V in ipairs(O) do
			io.write(k .. ":" .. V.nam .. " = " .. V.curval .. "    ")
		end
		print()
		repeat
			opt = inputNumber("Enter number of option to change or just [Enter] to continue")
			if opt == "" then
				local success, err = table.saveToFile(O, filename)
				if not success then
					print("WARNING: " .. err)
				end
				return O
			end
		until isNoErr(opt, 1, #O)

		repeat
			val =
					inputNumber("Current value is " .. O[opt].curval .. ". Enter new value or just [Enter] to keep current")
		until isNoErr(val, O[opt].minval, O[opt].maxval)

		if val ~= "" then
			O[opt].curval = val
		end
		print()
	end
end

--[[ function table.maxkey(T)
	local inv = {}
	for k, _ in pairs(T) do
		table.insert(inv, k)
	end
	if #inv > 1 then
		m = math.max(table.unpack(inv))
	else
		m = inv[1]
	end
	return m
end

function table.minkey(T)
	local inv = {}
	for k, _ in pairs(T) do
		table.insert(inv, k)
	end
	if #inv > 1 then
		m = math.min(table.unpack(inv))
	else
		m = inv[1]
	end
	return m
end ]]

function table.dump(T)
	for k, v in pairs(T) do
		print(k, v)
	end
end




