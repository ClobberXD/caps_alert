--
-- caps_alert
--

local violations = {}

-- Resets number of violations on player (re-)join
minetest.register_on_joinplayer(function(player)
	violations[player] = 0
end)

-- checks messages for CAPITAL letters, catches NEarLY all caps messages too
function checkMessages(message)
	local capscounter = 0 -- used to count capital letters in messages

	--[[ 
	 iterate over each character in a message, 
	 incrementing "capscounter" for every character that is capital
	--]]
	for i = 1, #message do
		local char = message:sub(i,i)
		-- replace anything that isn't a letter with a lower case "a"
		-- else it picks up spaces, numbers, and other special characters as capital letters
		char = char:gsub('%A', 'a') 
		if char == char:upper() then
			capscounter = capscounter + 1
		end
	end
	if capscounter >= 1 then
		return(true)
	end
end

minetest.register_on_chat_message(function(name, message)
	if (checkMessages(message) == true) and (message:len() > 4) then
		minetest.show_formspec(name, "caps_alert:warning",
					"size[7.5,3]" ..
					"label[1.5,0.5;Stop using excessive CAPS!]" ..
					"label[0.75,1;You will be kicked if you don't stop using CAPS.]" ..
					"button_exit[1.5,2;4,1;exit;OK]"
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
