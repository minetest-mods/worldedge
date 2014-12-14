

local count = 0
local edge = 30000 --sets the edge of map
local newedge = 29995 --sets the other side where player teleports to. Should be a few blocks less than edge
minetest.register_globalstep(function(dtime)   
   count = count + dtime
   if count > 5 then
      count = 0
      local players = minetest.get_connected_players()
      for _,player in pairs(players) do
         local pos = player:getpos()
         if pos.x >= edge then
            player:moveto({x = -newedge, y = pos.y, z = pos.z})
         end
         if pos.x <= -edge then
            player:moveto({x = newedge, y = pos.y, z = pos.z})
         end

-- This section is for the Y cord. It will move you from bottom to top or top to bottom of map
--[[         
         if pos.y >= edge then
            player:moveto({x = pos.x, y = -newedge, z = pos.z})
         end
         if pos.y <= -edge then
            player:moveto({x = pos.x, y = newedge, z = pos.z})
         end
--]]

         
         if pos.z >= edge then
            player:moveto({x = pos.x, y = pos.y, z = -newedge})
         end
         if pos.z <= -edge then
            player:moveto({x = pos.x, y = pos.y, z = newedge})
         end
       end
   end
end)


