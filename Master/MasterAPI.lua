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
Price_Str1 = "[b][color=yellow]";
Price_Str2 = "[/color] [color=lime]";
Price_Str3 = "[/color][/b]";
Price_Str4 = "[b][color=red]";

-- BB-Code string's
a1 = "[url=http://db.valkyrie-wow.com/?item="; a2 = "]"; a3 = "[/url] - ";
Buf_Table = {};
Buf_Name = "";

-- Bags Tables
Bags_Table = {};
Bags_Table_Buf = {};
bool_item_recive = false;
bool_mail_bdkp_help = true;
bool_mail_bdkp_help_first = false;

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
					if (Price_Table[Id] == nil) then
						output = output .. Quality_Table[Rarity] .. a1 .. Id .. a2 .. Name .. a3 .. Count .. Random_Chant_Str1 .. "(" .. Enchant_Suffix_Table[Suffix] .. ")" .. Random_Chant_Str2 .. "\n";
					else
						output = output .. Quality_Table[Rarity] .. a1 .. Id .. a2 .. Name .. a3 .. Count 
						.. Random_Chant_Str1 .. "(" .. Enchant_Suffix_Table[Suffix] .. ")" .. Random_Chant_Str2 .. ", " .. Price_Str1 .. "Price for " .. Price_Table[Id]["Count"] .. " items:" .. Price_Str2 .. Price_Table[Id]["Price"] .. Price_Str3 .. "\n";
					end
				else
					if (Price_Table[Id] == nil) then
						output = output .. Quality_Table[Rarity] .. a1 .. Id .. a2 .. Name .. a3 .. Count .. "\n";
					else
						output = output .. Quality_Table[Rarity] .. a1 .. Id .. a2 .. Name .. a3 .. Count 
						.. ", " .. Price_Str1 .. "Price for " .. Price_Table[Id]["Count"] .. " items:" .. Price_Str2 .. Price_Table[Id]["Price"] .. Price_Str3 .. "\n";
					end
				end
			end
		end
	end

	EditBox1:SetText(output);
end

function Print_Price_Table()
	output = "";

	for Id, Params in pairs(Price_Table) do
		local _, Link, Rarity, Level, MinLevel, Type, SubType, StackCount = GetItemInfo(Id);
		if (Params["Need"] == "0") then
			output = output .. Quality_Table[Rarity] .. a1 .. Id .. a2 .. Params["itemName"] .. a3 .. Price_Str1 .. "Price for " .. Params["Count"] .. " items:".. Price_Str2 .. Params["Price"] .. " dkp" .. Price_Str3 .. "\n";
		else
			output = output .. Quality_Table[Rarity] .. a1 .. Id .. a2 .. Params["itemName"] .. a3 .. Price_Str1 .. "Price for " .. Params["Count"] .. " items:".. Price_Str2 .. Params["Price"] .. " dkp." 
			.. Price_Str3 .. Price_Str4 .. " Items Need: " .. Params["Need"] .. Price_Str3 .. "\n";
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

----------------------------------------
-- Mail functions
----------------------------------------
bool_load_mail = 0;

function Scan_MailBox()
	if (bool_load_mail < GetInboxNumItems()) then
		bool_load_mail = bool_load_mail + 1;
	else
		if (GetInboxNumItems() > 0) then
			Mail_Table = {};
		
			for slot = 1, GetInboxNumItems() do
				name, itemTexture, count, quality = GetInboxItem(slot, 1);
				packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(slot);
				Mail_Table[slot] = {["Name"] = name, ["Count"] = count, ["Sender"] = sender};
			end
		end

		if (bool_mail_bdkp_help == true) then
			if (GetInboxNumItems() > 0) and (Mail_Table ~= nil) and (Price_Table ~= nil) then
				for slot, Params in pairs(Mail_Table) do
			
					if (Params["Name"] ~= nil) then
						Name = "["..Params["Name"].."]";
					end

					for id, Price_Params in pairs(Price_Table) do
						if (Name == Price_Params["itemName"]) then
					
							Price = tonumber(Price_Params["Price"]);
							Count = tonumber(Price_Params["Count"]);
					
							if (Count ~= 0) and (Params["Sender"] ~= nil) then
								Price = Price / Count;
								Price = Price * tonumber(Params["Count"]);
							
								if (Price ~= 0) then
									DEFAULT_CHAT_FRAME:AddMessage("|c40e0d000BDKP:|r" .. " sender |c0000ff00" .. Params["Sender"] .. "|r can recive |c0000ff00" .. Price .. "|r BDKP (" .. Params["Count"] .. "x " .. Price_Params["itemName"] .. ")");
								end

							else
								DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Error:|r Division by zero! Price is not correct.");
							end
						end
					end
				end
			end

			if (bool_mail_bdkp_help_first == false) then
				bool_mail_bdkp_help_first = true;
				bool_mail_bdkp_help = false;
			end
		end
	end
