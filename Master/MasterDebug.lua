----------------------------------------
-- Debug option
----------------------------------------
bool_debug = true;
debug_string = "|cffff0000Debug|r: |c0000ff00";

----------------------------------------
-- Addon's chanells debug
----------------------------------------
function  debug_MSG(arg1, arg2, arg3, arg4)
	SELECTED_CHAT_FRAME:AddMessage(debug_string .. arg1 .. " |r: " .. arg2 .. " : " .. arg3 .. " : " .. arg4);	
end

----------------------------------------
-- ItemLine show
----------------------------------------
function  ItemString_Show(Color, Ltype, Id, Enchant, Suffix, quality)
	SELECTED_CHAT_FRAME:AddMessage(debug_string .. Color .. " " .. Ltype .. " " .. Id .. " " .. Enchant .. " " .. Suffix);
	SELECTED_CHAT_FRAME:AddMessage(debug_string .. Enchant_Suffix_Table[Suffix]);
end