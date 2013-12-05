
local addonName, addon = ...

-- Convenience functions
local function print(...) _G.print("|cff708090GnomeBoy:|r", ...) end
local function _wd() return "Interface\\AddOns\\GnomeBoy\\" end

-- Save for future use
--"Interface\Buttons\UI-OptionsButton"

_G[addonName] = addon




function addon:LoadRom(romname)
	addon.Running = false;
	addon.Emulator:Restart()
	addon.Emulator:LoadRom(romname);
	addon.Running = true;
end

do
	local frameLimit = 40;
	local sinceLast = 0;
	local time = 1000/frameLimit;
	function addon:SetFrameLimit(limit)
		frameLimit = 40;
		time = 1000/frameLimit;
	end
	function addon:StartCycling()
		self:SetScript("OnUpdate",function(frame,elapsed)
			if (addon.Running == true) then
				sinceLast = sinceLast + elapsed*1000;
				if (sinceLast > time) then
					self.Emulator:Think();
					self.Emulator:Draw();
					sinceLast = 0;
				end
			end
		end);
	end
	function addon:Pause()
		addon.Running = false;
	end
	function addon:Unpause()
		addon.Running = true;
	end
	function addon:GetPaused()
		return addon.Running;
	end
end

function addon:Initialize()
	local gem = GBAgem
	addon.Emulator = gem.New();
	addon.changeable = true;
end


function GB_UseControl(string,bool)
	addon.Emulator:KeyChanged(string,bool)
end



------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

function eventFrame:ADDON_LOADED(loadedAddon)
	if loadedAddon ~= addonName then return end
	self:UnregisterEvent("ADDON_LOADED")

	addon:Initialize();
	print("Loaded.")

	self.ADDON_LOADED = nil
end

function eventFrame:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")

	addon:SetActiveSkin(addon:GetFirstSkin());
	
	addon:ShowEmulator();

	self.PLAYER_LOGIN = nil
end

------------------------------------------------------
function StartGameBoy()
	local self = GenerateGB()
	GB_GAMEBOY_INSTANCE = self;
end

BINDING_HEADER_GNOMEBOYADVANCE = "Gnome Boy Advance"