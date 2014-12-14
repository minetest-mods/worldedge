worldedge
=========

A Minetest Mod that teleports you to the other side of the map when you reach the edge.

This mod makes it so when a player reaches the edge of the world they are teleported to the other side of the map.
This gives the illusion that that world is round and you can walk all the way around.

You can change the worlds edge by changing 2 numbers at the top of init.lua.

local edge = 30005
local newedge = 30000

set edge to where you want the edge of the map to be.
newedge sets where player teleports to. it needs to be less than edge by at least 1 block.

This mod is licenced as WTFPL

Writen by Amaz
Modified by Don
