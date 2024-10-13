function table.deepcopy(o, seen)  --> recursively copies a table's contents, ensures that metatables are preserved
  -- Handle non-tables and previously-seen tables. |SRC: https://gist.github.com/tylerneylon/81333721109155b2d244#file-copy-lua-L84
  if type(o) ~= "table" then return o
  elseif seen and seen[o] then return seen[o]
  end;
  -- New table; mark it as seen an copy recursively.
  local s = seen or {};
  s[o] = true;
  local res = setmetatable({}, getmetatable(o));
  local k, v;
  for k, v in pairs(o) do res[table.deepcopy(k, s)] = table.deepcopy(v, s) end;
  return res
end;

function table.clearIndexed (T)
		for k,_ in ipairs (T) do
			T[k]=nil
		end
end


function createNew(what, q, init)
	if what=="array" then
		local ret={}
		for i=1, q do
			table.insert(ret,init)
		end
		return ret
	else
		return table.deepcopy(what)
	end

end

 
function input(txt) 
	io.write("\n"..txt.."> ")
	io.flush()
	local answer=io.read()
	return answer
end
 
function inputNumber(txt) 
	repeat
		ret=input(txt)
		if ret ~="" then ret=tonumber(ret) end
		if not ret then
			print("INCORRECT INPUT. One digital value or blank line expected.")
		end
	until ret	
	return ret
end
  

function saveTableToFile(Tbl, filename)
    local file = io.open(filename, "w")  -- открываем файл для записи
    if not file then
        return false, "Cannot open file ".. filename .." to write!"
    end

    local function serializeTable(t, indent)
        indent = indent or ""  -- отступ для форматирования вывода
        for key, value in pairs(t) do
            local keyString
	    if type(key) == "number" then
	       keyString = "["..tostring(key).."]"
	    else
	       keyString = tostring(key)
	    end
            if type(value) == "table" then
                file:write(indent .. keyString .. " = {\n")
                serializeTable(value, indent .. "  ")  -- рекурсивно обрабатываем вложенные таблицы
                file:write(indent .. "},\n")
            else
                local valueString = type(value) == "string" and string.format("%q", value) or tostring(value)
                file:write(indent .. keyString .. " = " .. valueString .. ",\n")
            end
        end
    end

    file:write("{\n")
    serializeTable(Tbl, "  ")  -- запускаем сериализацию с начальным отступом
    file:write("}\n")

    file:close()
    return true
end

function loadTableFromFile(filename)
    local file = io.open(filename, "r")
    
    if not file then
        return nil, "Cannot open file "..filename.." for read!"
    end

    local content = file:read("*all")  -- читаем всё содержимое файла
    file:close()

    -- Добавляем обёртку "return" к содержимому таблицы
    local luaCode = "return " .. content

    -- Компилируем и выполняем этот код    
    local func, err
    local major, minor = _VERSION:match("Lua (%d+)%.(%d+)")
    major, minor = tonumber(major), tonumber(minor)

    if major > 5 or (major == 5 and minor >= 2) then  -- для Lua 5.2 и выше используем load
        func, err = load(luaCode)
    else					      -- для 5.1 и ниже используем loadstring
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



function getOptions(O)					-- O = { n.{nam,curval,minval,maxval}, .. }

     
      local function isNoErr(v,vmin,vmax)
		--print(v,vmin,vmax)
		if v=="" then return true
		elseif v < vmin or v > vmax then
				 print("OUT OF RANGE. Value must be in the range of "..vmin.."--"..vmax)
		else return true				
		end		
      end

      local filename = "options~"	
      local O2, err = loadTableFromFile(filename)
      if O2 then
          -- print("Options loaded from file")
	  O = O2
      else
	 -- print ("Options not loaded from file " .. err)
      end
	
	
	
	while true do
		for k,V in ipairs (O) do
			io.write(k..":"..V.nam.." = "..V.curval.."    ")
		end
		print()
		repeat
			opt=inputNumber("Enter number of option to change or just [Enter] to continue")
			if opt == "" then
			   local success, err = saveTableToFile(O, filename)
			   if not success then print("WARNING: " .. err) end
			   return O
			end
		until isNoErr(opt,1,#O)
		
		repeat
			val=inputNumber("Current value is "..O[opt].curval..". Enter new value or just [Enter] to keep current")
		until isNoErr(val,O[opt].minval,O[opt].maxval)
		
		if val~="" then
			O[opt].curval = val
		end
		print()
	end
	 

end


  
  
function table.maxkey(T)
	local inv={}
	for k,_ in pairs(T) do
		table.insert(inv,k)
	end
	if #inv >1 then m = math.max(unpack(inv))
	else m=inv[1]
	end
	return m
end
function table.minkey(T)
	local inv={}
	for k,_ in pairs(T) do
		table.insert(inv,k)
	end
	if #inv >1 then m = math.min(unpack(inv))
	else m=inv[1]
	end
	return m
end

function table.dump(T)
	for k,v in pairs(T) do
		print (k,v)
	end
end

function table.dumpRet(T)
	for k,v in pairs(T) do
		io.write("h1="..v[1].." h2="..v[2].."  x"..v[3].." y"..v[4].."  deep="..v[5]..","..v[6].."\n")
	end
end
