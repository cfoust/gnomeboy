
local addonName, addon = ...

-- Convenience functions
local function print(...) _G.print("|cff708090GnomeBoy:|r", ...) end
local function _wd() return "Interface\\AddOns\\GnomeBoy\\" end

-- Save for future use
--"Interface\Buttons\UI-OptionsButton"

_G[addonName] = addon




function addon:LoadRom(romname)
	addon.Running = false;
	if addon.currentRom then
		addon:SaveRAM();
	end
	addon.Emulator:Restart()
	addon:LoadRAM(romname);
	addon.Emulator:LoadRom(romname);
	addon.currentRom = romname;
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
		local f = CreateFrame("Frame",nil,UIParent)
		f:SetScript("OnUpdate",function(frame,elapsed)
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

function addon:LoadEmulator()
	addon:LockSkin();
	addon:StartCycling();
end


if not GB_RAM_STORE then GB_RAM_STORE = {} end

do
	local function shallowcopy(orig)
	    local orig_type = type(orig)
	    local copy
	    if orig_type == 'table' then
	        copy = {}
	        for orig_key, orig_value in pairs(orig) do
	            copy[orig_key] = orig_value
	        end
	    else -- number, string, boolean, etc
	        copy = orig
	    end
	    return copy
	end

	function addon:SaveRAM()
		local name = addon.currentRom;
		if name then
			if not GB_RAM_STORE[name] then 
				GB_RAM_STORE[name] = {} 
			end
			local RAM = addon.Emulator.RAM
			for k,v in pairs(RAM) do
				if (v ~= 0) then
					GB_RAM_STORE[name][k] = v;
				end
			end
		end
	end

	function addon:LoadRAM(name)
		if GB_RAM_STORE[name] then
			local RAMStore = GB_RAM_STORE[name]
			for k,v in pairs(RAMStore) do
				self.Emulator.RAM[k] = v;
			end
		end
		
	end
end






function GB_UseControl(string,bool)
	addon.Emulator:KeyChanged(string,bool)
end



------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

function eventFrame:ADDON_LOADED(loadedAddon)
	if loadedAddon ~= addonName then return end
	self:UnregisterEvent("ADDON_LOADED")

	addon:Initialize();

	self.ADDON_LOADED = nil
end

function eventFrame:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")

	addon:SetActiveSkin(addon:GetFirstSkin());
	addon:HideEmulator();

	self.PLAYER_LOGIN = nil
end

function eventFrame:PLAYER_LOGOUT()
	self:UnregisterEvent("PLAYER_LOGOUT")

	addon:SaveRAM();

	self.PLAYER_LOGOUT = nil
end

local combatSuspend = false;

function eventFrame:PLAYER_REGEN_DISABLED()
	if addon:Visible() then
		combatSuspend = true;
		addon:HideEmulator();
	end
end

function eventFrame:PLAYER_REGEN_ENABLED()
	if combatSuspend == true then
		addon:ShowEmulator();
		combatSuspend = false;
	end
end

------------------------------------------------------


--Binding globals
BINDING_HEADER_GNOMEBOYADVANCE = "Gnome Boy"
BINDING_NAME_GB_START = "Start"
BINDING_NAME_GB_SELECT = "Select"
BINDING_NAME_GB_A = "A"
BINDING_NAME_GB_B = "B"
BINDING_NAME_GB_UP = "Up"
BINDING_NAME_GB_DOWN = "Down" 
BINDING_NAME_GB_LEFT = "Left"
BINDING_NAME_GB_RIGHT = "Right"