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
   NewLines={		 -- list of all cells, turned into lines on previous move. Used for highlihting in .draw()
      key = function(x,y)
	 return tostring(x)..tostring(y)
      end,
      add = function(S,x,y)
	 S.List[S.key(x,y)]={x,y}
      end,
      find = function(S,x,y)
	 return S.List[S.key(x,y)]
      end,
      clear=function(S)	 S.List={}  end
   },
   
   --
   clear=function(S) table.clearIndexed(S) end,
   --
   init=function(S,size)	 --> void
      S.NewLines:clear()
      S.LastMove={}
      S:clear()
      for y=1, size do
	 S[y]=createNew("array",size,0)
      end
   end,
   
   --
   draw=function(S)		 --> void
      for y=#S,1,-1 do
	 io.write(string.format("%2u· ",y))		 -- map Y-labels
	 for x=1,#S do
	    if S.NewLines:find(x,y) then char="x"	 -- new lines, created on last move, highlighted as scpecial characters
	    else char=S[x][y]				 
	    end
	    if S.LastMove[1]== x and S.LastMove[2]== y then char = "X" end     
	    io.write(char.." ")
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
      print()
   end,
   
   --
   makeMove=function(S,p,x,y)	 -- p:player's token; x,y:coordinates --> hits or nil 
     
      local function calcSame(A)		--> 1: if all args are the same (equal) / 0: if not
	    first=A[1]
	    for _, curr in ipairs(A) do
	       if first ~= curr then  return 0 end
	    end
	    return 1
      end

      local function makeNewLine(C)
	 for _, v in ipairs(C) do
	    S.NewLines:add (v[1],v[2])
	   for _,V in pairs(S.NewLines.List) do
	       if S[V[1]][V[2]]>0 and S[V[1]][V[2]] < 3 then
		  S[V[1]][V[2]]=S[V[1]][V[2]]+2
	       end
	    end
	 end
      end
      
      local function calcHit(...)  -- arg: {x1,y1},{x2,y2}..{xn,yn} coordinates of cells --> hits (1/0), Coords: table of {x,y} for every cell turned into line 
	 Cells, Coords = {},{}
	 for _, A in ipairs(arg) do					   -- collect all cells content and eliminate incorrect 
	    if A[1]<1 or A[1]>#S or A[2]<1 or A[2]>#S  then
	       return 0							   -- cell is out of range
	    end	  
	    c = S[A[1]][A[2]]						   -- с = content of the next cell from arg list
	    if A[1]==S.LastMove[1] and  A[2]==S.LastMove[2] then	   -- omit checkin for current move target cells becase there may be line already  
	       table.insert(Cells,p)	    
	    else
	       if c>2 or c==0  then return 0 end				   -- cell is already part of some line	or empty    
	       table.insert(Cells,c)
	    end
	    table.insert(Coords,{A[1],A[2]})
	 end	 
	 makeNewLine(Coords)
	 return calcSame(Cells)
      end
      

      if S[x][y] ~= 0 then return nil					   -- it's accepted to only put token on empty field
      elseif x<1 or x>#S or y<1 or y>#S then return nil			   -- cell is out of Map range
      end
      
      S.LastMove={x,y}
      S[x][y]=p								   -- place token on Map 
      hits = calcHit({x-1,y},{x,y},{x+1,y})			           -- calculate hits for horizontal line with center on new token
      hits = hits + calcHit({x-1,y+1},{x,y},{x+1,y-1})			   -- ...left-rightdown diagonal
      hits = hits + calcHit({x,y+1},{x,y},{x,y-1})			   -- ...vertical
      hits = hits + calcHit({x-1,y-1},{x,y},{x+1,y+1})			   -- ...left-rightup diagonal
									   -- I was too lazy to write line coordinates generator function
      hits = hits + calcHit({x,y},{x+1,y},{x+2,y})			   -- horizontal from token to right
      hits = hits + calcHit({x,y},{x+1,y+1},{x+2,y+2})			   -- upright diagonal
      hits = hits + calcHit({x,y},{x+1,y-1},{x+2,y-2})			   -- downright diagonal
      hits = hits + calcHit({x,y},{x,y-1},{x,y-2})			   -- vertical down
      hits = hits + calcHit({x,y},{x,y+1},{x,y+2})			   -- vertical up
      hits = hits + calcHit({x,y},{x-1,y},{x-2,y})			   -- horizintal to left
      hits = hits + calcHit({x,y},{x-1,y+1},{x-2,y+2})			   -- upleft diagonal
      hits = hits + calcHit({x,y},{x-1,y-1},{x-2,y-2})			   -- downleft diagonal

      return hits

   end,

   endMove=function(S)
      S.NewLines:clear()
      S.LastMove={}
   end,
}




-- Init
Player1.name="Player #1"
Player1.name="Player #2"
Map:init(10)
Map[5][2]=1
Map[8][2]=1
Map[7][2]=1
Map[6][3]=1
Map[6][1]=1
print(Map:makeMove(1,6,2))
Map:draw()
Map:endMove()
Map:draw()



