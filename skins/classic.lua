local addonName, addon = ...

-- Convenience functions
local function print(...) _G.print("|cff708090GnomeBoy:|r", ...) end
local function _wd() return "Interface\\AddOns\\GnomeBoy\\" end


local function generate()
	local self = CreateFrame("Frame",nil,UIParent)

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
		-- 19/32x19/32

		
		smallerButton:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up.tga");
		smallerButton:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down.tga")
		smallerButton:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled.tga")
		smallerButton:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight.tga")
	end
	
	

	self:SetFrameLevel(5)

	local function ratioW(num)
		return self:GetWidth()*(num/4000);
	end

	local function ratioH(num)
		return self:GetHeight()*(num/6563);
	end

	function self:setUp(self,size)
		self:SetSize(size,(840/512)*size)
	end
	local function resoluteRatioBtn(button,x1,y1,x2,y2)
		button:SetPoint("TOPLEFT",self,"TOPLEFT",ratioW(x1),-1*ratioH(y1))
		button:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",ratioW(x2),-1*ratioH(y2))
	end
	function self:Resolute(width)
		self:setUp(self,width)
		self.Screen:SetPoint("TOPLEFT",self,"TOPLEFT",ratioW(969),-1*ratioH(890))
		self.Screen:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",ratioW(3022),-1*ratioH(2765))
		resoluteRatioBtn(self.buttons.a,3146,3955,3693,4509)
		resoluteRatioBtn(self.buttons.b,2501,4233,3032,4829)
		resoluteRatioBtn(self.buttons.start,1868,5195,2351,5546)
		resoluteRatioBtn(self.buttons.select,1217,5209,1687,5544)
		resoluteRatioBtn(self.buttons.up,636,3911,1025,4205)
		resoluteRatioBtn(self.buttons.left,330,4229,613,4615)
		resoluteRatioBtn(self.buttons.right,1040,4234,1326,4615)
		resoluteRatioBtn(self.buttons.down,644,4647,1024,4920)
		resoluteRatioBtn(self.Options,152,6034,465,6347)
		local opSize = self.Options:GetWidth()*.5;
		self.Options.Icon:SetSize(opSize,opSize)
	end
	function self:SetSizeDelta(delta)
	  if ((self:GetWidth()+delta) > 220) and ((self:GetWidth()+delta) < 500) then self:Resolute(self:GetWidth()+delta) end
	end
	self:setUp(self,400)

	do
		self.art = CreateFrame("Frame",nil,self)
		self.art:SetAllPoints(self)
		local art = self.art;
		do
			self.bg = self.art:CreateTexture(nil,"OVERLAY",nil,5)
			self.bg:SetTexture(_wd() .. "textures\\gb.tga")
			self.bg:SetTexCoord(0,1,0,840/1024)
			self.bg:SetAllPoints(self.art)
			self.bg:Show()
		end
	end

	self:SetPoint("CENTER",UIParent,"CENTER")
	
	do
		self.Screen = CreateFrame("Frame",nil,self)
		self.Screen:SetFrameLevel(7)
		self.Screen:SetPoint("TOPLEFT",self,"TOPLEFT",ratioW(969),-1*ratioH(890))
		self.Screen:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",ratioW(3022),-1*ratioH(2765))
	end

	do
		self.buttons = CreateFrame("Frame",nil,self);
		self.buttons:SetAllPoints(self);
		local buttons = self.buttons;

		local function makeRatioButton(x1,y1,x2,y2)
			 local button = CreateFrame("Button",nil,buttons)
			 button:SetPoint("TOPLEFT",self,"TOPLEFT",ratioW(x1),-1*ratioH(y1))
			 button:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",ratioW(x2),-1*ratioH(y2))
			 return button;
		end

		local function makeEmuButton(button,key)
			button:EnableMouse(true)
			button:RegisterForClicks("LeftButtonUp","LeftButtonDown")
			button:SetScript("OnClick",function(btn,button,down)
				if (self.Emulator) then
					self.Emulator:KeyChanged(key,down);
				end
			end)
			button:SetScript("OnLeave",function(btn,motion)
				if (self.Emulator) then
					self.Emulator:KeyChanged(key,false);
				end
			end)
		end

		local function makeEmu(x1,y1,x2,y2,key)
			local button = makeRatioButton(x1,y1,x2,y2);
			makeEmuButton(button,key);
			return button;
		end

		buttons.a = makeEmu(3146,3955,3693,4509,"A")
		buttons.b = makeEmu(2501,4233,3032,4829,"B")
		buttons.start = makeEmu(1868,5195,2351,5546,"Start")
		buttons.select = makeEmu(1217,5209,1687,5544,"Select")
		buttons.up = makeEmu(636,3911,1025,4205,"Up")
		buttons.left = makeEmu(330,4229,613,4615,"Left")
		buttons.right = makeEmu(1040,4234,1326,4615,"Right")
		buttons.down = makeEmu(644,4647,1024,4920,"Down")

		self.Options = CreateFrame("Button",nil,buttons);
		self.Options:SetPoint("TOPLEFT",self,"TOPLEFT",ratioW(152),-1*ratioH(6034))
		self.Options:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",ratioW(465),-1*ratioH(6347))
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
	end
	function self:SetChangeable(bool)
		if bool == true then
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

			self:SetScript( "OnEnter", function(frame) 
				GameTooltip:SetOwner( frame, "ANCHOR_CURSOR" )
				local text = "Drag to move.";
				GameTooltip:SetText(text);
			end )
			self:SetScript( "OnLeave", GameTooltip_Hide )
		else
			self:EnableMouse(false)
			self:RegisterForDrag(nil)
			self:SetMovable(false)
			self:SetScript("OnDragStart",nil)
			self:SetScript("OnDragStop",nil)
			biggerButton:Hide()
			smallerButton:Hide()

			self:SetScript( "OnEnter",nil)
			self:SetScript( "OnLeave", nil)
		end
	end
	return self;
end

addon:RegisterSkin("Classic",generate);