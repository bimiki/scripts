menu.add_action("we do a little trolling", function()
    i = 0
    rot = 0
    repeat
        for v in replayinterface.get_vehicles() do
            if v and not (localplayer:get_current_vehicle() == v) then
                rot = v:get_rotation()
                v:set_rotation(rot + rot)
                -- v:set_health(-1)
            end
 
            i = i + 1
        end
    until i == 10000000
end)