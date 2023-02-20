local addonName, addon = ...

-- Convenience functions
local function print(...) _G.print("|cff708090GnomeBoy:|r", ...) end
local function _wd() return "Interface\\AddOns\\GnomeBoy\\" end

-- Convenience functions
local function print(...) _G.print("|cff708090GnomeBoy:|r", ...) end
local function _wd() return "Interface\\AddOns\\GnomeBoy\\" end

local function generate()
	local self = CreateFrame("Frame",nil,UIParent)

	self:SetSize(160*4,144*4);
	self:SetPoint("CENTER",UIParent,"CENTER");
	self:SetFrameLevel(5);

	local biggerButton = CreateFrame("Button",nil,self)
	biggerButton:SetSize(50,50)
	biggerButton:SetPoint("TOPRIGHT",self,"TOPLEFT");

	local smallerButton = CreateFrame("Button",nil,self)
	smallerButton:SetSize(50,50)
	smallerButton:SetPoint("TOPRIGHT",biggerButton,"BOTTOMRIGHT");
	do
		biggerButton:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up.tga");
		biggerButton:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down.tga")
		biggerButton:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled.tga")
		biggerButton:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight.tga")
		smallerButton:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up.tga");
		smallerButton:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down.tga")
		smallerButton:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled.tga")
		smallerButton:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight.tga")
	end

	self.Screen = CreateFrame("Frame",nil,self)
	local screen = self.Screen;
	screen:SetAllPoints(self);

	local hardOps = CreateFrame("Button",nil,self);
	hardOps:SetAllPoints(screen)
	hardOps:SetFrameLevel(6);
	hardOps:Hide();

	local floatOps = CreateFrame("Button",nil,self);
	floatOps:SetSize(40,40)
	floatOps:SetPoint("TOP",smallerButton,"BOTTOM")
	floatOps:SetNormalTexture("Interface\\Buttons\\UI-SquareButton-Up.tga")
	floatOps:SetPushedTexture("Interface\\Buttons\\UI-SquareButton-Down.tga")
	floatOps:SetDisabledTexture("Interface\\Buttons\\UI-SquareButton-Disabled.tga")
	floatOps:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight.tga")
	do
		floatOps.Icon = floatOps:CreateTexture(nil,"OVERLAY",nil,5)
		floatOps.Icon:SetTexture("Interface\\Buttons\\UI-OptionsButton.tga")
		local opSize = floatOps:GetWidth()*.5;
		floatOps.Icon:SetSize(opSize,opSize)
		floatOps.Icon:SetPoint("CENTER",floatOps,"CENTER")
		floatOps.Icon:Show()
	end
	floatOps:Hide();

	self.Options = floatOps;


	function self:setUp(size)
		self:SetSize(size,(144/160)*size)
	end

	function self:Resolute(width)
		self:setUp(width)
		local textHeight = .05*self.Screen:GetHeight();
		self.screenText:SetFont(_wd().."fonts\\pretendo.ttf",textHeight);
		for i=1,textHeight do self.screenText:SetTextHeight(i); end
	end

	function self:SetSizeDelta(delta)
	  if ((self:GetWidth()+delta) > 220) and ((self:GetWidth()+delta) < 1000) then
		self:Resolute(self:GetWidth()+delta)
	  end
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
	t:SetColorTexture(baseColor.r/255,baseColor.g/255,baseColor.b/255,1);
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
		if (bool == true) then
			self.Options = floatOps;
			self:EnableMouse(true)
			self:RegisterForDrag("LeftButton")
			self:SetMovable(true)
			self:SetClampedToScreen(true)
			self:SetScript("OnDragStart",function(self)
			  self:StartMoving()
			  end)
			self:SetScript("OnDragStop",function(self)
			  self:StopMovingOrSizing()
			end)

			biggerButton:RegisterForClicks("LeftButtonUp")
			biggerButton:SetScript("OnClick",function(btn,button,down)
				self:SetSizeDelta(30);
			end)

			smallerButton:RegisterForClicks("LeftButtonUp")
			smallerButton:SetScript("OnClick",function(btn,button,down)
				self:SetSizeDelta(-30);
			end)

			floatOps:Show();
			hardOps:Hide();


			self:SetScript( "OnEnter", function(frame)
				GameTooltip:SetOwner( frame, "ANCHOR_CURSOR" )
				local text = "Drag to move.";
				GameTooltip:SetText(text);
			end )
			self:SetScript( "OnLeave", GameTooltip_Hide )
		else
			self.Options = hardOps;
			self:EnableMouse(false)
			self:RegisterForDrag(nil)
			self:SetMovable(false)
			self:SetScript("OnDragStart",nil)
			self:SetScript("OnDragStop",nil)
			biggerButton:Hide()
			smallerButton:Hide()

			t:Hide()
			text:Hide()

			floatOps:Hide();
			hardOps:Show();


			self:SetScript( "OnEnter", function(frame)
				GameTooltip:SetOwner( frame, "ANCHOR_CURSOR" )
				local text = "Click for emulator options and to load ROMs.";
				GameTooltip:SetText(text);
			end )
			self:SetScript( "OnLeave", GameTooltip_Hide )
		end
	end
	return self;
end

addon:RegisterSkin("Screen",generate);