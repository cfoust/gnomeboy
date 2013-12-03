local ns = {}
print("GnomeBoyAdvance Alpha loaded")

local function _wd() return "Interface\\AddOns\\GnomeBoyAdvance\\" end

function GB_GET_ROM(string)
	for i,j in pairs(GB_ROMS) do
		if j['name'] == string then
	 return j;
		end
	end
	return nil;
end

function GenerateGB()
	local self = CreateFrame("Frame","GnomeBoy",UIParent)
	do
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
		self:SetFrameLevel(5)
	end

	local function ratioW(num)
		return self:GetWidth()*(num/4000);
	end

	local function ratioH(num)
		return self:GetHeight()*(num/6563);
	end

	function self:setUp(self,size)
		self:SetSize(size,(840/512)*size)
	end
	function self:Resolute()
		self.Screen:SetPoint("TOPLEFT",self,"TOPLEFT",ratioW(969),-1*ratioH(890))
		self.Screen:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",ratioW(3022),-1*ratioH(2765))
	end
	-- function self:SetSizeDelta(delta)
	--   if ((self:GetWidth()+delta) > 220) and ((self:GetWidth()+delta) < 700) then self:Resolute(self:GetWidth()+delta) end
	-- end
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

	self.SCREENGEN = false;
	
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

		buttons.on = makeRatioButton(395,0,1334,371)
		buttons.on:EnableMouse(true)
		buttons.on:RegisterForClicks("LeftButtonUp")
		buttons.on:SetScript("OnClick",function(btn,button,down)
			if (self.SCREENGEN == true) and(self.Emulator.RUNNING ~= nil) then
				self.Emulator.RUNNING = not self.Emulator.RUNNING;
			end
			if (self.SCREENGEN == false) then
				self.initScreen();
				self.initGB();
				self.SCREENGEN = true;

				self:EnableMouse(false)
				self:RegisterForDrag(nil)
				self:SetMovable(false)
				self:SetScript("OnDragStart",nil)
				self:SetScript("OnDragStop",nil)
			end
		end)
		buttons.on:SetScript( "OnEnter", function(frame) 
			GameTooltip:SetOwner( frame, "ANCHOR_CURSOR" )
			local text = "|cFF696969ON/OFF:|r \n";
			if (self.SCREENGEN == false) then
				text = text .. [[|cFFFF0000WARNING:|r Will lag (or freeze) your game pretty badly for a moment.
It generates the screen for the emulator, and unsurprisingly creating
just over 23k pixels takes a lot of power. You will not be able to move
the Gnome Boy after you have generated the screen, so choose its position
taking that into account.]]
			else
				text = text .. "(Un)pauses execution of the emulator so your FPS goes back up.";
			end
			GameTooltip:SetText(text);
		end )
		buttons.on:SetScript( "OnLeave", GameTooltip_Hide )
	end
	
	do
		local px,py = 160,144;
		local pixel;
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
		function self.initScreen()
			local base = self.Screen;
			base.pixels = {}
			for i = 1, py do
				base.pixels[i] = {}
				for j = 1, px do
					base.pixels[i][j] = base:CreateTexture("Texture",nil,base);
					pixel = base.pixels[i][j]
					pixel:SetTexture(baseColor.r/255,baseColor.g/255,baseColor.b/255,1)
					pixel:SetSize((base:GetWidth()/px),(base:GetHeight()/py))
					pixel:SetPoint("TOPLEFT",base,"TOPLEFT",(base:GetWidth()/px)*(j-1),-1*(base:GetHeight()/py)*(i-1));
				end
			end
		end
		
		local cr,cg,cb,ca = 0,0,0,0;
		
		local redRange = baseColor.r - darkColor.r;
		local greenRange = baseColor.g - darkColor.g;
		local blueRange = baseColor.b - darkColor.b;
		function self.setdrawcolor(red,green,blue,alpha)
			cr = (red/255)*redRange + darkColor.r;
			cg = (green/255)*greenRange + darkColor.g;
			cb = (blue/255)*blueRange + darkColor.b;
			cr = cr / 255;
			cg = cg / 255;
			cb = cb / 255;
			ca = 1;
		end
		local xm = 1000;
		local min = 1000;
		function self.drawrect(x,y,width,height)
			if (0 <= x) and (x <= px) and (0 <= y) and (y <= py) then
		 		self.Screen.pixels[y+1][x+1]:SetTexture(cr,cg,cb,ca);
			end
		end
		function self.clearScrn()
			for i = 1, py do
				for j = 1, px do
					self.Screen.pixels[py][px]:SetTexture(baseColor.r,baseColor.g,baseColor.b,1);
				end
			end
		end
	end

	function self.initGB()
		local gem = GBAgem
		self.Emulator = gem.New("Tetris.gb","GBZ80");
		if (self.Emulator) then
			self.Emulator.colorfunc = self.setdrawcolor;
			self.Emulator.drawfunc = self.drawrect;
		end
		local framelimit = 25;
		local sinceLast = 0;
		local time = 1000/framelimit;
		self:SetScript("OnUpdate",function(frame,elapsed)
			if (self.Emulator.RUNNING == true) then
				sinceLast = sinceLast + elapsed*1000;
				if (sinceLast > time) then
					self.Emulator:Think();
					self.Emulator:Draw();
					sinceLast = 0;
				end
			end
		end);
	end

	self:Show()
	
	return self;
end



BINDING_HEADER_GNOMEBOYADVANCE = "Gnome Boy Advance"