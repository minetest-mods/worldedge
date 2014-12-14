
--[[
local count = 0
minetest.register_globalstep(function(dtime)   
   count = count + dtime
   if count > 5 then
      count = 0
      local players = minetest.get_connected_players()
      for _,player in pairs(players) do
         local pos = player:getpos()
         if pos.x >= 30850 then
            player:moveto({x = -30800, y = pos.y, z = pos.z})
         end
         if pos.x <= -30850 then
            player:moveto({x = 30800, y = pos.y, z = pos.z})
         end
         
         if pos.y >= 30850 then
            player:moveto({x = pos.x, y = -30800, z = pos.z})
         end
         if pos.y <= -30850 then
            player:moveto({x = pos.x, y = 30800, z = pos.z})
         end
         
         if pos.z >= 30850 then
            player:moveto({x = pos.x, y = pos.y, z = -30800})
         end
         if pos.z <= -30850 then
            player:moveto({x = pos.x, y = pos.y, z = 30800})
         end
       end
   end
end)
--]]

local count = 0
minetest.register_globalstep(function(dtime)   
   count = count + dtime
   if count > 5 then
      count = 0
      local players = minetest.get_connected_players()
      for _,player in pairs(players) do
         local pos = player:getpos()
         if pos.x >= 100 then
            player:moveto({x = -100, y = pos.y, z = pos.z})
         end
         if pos.x <= -100 then
            player:moveto({x = 100, y = pos.y, z = pos.z})
         end
         
         --[[if pos.y >= 30850 then
            player:moveto({x = pos.x, y = -30800, z = pos.z})
         end
         if pos.y <= -30850 then
            player:moveto({x = pos.x, y = 30800, z = pos.z})
         end--]]
         
         if pos.z >= 100 then
            player:moveto({x = pos.x, y = pos.y, z = -100})
         end
         if pos.z <= -100 then
            player:moveto({x = pos.x, y = pos.y, z = 100})
         end
       end
   end
end)
