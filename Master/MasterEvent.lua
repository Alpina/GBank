----------------------------------------
-- Test
----------------------------------------
bool_mute = false;
bool_sorting = false;
bool_bank_is_open = false;

----------------------------------------
-- Slashcommands
----------------------------------------
SLASH_BLAH1 = "/gb"
SLASH_BLAH2 = "/guildbank"
SLASH_BLAH3 = "/gbank"
SlashCmdList["BLAH"] = function(msg)
    -- (0) Help
    if (msg == "help") then
    	SELECTED_CHAT_FRAME:AddMessage("\nGBank addon by |cff6495EDAlpinka|r: ".. Addon_Version);
    	SELECTED_CHAT_FRAME:AddMessage("/gb |c40e0d000s|rhow");
    	SELECTED_CHAT_FRAME:AddMessage("/gb |c40e0d000d|rebug");
    	SELECTED_CHAT_FRAME:AddMessage("/gb |c40e0d000v|rersion");
    	SELECTED_CHAT_FRAME:AddMessage("/gb |c40e0d000S|rorting");
    end	

    -- (1) Set visibility
    if (msg == "show") or (msg == "s") or (msg == "enable") or (msg == "") then
    	if Frame1:IsShown() then
			Frame1:Hide();
		else
			if (bool_bank_is_open == false) then
				Button1:Disable();
			else
				Button1:Enable();
			end

			Frame1:Show();
			Login_Updates_Check();
		end
	end

    -- (2) Set debug
	if (msg == "debug") or (msg == "d") then
		if bool_debug == false then
			bool_debug = true;
			SELECTED_CHAT_FRAME:AddMessage("Debug is|cffff0000 on|r");
		else
			bool_debug = false;
			SELECTED_CHAT_FRAME:AddMessage("Debug is|c0000ff00 off|r");
		end
	end

	-- (3) Show version
	if (msg == "ver") or (msg == "v") or (msg == "version") then
		SELECTED_CHAT_FRAME:AddMessage("GBank ver |cffff0000" .. Addon_Version .. "|r");
	end

	-- (4) Eneble\Disable sorting
	if (msg == "s") or (msg == "sort") or (msg == "sorting") then
		if (bool_sorting == true) then
			bool_sorting = false;
			SELECTED_CHAT_FRAME:AddMessage("Sorting is|c0000ff00 off|r");
		else
			bool_sorting = true;
			SELECTED_CHAT_FRAME:AddMessage("Sorting is|cffff0000 on|r");
		end
	end
end

----------------------------------------
-- Event registration
----------------------------------------
function GBank_OnLoad()
	Addon_Version = GetAddOnMetadata("GBank", "Version");
	TextLine1:SetText("GBank v" .. Addon_Version);
	
	-- Global values DB clean run
	if Buf_DB == nil then
		Buf_DB = {};
	end
	if Buf_DB_Timestamp == nil then
		Buf_DB_Timestamp = 0;
	end
	if Buf_DB_Unique == nil then
		Buf_DB_Unique = {};
	end
	if DB == nil then
		DB = {};
	end
	if DB_Timestamp == nil then
		DB_Timestamp = 0;
	end
	if DB_Unique == nil then
		DB_Unique = {};
	end

	this:RegisterEvent("CHAT_MSG_ADDON");
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("BANKFRAME_OPENED");
	this:RegisterEvent("BANKFRAME_CLOSED");
	this:RegisterEvent("MAIL_SHOW");
	this:RegisterEvent("MAIL_INBOX_UPDATE");
end


----------------------------------------
-- Event Functions
----------------------------------------
function GBank_OnEvent()
	-- Show login message
	if (event == "PLAYER_LOGIN") then
		SELECTED_CHAT_FRAME:AddMessage("GBank by|cff6495ED Alpinka|r |cff7fff7f" .. Addon_Version .. "|r loaded. Use |cff6495ED/gb|r to open UI.");
		return;
	end

	-- BankFrame open check
	if (event == "BANKFRAME_OPENED") then
		bool_bank_is_open = true;
		Button1:Enable();
		return;
	end

	if (event == "BANKFRAME_CLOSED") then
		bool_bank_is_open = false;
		Button1:Disable();
		return;
	end

	-- Resive addon messages
	if (event == "CHAT_MSG_ADDON") then
		
		if bool_debug == true then 
			debug_MSG(arg1, arg2, arg3, arg4); 
		end

		-- arg1 == prefix 
		-- arg2 == message
		-- arg3 == chanell
		-- arg4 == sender
		if (arg1 == GBank_SEND) then
			
			if (arg4 ~= UnitName("player")) and (bool_mute == true) then
				local _, _, player, id, suffix, count, price = string.find(arg2, "(%a+)%s(%d*)%s(%d*)%s(%d*)%s(%d*)");
				
				Receive_Update(player, id, suffix, count, price);
			end

			return
		end

		if (arg1 == GBank_UPD) then
			-- To update signal
			if (arg2 == "upd") and ( arg4 ~= UnitName("player")) then
				-- Send table data in to addon chat
				if bool_mute == false then
					Send_Data();
				end

				return
			end

			-- Mute Spam
			if (arg2 == "mute") and (arg4 ~= UnitName("player")) then
				if bool_debug == true then
					DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Debug|r: Mute by " .. arg4);
				end
				bool_mute = true;

				-- Clear old DB
				DB = {};
				Buf_DB = {};

				return
			end

			-- Unmute Spam
			if (arg2 == "unmute") and (arg4 ~= UnitName("player")) then
				if bool_debug == true then
					DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Debug|r: Unmute by " .. arg4);
				end

				if bool_mute == true then
					-- Copy Buf_DB to DB
					Update_DB();
				end

				-- Unmute addon
				bool_mute = false;

				return
			end


			if (arg2 ~= "upd") or (arg2 ~= "mute") or (arg2 ~= "unmute") then
				-- Resive timestamp
				tmp_message = tonumber(arg2);
				tmp_timestp = tonumber(DB_Timestamp);

				if (tmp_message ~= nil) and (tmp_timestp ~= nil) then
					if tmp_message > tmp_timestp then

						if bool_debug == true then
							DEFAULT_CHAT_FRAME:AddMessage("Forced Update by " .. arg4 .. " to version " .. arg2);
						end

						-- Update timestamp
						Buf_DB_Timestamp = tmp_message;

						-- Begin force update
						Force_Update();
					end
				end

				return
			end
		end

		if (arg1 == GBank_GET) then
			-- GET channel processing

			return;
		end

		if (arg1 == GBank_ADD) then
			tmp_message = tonumber(arg2);
			tmp_timestp = tonumber(DB_Timestamp);
			-- Reaction to Joined player
			if tmp_message < tmp_timestp then
				-- If timestamp of joined player DB lower then your DB - addon sed whisper message for update.
				SendAddonMessage(GBank_UPD, DB_Timestamp, "GUILD");
			end

			return;
		end
	end
end