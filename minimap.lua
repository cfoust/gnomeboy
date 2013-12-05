local addonName, addon = ...

local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then return end

local function print(...) _G.print("|cff708090GnomeBoy:|r", ...) end

local plugin = ldb:NewDataObject(addonName, {
	type = "data source",
	icon = "Interface\\Icons\\INV_Misc_Head_ClockworkGnome_01",
})

local hidden = true;
function plugin.OnClick(self, button)
	hidden = not hidden;
	if (hidden == true) then
		addon:HideEmulator()
	else
		addon:ShowEmulator()
	end
end

function plugin.OnTooltipShow(tt)
	tt:AddLine("|cff708090GnomeBoy:|r Click to show/hide the emulator.")
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	local icon = LibStub("LibDBIcon-1.0", true)
	if not icon then return end
	if not GnomeBoyLDBIconDB then GnomeBoyLDBIconDB = {} end
	icon:Register(addonName, plugin, GnomeBoyLDBIconDB)
end)
f:RegisterEvent("PLAYER_LOGIN")