local function Text(text)
	menu.add_action(text, function() end)
end
 
local function sqrt(i)
	return i^0.5
end
 
local function DistanceToSqr(vec1, vec2)
	return ((vec2.x - vec1.x)^2) + ((vec2.y - vec1.y)^2) + ((vec2.z - vec1.z)^2)
end
 
local function Distance(vec1, vec2)
	return sqrt(DistanceToSqr(vec1, vec2))
end
 
local function onodot(n)
	local l = 0 
	for i = n-1, n do
		l = i
	end
	return l
end
 
function round(number)
	return number - (number % 1)
end
local plys = 0
 
for p in replayinterface.get_peds() do
	if p == nil then
		goto continue
	end
 
	if p:get_pedtype() >= 4 then
		goto continue
	end
 
	plys = plys + 1
	::continue::
end
 
local selectedplayer = -1
 
local function act(action)
	if selectedplayer == -1 then Text("No selected player") return end
	local p = nil
 
	local b = 1
	for p in replayinterface.get_peds() do
		if (p == nil) then
			return
		end
		
		if p:get_pedtype() >= 4 then
			goto continue
		end
 
		if b == selectedplayer then
			if action == 0 then
				local pos = p:get_position()
				if not localplayer:is_in_vehicle() then
					localplayer:set_position(pos)
				else
					localplayer:get_current_vehicle():set_position(pos)
				end
			elseif action == 1 then
				local pos = p:get_position()
 
				local veh = nil 
				if localplayer:is_in_vehicle() then
					veh = localplayer:get_current_vehicle()
				end
 
				for v in replayinterface.get_vehicles() do
					if veh and veh == v then
						goto com
					end
					v:set_position(pos)
					::com::
				end
			elseif action == 2 then
				local pos = p:get_position()
				--menu.kill_all_vehicles()
				local veh = nil 
				if localplayer:is_in_vehicle() then
					veh = localplayer:get_current_vehicle()
				end
				for v in replayinterface.get_vehicles() do
					if veh and veh == v then
						goto co
					end
					--v:set_health(-1)
					--v:set_model_hash(-150975354)
					v:set_health(-1)
					v:set_position(pos)
					::co::
				end
			elseif action == 3 then
				local pos = p:get_position()
				for v in replayinterface.get_peds() do
					if v == nil then
						goto contin
					end
 
					if v:get_pedtype() < 4 then
						goto contin
					end
 
					v:set_position(pos)
					::contin::
				end
			elseif action == 4 then
				local pos = p:get_position()
				for v in replayinterface.get_pickups() do
					v:set_position(vector3(pos.x,pos.y,pos.z))
				end
			end
			return
		end
 
		b = b + 1
		::continue::
	end
 
	
end
 
menu.add_action("Teleport to player", function() act(0) end)
menu.add_action("Teleport vehicles to player", function() act(1) end)
menu.add_action("Teleport peds to player", function() act(3) end)
menu.add_action("Explode player", function() act(2) end)
--menu.add_action("Test", function() act(4) end)
 
Text("---Player List, "..plys.." Players---")
--menu.addaction("-Update-")
 
local pID = 1
local j = 1
local near = 100000
for p in replayinterface.get_peds() do
 
	if p == nil then
		goto continue
	end
 
	if p:get_pedtype() >= 4 then
		goto continue
	end
 
	local x = 1
	local distance
	local yes = true
	distance = round(onodot(Distance(p:get_position(), localplayer:get_position())))
	
	if distance < near then
		if distance == 0 then
			goto continue
		else 
			j = 0
			j = x
			pID = 0
			pID = p:get_player_id()
			near = distance
		end
		x = x + 1 
	end
	::continue::
end
 
local i = 1
for p in replayinterface.get_peds() do
	if p == nil then
		goto continue
	end
 
	if p:get_pedtype() >= 4 then
		goto continue
	end
 
	local god = ""
	if p:get_godmode() and p:is_in_vehicle() then
		god = " I Modder"
	elseif p:get_godmode() then
		god = " I   God   "
	elseif p:is_in_vehicle() then
		god = " I Vehicle"
	else
		god = " I            "
	end
 
	local nearest = ""
	if pID == p:get_player_id() then
		if j == i then
		
		nearest = " I <----"
		end	
	elseif j == i then
		nearest = " I <----"
	end
 
 
	local distance  = " I "..round(onodot(Distance(p:get_position(), localplayer:get_position()))).." m."
 
	local health = " "..p:get_health().." HP"
 
	local wanted = " "..p:get_wanted_level().."*"
 
	local lp = " I Player"
	if p == localplayer then
		lp = " I -YOU-"
	end
 
	local space = "   "
	if i >= 10 then
		space = " "
	end
 
	--local wallet = " I "..p:get_wallet().." $"
 
	local text = i..space..lp..god..distance..nearest
	
	local d = i
 
	menu.add_toggle(text, function()
		if selectedplayer == d then
			return true
		else
			return false
		end
	end, function(val)
		selectedplayer = d
	end)
 
	i = i + 1
	::continue::
end
 
Text("---End---")