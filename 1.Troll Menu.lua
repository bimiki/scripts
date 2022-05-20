-- Function definitions
local function null() end
local function Text(submenu, text)
	if (submenu ~= nil) then
		submenu:add_action(text, null)
	else
		menu.add_action(text, null)
	end
end
 
local function sqrt(i)
	return math.sqrt(i)
end
local function DistanceToSqr(vec1, vec2)
	return ((vec2.x - vec1.x)^2) + ((vec2.y - vec1.y)^2) + ((vec2.z - vec1.z)^2)
end
local function Distance(vec1, vec2)
	return sqrt(DistanceToSqr(vec1, vec2))
end
local function floor(num)
	return math.floor(num)
end
local function clamp(num, min, max)
	if num > max then return max elseif num < min then return min else return num end
end

-- Player Info
local function IsPlayer(ped)
	if ped == nil or ped:get_pedtype() >= 4 then
		return false
	end
	return true
end
local function IsNPC(ped)
	if ped == nil or ped:get_pedtype() < 4 then
		return false
	end
	return true
end
local function GetSpeed(ent)
	oldpos = ent:get_position()
	sleep(0.05)
	newpos = ent:get_position()
	return DistanceToSqr(oldpos, newpos)
end
local function IsModder(ply)
	if not IsPlayer(ply) then return false end
	if ply:get_max_health() < 100 then return true end
	if ply:is_in_vehicle() and ply:get_godmode() then return true end
	if ply:get_run_speed() > 1.0 or ply:get_swim_speed() > 1.0 then return true end
	if ply:get_infinite_clip()then return true end --Infinit clip
	if ply:get_no_ragdoll() then return true end --No ragdoll
	if ply:get_seatbelt() and ply:is_in_vehicle() then return true end
	if ply:get_current_weapon() and ply:get_current_weapon():get_current_ammo() > 0 and ply:get_infinite_ammo() then return mod end --Infinite ammo
	return false
end
local function GetPlayerCount()
	return player.get_number_of_players()
end
 
-- Action functions
local function TeleportToPlayer(ply, seconds)
	if not ply or ply == nil then return end 
	local pos = ply:get_position()
	if seconds then
		if localplayer:is_in_vehicle() then return end
 
		local oldpos = localplayer:get_position()
		localplayer:set_position(pos)
		sleep(seconds)
		localplayer:set_freeze_momentum(true) 
		localplayer:set_config_flag(292,true)
		localplayer:set_position(oldpos)
		localplayer:set_freeze_momentum(false) 
		localplayer:set_config_flag(292,false)
		return
	end
	if not localplayer:is_in_vehicle() then
		localplayer:set_position(pos)
	else
		localplayer:get_current_vehicle():set_position(pos)
	end
end

local function TeleportClosestVehicleToPlayer(ply)
	if not ply or ply == nil then return end 
	local pos = ply:get_position()
	local veh = localplayer:get_nearest_vehicle()
	if not veh then return end
	veh:set_position(pos)
end
 
local function TeleportPedsToPlayer(ply, dead)
	if not ply or ply == nil then return end 
	local pos = ply:get_position()
	for ped in replayinterface.get_peds() do
		if IsNPC(ped) then
			if not ped:is_in_vehicle() then
				ped:set_position(pos)
			end
		end
	end
end
 
local function ExplodePlayer(ply)
	if not ply or ply == nil then return end 
	local pos = ply:get_position()
	local currentvehicle = nil 
	if localplayer:is_in_vehicle() then
		currentvehicle = localplayer:get_current_vehicle()
	end
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			veh:set_rotation(vector3(0,0,180))
			veh:set_health(-1)
			veh:set_position(pos)
		end
	end
end
 
local function LaunchPlayer(ply)
	if not ply or ply == nil then return end 
	local currentvehicle = nil 
	if localplayer:is_in_vehicle() then
		currentvehicle = localplayer:get_current_vehicle()
	end
	local i = 0
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			local pos = ply:get_position()
			veh:set_rotation(vector3(0,0,0))
			veh:set_gravity(-100)
			veh:set_position(vector3(pos.x, pos.y, pos.z - 20))
		end
	end
	sleep(1)
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			local pos = ply:get_position()
			veh:set_gravity(9.8)
		end
	end
end
 
local function SlamPlayer(ply)
	if not ply or ply == nil then return end 
	local currentvehicle = nil 
	if localplayer:is_in_vehicle() then
		currentvehicle = localplayer:get_current_vehicle()
	end
	local i = 0
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			local pos = ply:get_position()
			veh:set_rotation(vector3(0,0,0))
			veh:set_gravity(10000)
			veh:set_position(vector3(pos.x, pos.y, pos.z + 100))
		end
	end
	sleep(1)
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			local pos = ply:get_position()
			veh:set_gravity(9.8)
		end
	end
