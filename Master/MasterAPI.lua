----------------------------------------
-- Global API Values
----------------------------------------
-- BB-Code quality Table
Quality_Table = {
	[0] = "[color=#9d9d9d][b](P)[/b][/color] ",
	[1] = "[color=#ffffff][b](C)[/b][/color] ",
	[2] = "[color=#1eff00][b](U)[/b][/color] ",
	[3] = "[color=#0070dd][b](R)[/b][/color] ",
	[4] = "[color=#a335ee][b](E)[/b][/color] ",
	[5] = "[color=#ff8000][b](L)[/b][/color] ",
	[6] = "[color=#e6cc80][b](A)[/b][/color] "
};
-- BB-Code Random Chant color
Random_Chant_Str1 = " [Color=#489FDA][b]";
Random_Chant_Str2 = "[/b][/color]";
-- BB-Code string's
a1 = "[url=http://db.valkyrie-wow.com/?item="; a2 = "]"; a3 = "[/url] - ";
Buf_Table = {};
Buf_Name = "";
-----------------------------------------
-- Parser Function
-----------------------------------------
function Parse()
	Local_Table = {};

	for bag = -1, 11 do
		for slot = 1,GetContainerNumSlots(bag) do
			-- Get itemLink
			local itemLink = GetContainerItemLink(bag, slot);
			
			if (itemLink ~= nil) then
				-- Get slot info
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag,slot);
				local _, _, Color, Ltype, Id, Enchant, Suffix = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d*):?(%d*):?(%d*)");

				-- Random enchanted suffix
				if ((bool_debug == true) and (Suffix ~= "0")) then
					ItemString_Show(Color, Ltype, Id, Enchant, Suffix);
				end 

				local Tmp_Suffix = {}; Tmp_Suffix[Suffix] = {["Price"] = 0, ["Count"] = 0};

				if (Local_Table[Id] == nil) then
					Local_Table[Id] = Tmp_Suffix;
				else
					if (Local_Table[Id][Suffix] == nil) then
						Local_Table[Id][Suffix] = {["Price"] = 0, ["Count"] = 0};
					end
				end

				Local_Table[Id][Suffix]["Count"] = Local_Table[Id][Suffix]["Count"] + itemCount;
			end
		end
	end

	-- Player Sign
	Local_Nickname, realm = UnitName("player");
	-- Timestamp
	Local_Timestamp = tonumber(time());

	if bool_debug == true then
		DEFAULT_CHAT_FRAME:AddMessage("Timestamp: " .. Local_Timestamp .. "\nName sign: " .. Local_Nickname);
	end

	if boll_sorting == true then
		-- Test function
		Sorting();
	else
		-- Default
		Buf_DB_ADD();
	end

end

-----------------------------------------
-- Unique sorting
-----------------------------------------
function Sorting()


	-- Add Buf_Table to Buf_DB
	Buf_DB_ADD();
end

-----------------------------------------
-- Output table
-----------------------------------------
function Print_Local_Table()
	-- nil check
	if (Local_Table == nil) then
		DEFAULT_CHAT_FRAME:AddMessage("Open your bank to display data.");
		return;
	end 

	output = "";

	for Id, Item in pairs(Local_Table) do

		-- Get Name
		local Name, Link, Rarity, Level, MinLevel, Type, SubType, StackCount = GetItemInfo(Id);

		for Suffix, Params in pairs(Item) do

			Price = Params["Price"];
			Count = Params["Count"];

			if (Suffix == nil) then
				output = output .. Quality_Table[Rarity] .. a1 .. Id .. a2 .. Name .. a3 .. Count .. "\n";
				DEFAULT_CHAT_FRAME:AddMessage("GBank: UNKNOWN RANDOM BONUS! id: " .. Id .. " suffix: " .. Suffix);
			else
				if (Suffix ~= "0") then
					-- With random chant
					output = output .. Quality_Table[Rarity] .. a1 .. Id .. a2 .. Name .. a3 .. Count .. Random_Chant_Str1 .. "(" .. Enchant_Suffix_Table[Suffix] .. ")" .. Random_Chant_Str2 .. "\n";
				else
					output = output .. Quality_Table[Rarity] .. a1 .. Id .. a2 .. Name .. a3 .. Count .. "\n";
				end
			end
		end
	end

	EditBox1:SetText(output);
end

----------------------------------------
-- DB Syncronization functions
----------------------------------------
function Login_Updates_Check()
	-- send upload addon message (send timestamp)
	SendAddonMessage(GBank_ADD, DB_Timestamp, "GUILD");
	if bool_debug == true then
		DEFAULT_CHAT_FRAME:AddMessage("GBank: Check for updates");
	end	
end


function Buf_DB_ADD()
	-- Add local DB data to main DB
	Buf_DB[Local_Nickname] = Local_Table;
	Buf_DB_Timestamp = Local_Timestamp;

	Update_DB();
end


function Update_DB()
	-- Update actual table data
	DB = Buf_DB;
	DB_Timestamp = Buf_DB_Timestamp;
end


function Sync_DB()
	-- Send signal about new DB version
	if bool_mute == false then
		SendAddonMessage(GBank_UPD, DB_Timestamp, "GUILD");
	end
end


function Force_Update()
	-- Function to force update
	if bool_mute == false then
		SendAddonMessage(GBank_UPD, "upd", "GUILD");
	end
end


function Send_Data()
	-- Stop-spam signal
	SendAddonMessage(GBank_UPD, "mute", "GUILD"); -- mute spam

	-- Send fresh table
	for Player, ItemTable in pairs(DB) do
		for Id, Item in pairs(ItemTable) do
			for Chant, Params in pairs(Item) do
				SendAddonMessage(GBank_SEND, Player .. " " .. Id .. " " .. Chant .. " " .. Params["Count"] .. " " .. Params["Price"], "GUILD");
			end
		end
	end

	SendAddonMessage(GBank_UPD, "unmute", "GUILD"); -- unmute
end


function Receive_Update(player, id, suffix, count, price)
	count = tonumber(count);

	if ((id == nil) or (count == nil) or (player == nil) or (suffix == nil) or (price == nil)) then
		DEFAULT_CHAT_FRAME:AddMessage("Error in table updating! (nil in the received values)");
		return;
	end

	if (Buf_Name ~= player) then
		Buf_Table = {};
		Buf_Name = player;
	end
	
	local Tmp = {};
	Tmp[suffix] = {["Count"] = count, ["Price"] = price};

	-- Add data in to DB
	if (Buf_Table[id] == nil) then
		Buf_Table[id] = Tmp;
	else
		Buf_Table[id][suffix] = {["Count"] = count, ["Price"] = price};
	end

	Buf_DB[player] = Buf_Table;

	return;
end