end

function Search_Mail(id, count)
	local Name, Link, Rarity, Level, MinLevel, Type, SubType, StackCount = GetItemInfo(id);

	for slot, params in pairs(Mail_Table) do
		if (Name == params["Name"]) and (count == params["Count"]) then
			return params["Sender"];
		end
	end
end

----------------------------------------
-- Bags functions
----------------------------------------
function Check_Bags(bag_id)
	if (bag_id == -1) then

		for bag = -1, 11 do
			for slot = 1, GetContainerNumSlots(bag) do
				local itemLink = GetContainerItemLink(bag, slot);
				
				if (itemLink ~= nil) then
					local texture, count, locked, quality, readable = GetContainerItemInfo(bag, slot);
					local _, _, Color, Ltype, id, enchantednt, Suffix = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d*):?(%d*):?(%d*)");

					
					if (Bags_Table[bag] == nil) then
						Bags_Table[bag] = {};	
					end 
					Bags_Table[bag][slot] = {["id"] = id, ["count"] = count};
				end
			end
		end
		return;
	end

	if (bag_id ~= -1) then

		Bags_Table_Buf = {};

		if (bag_id < 12) and (bag_id > -2) then
			for slot = 1, GetContainerNumSlots(bag_id) do
				local itemLink = GetContainerItemLink(bag_id, slot);
				
				if (itemLink ~= nil) then
					local texture, count, locked, quality, readable = GetContainerItemInfo(bag_id, slot);
					local _, _, Color, Ltype, id, enchantednt, Suffix = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d*):?(%d*):?(%d*)");

					Bags_Table_Buf[slot] = {["id"] = id, ["count"] = count};
				end
			end
		end

		for slot, param in pairs(Bags_Table_Buf) do
			Result = 0;
			if (Bags_Table[bag_id][slot] == nil) then
				Change_BDKP(tonumber(param["id"]), tonumber(Bags_Table_Buf[slot]["count"]));
				Check_Bags(-1);
				return;
			else
				if (Bags_Table[bag_id][slot]["count"] ~= Bags_Table_Buf[slot]["count"]) then
					Change_BDKP(tonumber(param["id"]), tonumber(Bags_Table_Buf[slot]["count"])-tonumber(Bags_Table[bag_id][slot]["count"]));
					Check_Bags(-1);
					return;
				end
			end
		end	
	end
end

function Change_BDKP(id, count_input)
	Sender = Search_Mail(id, count_input);
	
	if (Sender ~= nil) then
		if (BDKP_Table[Sender] == nil) then
			BDKP_Table[Sender] = 0;
		end
		if (BDKP_Log[Sender] == nil) then
			BDKP_Log[Sender] = {};
		end

		local Name, Link, Rarity, Level, MinLevel, Type, SubType, StackCount = GetItemInfo(id);
		Name = "["..Name.."]";
		for id, Price_Params in pairs(Price_Table) do
			if (Name == Price_Params["itemName"]) then
					
				Price = tonumber(Price_Params["Price"]);
				Count = tonumber(Price_Params["Count"]);
					
				if (Count ~= 0) then
					Price = (Price / Count) * count_input;
							
					if (Price ~= 0) then
						DEFAULT_CHAT_FRAME:AddMessage("|c40e0d000BDKP:|r" .. " |c0000ff00" .. Sender .. "|r +|c0000ff00" .. Price .. "|r BDKP (" .. count_input .. "x " .. Name .. ")");
						-- 
						Timestamp = time();
						BDKP_Log[Sender][Timestamp] = {["id"] = id, ["Count"] = count_input, ["dkp"] = Price, ["itemName"] = Name};
						-- 
						BDKP_Table[Sender] = BDKP_Table[Sender] + Price;
					end
				else
					DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Error:|r Division by zero! Price is not correct.");
				end
			end
		end
	end
end