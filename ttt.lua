-- tictactoe game (c) Michael.Voitovich@gmail.com, 2018
require "tools"
os.execute("chcp 65001 >nul")	       -- for MS Windows console 

t_Player = {
   name="",
   score=0,
   controller="user"  -- user,AI1,AI2
}

Player1=createNew(t_Player)
Player2=createNew(t_Player)


Map={
   init=function(S,size)	 --> void
      for y=1, size do
	 S[y]=createNew("array",size,0)
      end
   end,
   draw=function(S)		 --> void
      for y=#S,1,-1 do
	 io.write(string.format("%2u· ",y))		 -- map Y-labels
	 for x=1,#S do
	    io.write(S[x][y].." ")
	 end
	 print()
      end
      io.write("   ")
      for i=1,#S do
	 io.write(" ·")		       
      end
      io.write("\n   ")      
      for i=1,#S do
	 io.write(string.format("%2u",i))		 -- map X-labels      
      end
   end,
   makeMove=function(S,p,x,y)	 -- p:player's token; x,y:coordinates --> hits or nil 

      local function calcSame(...)		--> 1: if all args are the same (equal) / 0: if not
	 first=arg[1]
	 for _, curr in ipairs(arg) do
	    if first ~= curr then return 0 end
	 end
	 return 1
      end

      local function calcHit(...)  -- arg: {x1,y1},{x2,y2}..{xn,yn} coordinates of cells -> 1/0
	 Cells={}
	 for _, A in ipairs(arg) do					   -- collect all cells content and eliminate incorrect 
	    if A[1]<1 or A[1]>#S or A[2]<1 or A[2]>#S  then
	       return 0						   -- cell is out of range
	    end	  
	    c = S[A[1]][A[2]]						   -- с = content of the next cell from arg list
	    if c>2  then return 0 end					   -- cell is already part of some line	    
	    table.insert(Cells,c)
	 end	 
	 return calcSame(unpack(Cells))
      end

      if S[x][y] ~= 0 then return nil					   -- it's accepted to only put token on empty field
      elseif x<1 or x>#S or y<1 or y>#S then return nil			   -- cell is out of Map range
      end
      S[x][y]=p								   -- place token on Map 
      hits = calcHit({x-1,y},{x,y},{x+1,y})				   -- calculate hits for horizontal line
      hits = hits + calcHit({x-1,y+1},{x,y},{x+1,y-1})			    -- left-rightdown diagonal
      hits = hits + calcHit({x,y+1},{x,y},{x,y-1})			   -- vertical
      hits = hits + calcHit({x-1,y-1},{x,y},{x+1,y+1})			   -- left-rightup diagonal
      return hits
   end,
}




-- Init
Player1.name="Player #1"
Player1.name="Player #2"
Map:init(10)
Map[5][2]=1
Map[7][2]=1
Map[6][3]=1
Map[6][1]=1
print(Map:makeMove(1,6,2))


-- MainGame
Map:draw()

-- End

