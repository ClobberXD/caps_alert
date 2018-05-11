--
-- caps_alert
--

local violations = {}

-- Resets number of violations on player (re-)join
minetest.register_on_joinplayer(function(player)
	violations[player] = 0
end)

minetest.register_on_chat_message(function(name, message)
	if (message == message:upper()) and (message:len() > 4) then
		minetest.show_formspec(name, "caps_alert:warning",
					"size[6,3]" ..
					"label[0,0.5;Stop using excessive CAPS,\nYou will be kicked if you keep using CAPS again]" ..
					"button_exit[1,2;4,1;exit;OK]"
		)
		
		violations[name] = (violations[name] or 0) + 1
		if violations[name] > 3 then
			for _, player in pairs(minetest.get_connected_players()) do
				minetest.kick_player(name, "Use of excessive CAPS")
				
				local moderator = player:get_player_name()
				if minetest.check_player_privs(player_name, {kick = true, ban = true}) then
					minetest.chat_send_player(player_name, minetest.colorize("#FFFF00",
							"-!- " .. name .. " has been kicked for use if excessive CAPS."))
				end
			end
		end
		
		return true
	end
	
	return false
end)

local kick_player = function(name)
	minetest.kick_player(name, "Use of excessive CAPS")
	
	for _, player in pairs(minetest.get_connected_players()) do
		local moderator = player:get_player_name()
		if minetest.check_player_privs(moderator, {kick = true, ban = true}) then
			minetest.chat_send_player(moderator, minetest.colorize("#FFFF00",
					"-!- " .. name .. " has been kicked for use if excessive CAPS."))
		end
	end
end
