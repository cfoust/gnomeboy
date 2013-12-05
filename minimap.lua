local addonName, addon = ...

local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then return end

local function print(...) _G.print("|cff708090GnomeBoy:|r", ...) end

local plugin = ldb:NewDataObject(addonName, {
	type = "data source",
	icon = "Interface\\AddOns\\BugSack\\Media\\icon",
})

function plugin.OnClick(self, button)
	print(self,button)
end

function plugin.OnTooltipShow(tt)
	tt:AddLine("This is a test")
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	local icon = LibStub("LibDBIcon-1.0", true)
	if not icon then return end
	if not GnomeBoyLDBIconDB then GnomeBoyLDBIconDB = {} end
	icon:Register(addonName, plugin, GnomeBoyLDBIconDB)
end)
f:RegisterEvent("PLAYER_LOGIN")