
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
  
  function getOptions(O)					-- O = { .n.{nam,curval,minval,maxval} }
	
	local function isNoErr(v,vmin,vmax)
		--print(v,vmin,vmax)
		if v=="" then return true
		elseif v < vmin or v > vmax then
				 print("OUT OF RANGE. Value must be in the range of "..vmin.."--"..vmax)
		else return true				
		end		
	end
	
	while true do
		for k,V in ipairs (O) do
			io.write(k..":"..V.nam.." = "..V.curval.."    ")
		end
		print()
		repeat
			opt=inputNumber("Enter number of option to change or just [Enter] to continue")
			if opt == "" then return O end
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
