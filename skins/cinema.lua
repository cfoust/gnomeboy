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

	

	self.Screen = CreateFrame("Frame",nil,self)
	local screen = self.Screen;
	screen:SetSize(160*4,144*4);
	screen:SetPoint("CENTER",UIParent,"CENTER");

	self.Options = CreateFrame("Button",nil,self);
	self.Options:SetSize(40,40);
	self.Options:SetPoint("TOP",screen,"BOTTOM")
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

	local baseColor = {
		["r"] = 148,
		["g"] = 189,
		["b"] = 32
	};
	local darkColor = {
		["r"] = 43,
		["g"] = 54,
		["b"] = 10
	};

	local t = screen:CreateTexture(nil,"OVERLAY",nil,5);
	t:SetTexture(baseColor.r/255,baseColor.g/255,baseColor.b/255,1);
	t:SetAllPoints(screen);

	self.screenText = screen:CreateFontString(nil,"OVERLAY",2)
	local text = self.screenText;
	text:SetTextColor(darkColor.r/255,darkColor.g/255,darkColor.b/255,1);
	text:SetJustifyH("CENTER");
	text:SetJustifyV("CENTER");
	local textHeight = .05*self.Screen:GetHeight();
	text:SetFont(_wd().."fonts\\pretendo.ttf",textHeight);
	text:SetPoint("CENTER",self.Screen,"CENTER");
	for i=1,textHeight do text:SetTextHeight(i); end
	text:SetText("Screen")



	self:SetPoint("CENTER",UIParent,"CENTER")
	function self:SetChangeable(bool)
		ChatFrame1:SetFrameLevel(2)
		ChatFrame1:ScrollToBottom();
		if (bool == true) then
			t:Show();
			text:Show();
		else

			t:Hide();
			text:Hide();
		end
	end
	return self;
end

addon:RegisterSkin("Cinema",generate);