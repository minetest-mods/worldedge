--------------
-- Defines the edge of a world
local WORLD_SIZE = tonumber(core.settings:get("worldedge.world_size")) or 5000
-- Radius which should be checked for a good teleportation place
local SEARCH_RADIUS = 2
-- How often to perform the teleportation routine (in seconds)
local CHECK_INTERVAL = 2
--------------

if not core.compare_block_status then
	error("worldedge requires Luanti/Minetest version >= 5.5.0. Please consider updating.")
end

if core.settings:get_bool("log_mods") then
	core.log("action", "World edge: " .. WORLD_SIZE)
end

local dprint = false and print or function() end

local get_surface_pos
local count = 0
local waiting_list = {}
--[[ Explanation of waiting_list table
	Index = Player name
	Value = {
		player = Player to teleport
		pos = Destination
		obj = Attached entity
		timeout = After when to give up on searching a free spot
	}
]]

core.register_globalstep(function(dtime)
	count = count + dtime
	if count < CHECK_INTERVAL then
		return
	end
	count = 0

	for k, v in pairs(waiting_list) do
		if v.player and v.player:is_player() then
			local pos = get_surface_pos(v.pos)
			local timeout_reached = v.timeout <= 0
			v.timeout = v.timeout - CHECK_INTERVAL

			if not pos and timeout_reached then
				-- Prevent the player from being locked in place forever
				core.chat_send_player(k, "World edge: Sorry, we could not find a free place.")
				dprint("Timeout reached")
				pos = v.pos
			end

			if pos then
				v.obj:remove()
				v.player:set_pos(pos)
				waiting_list[k] = nil
				dprint("Teleport done")
			end
		else
			waiting_list[k] = nil
		end
	end

	local newedge = WORLD_SIZE - 5
	-- Check if the players are near the edge and teleport them
	local players = core.get_connected_players()
	for i, player in ipairs(players) do
		local name = player:get_player_name()
		if not waiting_list[name] then
			local pos = vector.round(player:get_pos())
			local newpos = vector.copy(pos)
			if pos.x >= WORLD_SIZE then
				newpos.x = -newedge
			elseif pos.x <= -WORLD_SIZE then
				newpos.x = newedge
			end

			if pos.z >= WORLD_SIZE then
				newpos.z = -newedge
			elseif pos.z <= -WORLD_SIZE then
				newpos.z = newedge
			end

			-- Teleport the player
			if not vector.equals(pos, newpos) then
				core.chat_send_player(name, "World edge: " ..
					"Please wait a few seconds. We will teleport you soon.")
				local obj = core.add_entity(newpos, "worldedge:lock")
				player:set_attach(obj, "", {x=0, y=0, z=0}, {x=0, y=0, z=0})
				waiting_list[name] = {
					player = player,
					pos = newpos,
					obj = obj,
					timeout = 10,
				}
			end
		end
	end
end)

get_surface_pos = function(pos)
	-- Note: The maximum possible Y extent for searchig ground
	-- depends on the block load radius setting of the server!
	local minp = {
		x = pos.x - SEARCH_RADIUS - 1,
		y = pos.y - 40,
		z = pos.z - SEARCH_RADIUS - 1
	}
	local maxp = {
		x = pos.x + SEARCH_RADIUS - 1,
		y = pos.y + 40,
		z = pos.z + SEARCH_RADIUS - 1
	}

	-- Ensure that nearby blocks are loaded
	local probe_pos = vector.copy(pos)
	for y = minp.y, maxp.y, (core.MAP_BLOCKSIZE / 2) do
		probe_pos.y = y
		if not core.compare_block_status(probe_pos, "loaded") then
			return
		end
	end
	dprint("Mapblocks loaded -> search spot")

	local c_air = core.get_content_id("air")
	local c_ignore = core.get_content_id("ignore")

	local vm = core.get_voxel_manip()
	local emin, emax = vm:read_from_map(minp, maxp)
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()

	local seen_air = false
	local deepest_place = vector.new(pos)
	deepest_place.y = maxp.y

	for x = minp.x, maxp.x do
	for z = minp.z, maxp.z do
		-- Top-down scanning: when starting with a solid node (tree, stone),
		-- avoid teleporting the player into caves below.
		local solid = 0
		for y = deepest_place.y, minp.y, -1 do
			local node = data[area:index(x, y, z)]
			if y < deepest_place.y and node == c_air then
				deepest_place = vector.new(x, y, z)
				seen_air = true
			end
			if solid > 5 then
				-- Do not find caves!
				break
			end
			if node ~= c_air and node ~= c_ignore then
				solid = solid + 1
			end
		end
	end
	end
	if seen_air then
		dprint("Found ground: ", dump(deepest_place))
	end
	return seen_air and deepest_place or pos
end

core.register_entity("worldedge:lock", {
	initial_properties = {
		is_visible = false,
		static_save = false,
	},
	on_activate = function(staticdata, dtime_s)
		--self.object:set_armor_groups({immortal = 1})
	end,
	on_detach_child = function(self, _)
		-- Clean up this entity when the player leaves while teleporting
		self.object:remove()
		dprint("Child detach")
	end
})
