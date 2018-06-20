
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