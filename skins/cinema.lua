local addonName, addon = ...

-- Convenience functions
local function print(...) _G.print("|cff708090GnomeBoy:|r", ...) end
local function _wd() return "Interface\\AddOns\\GnomeBoy\\" end

local function generate()
	local self = CreateFrame("Frame",nil,UIParent)

	
	self:SetFrameLevel(1);
	
	do
		self.BG = CreateFrame("Frame",nil,self);
		local bg = self.BG;
		bg:SetAllPoints(UIParent);
		bg:SetFrameStrata("BACKGROUND");
		local t = bg:CreateTexture(nil,"OVERLAY",nil);
		t:SetTexture(0,0,0,1);
		t:SetAllPoints(bg);
	end

	-- do
	-- 	self.Screen = CreateFrame("Frame",nil,self)
	-- 	local screen = self.Screen;
	-- 	-- screen:SetFrameLevel(8)
	-- 	-- screen:SetFrameStrata("FULLSCREEN");
	-- 	screen:SetSize(160*2,144*2);
	-- 	screen:SetPoint("CENTER");

	-- 	local t = screen:CreateTexture(nil,"OVERLAY",nil,5);
	-- 	t:SetTexture(169/255,169/255,169/255,1);
	-- 	t:SetAllPoints(screen);

	-- 	print(screen:IsVisible())
	-- end

	self.Options = CreateFrame("Button",nil,self);
	self.Options:SetSize(25,25);
	self.Options:SetPoint("RIGHT",UIParent,"RIGHT")
	self.Options:SetNormalTexture("Interface\\Buttons\\UI-SquareButton-Up.tga")
	self.Options:SetPushedTexture("Interface\\Buttons\\UI-SquareButton-Down.tga")
	self.Options:SetDisabledTexture("Interface\\Buttons\\UI-SquareButton-Disabled.tga")
	self.Options:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight.tga")
	do
		self.Options.Icon = self.Options:CreateTexture(nil,"OVERLAY",nil,5)
		self.Options.Icon:SetTexture("Interface\\Buttons\\UI-OptionsButton.tga")
		local opSize = self.Options:GetWidth()*.5;
		self.Options.Icon:SetSize(opSize,opSize)
		self.Options.Icon:SetPoint("CENTER",self.Options,"CENTER")
		self.Options.Icon:Show()
	end

	self.Screen = CreateFrame("Frame",nil,self)
	local screen = self.Screen;
	-- screen:SetFrameLevel(8)
	-- screen:SetFrameStrata("FULLSCREEN");
	screen:SetSize(160*4,144*4);
	screen:SetPoint("CENTER",UIParent,"CENTER");

	local t = screen:CreateTexture(nil,"OVERLAY",nil,5);
	t:SetTexture(169/255,169/255,169/255,1);
	t:SetAllPoints(screen);



	self:SetPoint("CENTER",UIParent,"CENTER")
	function self:SetChangeable(bool)
		if (bool == true) then
			t:Show();
		else
			t:Hide();
		end
	end
	return self;
end

addon:RegisterSkin("Cinema",generate);