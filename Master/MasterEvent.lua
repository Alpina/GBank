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
    	SELECTED_CHAT_FRAME:AddMessage("/gb |c40e0d000s|rorting");
    	SELECTED_CHAT_FRAME:AddMessage("/gb |c40e0d000p|rice [itemLink] [Price] [Count] [Need Count]");
    	SELECTED_CHAT_FRAME:AddMessage("/gb |c40e0d000bdkp|r [Name]");
    	SELECTED_CHAT_FRAME:AddMessage("/gb |c40e0d000bdkp help|r");
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
		return;
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
		return;
	end

	-- (3) Show version
	if (msg == "ver") or (msg == "v") or (msg == "version") then
		SELECTED_CHAT_FRAME:AddMessage("GBank ver |cffff0000" .. Addon_Version .. "|r");
		return;
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
		return;
	end

	-- (5) Set Price
	if (string.find(msg, "p") == 1) then
		local _, _, Color, Ltype, Id, Enchant, Suffix, par1, Name, Price, Count, Need = string.find(msg, "^p%s|?c?f?f?(%x*)|?H?([^:]*):?(%d*):?(%d*):?(%d*):?(%d*)|?h?([^|]*)|?h|?r%s(%d*)%s(%d*)%s(%d*)");
		
		if (Color ~= nil) and (Ltype ~= nil) and (Id ~= nil) and (Enchant ~= nil) and (Suffix ~= nil) and (Name ~= nil) then
			if (Price == nil) or (Count == nil) or (Need == nil) then
				SELECTED_CHAT_FRAME:AddMessage("|cffff0000Err|r: Please, type price after ItemLink and count.");
			else
				if (Need == "0") and (Count == "0") and (Price == "0") then
					-- (5.1) del item
					if (Price_Table[Id] ~= nil) then
						Buf_Price_Table = {};
						for table_Id, Params in pairs(Price_Table) do
							if (table_Id ~= Id) then
								Buf_Price_Table[Id] = Params;
							end
						end
						Price_Table = Buf_Price_Table;
						SELECTED_CHAT_FRAME:AddMessage("Delete " .. Name .. " form price table." );
						return;
					end
				end

				if (Need == "0") then
					SELECTED_CHAT_FRAME:AddMessage("Item Id: " .. Id .. " name: " .. Name .. ", Price = " .. Price .. " for " .. Count .. " items.");
				else
					SELECTED_CHAT_FRAME:AddMessage("Item Id: " .. Id .. " name: " .. Name .. ", Price = " .. Price .. " for " .. Count .. " items. Need: " .. Need .. " items.");
				end

				if (Price_Table == nil) then
					Price_Table = {};
				end

				Params = {["itemName"] = Name, ["Price"] = Price, ["Count"] = Count, ["Need"] = Need};
				Price_Table[Id] = Params;
			end
		else
			local _, _, Id, Price, Count, Need = string.find(msg, "^p%s(%d*)%s(%d*)%s(%d*)%s(%d*)");
			
			if (Need == "0") and (Count == "0") and (Price == "0") then
				-- (5.1) del item
				if (Price_Table[Id] ~= nil) then
					Buf_Price_Table = {};
					for table_Id, Params in pairs(Price_Table) do
						if (table_Id ~= Id) then
							Buf_Price_Table[Id] = Params;
						end
					end
					Price_Table = Buf_Price_Table;
					local Name, Link, Rarity, Level, MinLevel, Type, SubType, StackCount = GetItemInfo(Id);
					SELECTED_CHAT_FRAME:AddMessage("Delete [" .. Name .. "] form price table." );
					return;
				end
			end

			if (Price == nil) or (Count == nil) or (Need == nil) then
				SELECTED_CHAT_FRAME:AddMessage("|cffff0000Err|r: Please, type price after ItemLink and count.");
			else
				local Name, Link, Rarity, Level, MinLevel, Type, SubType, StackCount = GetItemInfo(Id);
				
				if (Name ~= nil) then
					if (Need == "0") then
						SELECTED_CHAT_FRAME:AddMessage("Item Id: " .. Id .. " name: [" .. Name .. "], Price = " .. Price .. " for " .. Count .. " items.");
					else
						SELECTED_CHAT_FRAME:AddMessage("Item Id: " .. Id .. " name: [" .. Name .. "], Price = " .. Price .. " for " .. Count .. " items. Need: " .. Need .. " items.");
					end

					if (Price_Table == nil) then
						Price_Table = {};
					end

					Params = {["itemName"] = "["..Name.."]", ["Price"] = Price, ["Count"] = Count, ["Need"] = Need};
					Price_Table[Id] = Params;
				else
					SELECTED_CHAT_FRAME:AddMessage("Item not avable, check your ID.");
				end
			end
		end
		return;
	end

	-- (6) Get player BDKP
	if (string.find(msg, "bdkp") == 1) then
		local _, _, Name = string.find(msg, "^bdkp%s(%S+)");
		if (Name ~= "help") then
			if (BDKP_Table[Name] ~= nil) then
				SELECTED_CHAT_FRAME:AddMessage("|c40e0d000BDKP:|r|c0000ff00 " .. Name .. "|r dkp = |c0000ff00" .. BDKP_Table[Name] .. "|r");
			else
				SELECTED_CHAT_FRAME:AddMessage("|c40e0d000BDKP:|r|c0000ff00 " .. Name .. "|r dkp = |c0000ff000|r");
			end
		end
		return;
	end

	-- (7) On\Off BDKP Help
	if (msg == "bdkp help") then
		if (bool_mail_bdkp_help == false) then
			bool_mail_bdkp_help = true;
			SELECTED_CHAT_FRAME:AddMessage("|c40e0d000BDKP Mail Help|r is|cffff0000 on|r");
		else
			bool_mail_bdkp_help = false;
			SELECTED_CHAT_FRAME:AddMessage("|c40e0d000BDKP Mail Help|r is|c0000ff00 off|r");
		end
		return;
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
	if Price_Table == nil then
		Price_Table = {};
	end
	if Mail_Table == nil then
		Mail_Table = {};
	end
	if BDKP_Table == nil then
		BDKP_Table = {};
	end
	if BDKP_Log == nil then
		BDKP_Log = {};
	end

	this:RegisterEvent("CHAT_MSG_ADDON");
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("BANKFRAME_OPENED");
	this:RegisterEvent("BANKFRAME_CLOSED");
	this:RegisterEvent("MAIL_SHOW");
	this:RegisterEvent("MAIL_INBOX_UPDATE");

	this:RegisterEvent("BAG_UPDATE");
end


----------------------------------------
-- Event Functions
----------------------------------------
function GBank_OnEvent()
	-- Show login message
	if (event == "PLAYER_LOGIN") then
		Check_Bags(-1); -- scan all bags
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

	if (event == "MAIL_INBOX_UPDATE") then
		bool_item_recive = true;
		Scan_MailBox();
		return;
	end
	-------------------------------------------------------------
	if (event == "BAG_UPDATE") then
		if (bool_item_recive == true) then
			Check_Bags(arg1);
			bool_item_recive = false;
		end
		return;
	end
	-------------------------------------------------------------

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