end
 
-- Player option 
local selectedplayer = -1
 
local function f_p_o(ply_id, ply, ply_name) -- Format Player Option Text
	local text = ""
	if ply == localplayer then
		text = text.."YOU"
	else
		text = text..ply_name
	end
	if IsModder(ply) then
		text = text.."*"
	end
	if ply:get_godmode() then
		text = text.." | God"
	end
	if ply:is_in_vehicle() then
		if ply:get_current_vehicle():get_godmode() then
			text = text.." | vGod"
		else
			
			text = text.." |   "
		end
	end

	-- Player's Distance From You
	text = text.." | "..floor(Distance(ply:get_position(), localplayer:get_position())).." m"
	
	return text
end
 
local function add_player_option(submenu, ply_id, ply, ply_name)
	local text = f_p_o(ply_id, ply, ply_name)
	local d = ply_id
 
	if (submenu ~= nil) then
		submenu:add_bare_item(text, function() return f_p_o(ply_id, ply, ply_name).."|"..(selectedplayer == ply_id and "✓" or "□")  end, function() selectedplayer = d end, null, null)
	else
		menu.add_bare_item(text, function() return f_p_o(ply_id, ply, ply_name).."|"..(selectedplayer == ply_id and "✓" or "□") end, function() selectedplayer = d end, null, null)
	end
end
 
local function add_info_option(submenu, text, funcget, forceplayer)
	local func = function() 
		local ply = player.get_player_ped(forceplayer and forceplayer or selectedplayer)
		if not ply then return text..": **Invalid**" end
		return text..": "..funcget(ply)
	end
	if (submenu ~= nil) then
		submenu:add_bare_item(text..": ", func, null, null, null)
	else
		menu.add_bare_item(text..": ", func, null, null, null)
	end
end
 
-- Building Player List
local playerlist = menu.add_submenu("Troll Menu")

-- --
local mpx = stats.get_int("MPPLY_LAST_MP_CHAR")
local enab = 1
local function lpBmb()
	while enab == 1 do
		if stats.get_int("MP"..mpx.."_H4LOOT_WEED_I_SCOPED") == 0 then return end
		ExplodePlayer(player.get_player_ped(selectedplayer))
		sleep(0.5)
		menu.send_key_press(85)
		sleep(1.5)
	end
end
menu.register_hotkey(155, lpBmb)
-- --

local function BuildListOld()
	Text(playerlist, "---AppleVegas's Player List, "..GetPlayerCount().." Players---")
	for i = 0, 31 do
		local ply = player.get_player_ped(i)
		if ply then 
			add_player_option(playerlist, i, ply, player.get_player_name(i))
		end
	end
	Text(playerlist, "---End---")
 	add_info_option(playerlist, "Player", function() return player.get_player_name(selectedplayer) end)
	
	local LsTr = 1
	local LsTP = 2
	-- Troll Options
	local TrOp = {}
	TrOp[1] = "Explotion"
	TrOp[2] = "Anti-Gravity"
	TrOp[3] = "Slamming"
	playerlist:add_array_item("Troll by>", TrOp, function() return LsTr end, function(LsTr)
		if LsTr == 1 then
			ExplodePlayer(player.get_player_ped(selectedplayer))
		elseif LsTr == 2 then
			LaunchPlayer(player.get_player_ped(selectedplayer))
		else
			SlamPlayer(player.get_player_ped(selectedplayer))
		end
	end)
	
	--Teleport Options
	playerlist:add_int_range("Peek for(seconds)", 2, 1, 10, function() return 2 end, function(n) TeleportToPlayer(player.get_player_ped(selectedplayer), n) end)

 	local TPOp = {}
	TPOp[1] = "Yourself"
	TPOp[2] = "Closest Vehicle"
	TPOp[3] = "Peds"
	playerlist:add_array_item("Send to player>", TPOp, function() return LsTP end, function(LsTP)
		if LsTP == 1 then
			TeleportToPlayer(player.get_player_ped(selectedplayer))
		elseif LsTP == 2 then
			TeleportClosestVehicleToPlayer(player.get_player_ped(selectedplayer))
		else
			TeleportPedsToPlayer(player.get_player_ped(selectedplayer))
		end
	end)
end
-- List Updater
menu.add_bare_item("Auto-Updating Player List...", function() playerlist:clear() BuildListOld() end, null, null, null)