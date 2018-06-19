-- tictactoe game (c) Michael.Voitovich@gmail.com, 2018
require "tools"
os.execute("chcp 65001 >nul")

t_Player = {
   name="",
   score=0,
   controller="user"  -- user,AI1,AI2
}

Player1=createNew(t_Player)
Player2=createNew(t_Player)


Map={
   init=function(S,size)
      for y=1, size do
	 S[y]=createNew("array",size,0)
      end
   end,
   draw=function(S)
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
   end
}




-- Init
Player1.name="Player #1"
Player1.name="Player #2"
Map:init(10)
Map[5][2]=1



-- MainGame
Map:draw()

-- End
