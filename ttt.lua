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
   isOutOfRange = function(S, x,y)
      if x<1 or x>#S or y<1 or y>#S then return true end
   end,
   
   --
   makeMove=function(S,p,x,y)	 -- p:player's token; x,y:coordinates --> hits or nil    
      

      local function makeNewLine(x,y,x2,y2)
	 
	 local function calcDelta(v1,v2)
	    if v1>v2 then return -1
	    elseif v1<v2 then return 1
	    else return 0
	    end
	 end
	 
	 local function proceedCell(x,y)
	    if S[x][y]==0 then error("Map.makeMove() -> makeNewLine(): Zero-cell in line!")
	    elseif S[x][y]<3 then S[x][y]=S[x][y]+2
	    end
	    S.NewLines:add (x,y)
	 end

	 repeat	    
	    proceedCell(x,y)
	    x=calcDelta(x,x2)+x
	    y=calcDelta(y,y2)+y
	 until x == x2 and y == y2
	 proceedCell(x,y)
      end
      

      
      function neightborByDirection(x,y, dir)	   --> new x,y for neightbor cell in direction dir from cell x,y   
	 if dir==1 then y=y+1
	 elseif dir == 2 then x=x+1; y=y+1 
	 elseif dir == 3 then x=x+1
	 elseif dir == 4 then x=x+1; y=y-1
	 elseif dir == 5 then y=y-1
	 elseif dir == 6 then y=y-1; x=x-1
	 elseif dir == 7 then x=x-1
	 elseif dir == 8 then y=y+1; x=x-1
	 else return nil
	 end
	 return x,y   
      end

      function invertDirection(dir)
	 dir = dir+4
	 if dir > 8 then dir=dir-8 end
	 return dir
      end

      function calcLine(x,y,p,dir)			   --> x,y of last p) token on line in direction dir 
	 count = 1
	 while true do
	    x1,y1 = neightborByDirection(x,y, dir)
	    if not S:isOutOfRange(x1,y1) and S[x1][y1] == p then
	       x,y = x1,y1
	       count=count+1
	    else break
	    end
	 end
	 return x,y,count
      end


      if S[x][y] ~= 0 or S:isOutOfRange(x,y) then return nil end				   -- it's accepted to only put token on empty field
      
      S.LastMove={x,y}
      S[x][y]=p											   -- place token on Map 
     
      local hits=0

      for dir=1, 8 do
	 local x1,y1,h1=calcLine(x,y,p,dir) 
	 local x2,y2,h2=calcLine(x,y,p,invertDirection(dir))

	 local h=h1+h2-1
	 if h >=3 then
	    --print(" ",h)
	    makeNewLine(x1,y1,x2,y2)
	    hits=hits+h-2
	 end
      end
      
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
Map[6][4]=1
Map[7][3]=1
Map[5][1]=1
print()
print(Map:makeMove(1,6,2))
Map:draw()
Map:endMove()
Map:draw()

  




