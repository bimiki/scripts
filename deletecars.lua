local function TPCars()
	repeat
	sleep(0.01)
			local currentvehicle = nil 
 
	if localplayer:is_in_vehicle() then
		currentvehicle = localplayer:get_current_vehicle()
	end
 
	for veh in replayinterface.get_vehicles() do
                local pos = veh:get_position()
		if not currentvehicle or currentvehicle ~= veh then
			pos.x = pos.x
			pos.y = pos.y
			pos.z = pos.z - 100000
			veh:set_position(pos)
		end
	end
	until(localplayer:is_in_vehicle() == false)
end
 
menu.add_action("Delete ALL Cars", function() TPCars() end)