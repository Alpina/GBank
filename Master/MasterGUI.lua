----------------------------------------
-- Buttons OnClick events
----------------------------------------
-- (1) "Parse" button
function Button1_OnClick()
	Parse();
	Print_Local_Table();
end

-- (2) "Close" button
function Button2_OnClick()
	Frame1:Hide();
end

-- (3) "Clear" clear editbox and focus button
function Button3_OnClick()
	EditBox1:SetText("");
	EditBox1:ClearFocus();
end

-- (4) "Print" Create Resulted DB button
function Button4_OnClick()
	Print_Local_Table();
end

-- (5) Release new version of DB
function Button5_OnClick()
	Sync_DB();
end

-- (6) Open Bank Table
function Button6_OnClick()
	if Frame2:IsShown() then
		Frame2:Hide();
	else
		Frame2:Show();
	end
end

-- (7) Print Price list
function Button7_OnClick()
	Print_Price_Table();
end