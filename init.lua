--------------
-- TODO: Check for terrain height

-- Defines the edge of a world
local edge = 30000
--------------

local count = 0
minetest.register_globalstep(function(dtime)   
   count = count + dtime
   if count < 5 then
      return
   end
   count = 0
   
   local newedge = edge - 5
   -- Check if the players are near the edge and teleport them
   local players = minetest.get_connected_players()
   for _,player in pairs(players) do
      local pos = player:getpos()
      if pos.x >= edge then
         player:moveto({x = -newedge, y = pos.y, z = pos.z})
      end
      if pos.x <= -edge then
         player:moveto({x = newedge, y = pos.y, z = pos.z})
      end
      
      if pos.z >= edge then
         player:moveto({x = pos.x, y = pos.y, z = -newedge})
      end
      if pos.z <= -edge then
         player:moveto({x = pos.x, y = pos.y, z = newedge})
      end
   end
end)


