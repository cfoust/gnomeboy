local addonName, addon = ...

-- Convenience functions
local function print(...) _G.print("|cff708090GnomeBoy:|r", ...) end
local function _wd() return "Interface\\AddOns\\GnomeBoy\\" end

if not addon.skin then addon.skin = {} end

local skins = {};

-- Each skin func must return a frame
-- which has the following:
--		an Options attribute which is a Button that will be used to display emu ops
--		a Screen attribute which is a Frame we can turn into the screen
--		a SetChangeable method which we can call to allow the user to move the skin around and such
--			(SetChangeable should take 1 argument which will be a boolean, true or false)

-- Some notes:
-- 		the frame will get a reference to the Emulator, injected into the frame.Emulator attribute
--			(so that you can make clickable controls and suchlike)

function addon:RegisterSkin(name,skinFunc)
	skins[name] = {
		["Generate"] = skinFunc,
		["generated"] = false
	};
end

function addon:GetFirstSkin()
	for i,j in pairs(skins) do
		return i;
	end
end

function addon:GetActiveSkin()
	return addon.skin.activeName;
end

local function setOptionsChangeable(frame)
	local ops = frame.Options;
	ops:EnableMouse(true);
	ops:RegisterForClicks("LeftButtonUp")
	ops:SetScript("OnClick",function(btn,button,down)
		if not ops.dropdown then
			ops.dropdown = CreateFrame("Frame",nil);
			ops.dropdown.displayMode = "MENU";
		end
		local dropdown = ops.dropdown;
		UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
			if (level == 1) then
				local info = UIDropDownMenu_CreateInfo();
				info.text = "Change Skin"
				info.menuList = "Change Skin";
				info.hasArrow = true;
				info.notCheckable = true;
				UIDropDownMenu_AddButton(info,level)

				info.text = "Lock Skin and Load Emulator";
				info.hasArrow = false;
				info.func = function()
					addon:LoadEmulator();
				end
				info.tooltipTitle = "Loads the Emulator"
				info.tooltipText = [[|cFFFF0000WARNING:|r Will lag (or freeze) your game pretty badly for a moment.
It generates the screen for the emulator, and unsurprisingly creating
just over 23k pixels takes a lot of power. You will not be able to move
the Gnome Boy after you have generated the screen, so choose its position
taking that into account. You will still be able to show/hide it.]]
				info.tooltipOnButton = true;
				UIDropDownMenu_AddButton(info,level)
			elseif (level == 2) then
				if UIDROPDOWNMENU_MENU_VALUE == "Change Skin" then
					local info = UIDropDownMenu_CreateInfo();
					info.notCheckable = true;
					for i,j in pairs(skins) do
						if i == addon:GetActiveSkin() then
							info.text = "|cffa9a9a9"..i.."|r";
							info.func = nil;
							info.disabled = true;
						else
							info.text = i;
							info.func = function()
								ToggleDropDownMenu(1, nil, dropdown, ops, 0, 0)
								addon:SetActiveSkin(i);
							end
							info.disabled = false;
						end
						UIDropDownMenu_AddButton(info,level);
					end
					
				end
			end
		end);
		ToggleDropDownMenu(1, nil, dropdown, ops, 0, 0)
	end)
end

local function setOptionsNormal(frame)
	local ops = frame.Options;
	ops:EnableMouse(true);
	ops:RegisterForClicks("LeftButtonUp")
	ops:SetScript("OnClick",function(btn,button,down)
		if not ops.dropdown then
			ops.dropdown = CreateFrame("Frame",nil);
			ops.dropdown.displayMode = "MENU";
		end
		local dropdown = ops.dropdown;
		UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
			if (level == 1) then
				local info = UIDropDownMenu_CreateInfo();
				info.text = "Load ROM"
				info.menuList = "Load ROM";
				info.hasArrow = true;
				info.notCheckable = true;
				UIDropDownMenu_AddButton(info,level)

				if (addon.Running == true) then
					info.text = "Freeze the Emulator";
				else
					info.text = "Unfreeze the Emulator";
				end
				info.hasArrow = false;
				info.func = function()
					addon.Running = not addon.Running;
				end
				UIDropDownMenu_AddButton(info,level)
			elseif (level == 2) then
				if UIDROPDOWNMENU_MENU_VALUE == "Load ROM" then
					local info = UIDropDownMenu_CreateInfo();
					info.notCheckable = true;
					for i,j in pairs(GB_ROMS) do
						info.text = j['name'];
						info.func = function()
							ToggleDropDownMenu(1, nil, dropdown, ops, 0, 0)
							addon:LoadRom(j['name']);
						end
						info.disabled = false;
						UIDropDownMenu_AddButton(info,level);
					end
					
				end
			end
		end);
		ToggleDropDownMenu(1, nil, dropdown, ops, 0, 0)
	end)
end

function addon:SetActiveSkin(name)
	if not addon.changeable then return end
	if not skins[name] then return end

	if skins[addon:GetActiveSkin()] then
		skins[addon:GetActiveSkin()].Frame:Hide();
	end

	if not skins[name].generated then
		skins[name].Frame = skins[name].Generate();
		skins[name].generated = true;
		skins[name].Frame.Emulator = addon.Emulator;
	end

	skins[name].Frame:SetChangeable(true);
	setOptionsChangeable(skins[name].Frame);
	skins[name].Frame:Show();

	addon.skin.activeName = name;
end



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

function addon:LockSkin()
	local currentSkin = skins[addon:GetActiveSkin()];
	if not currentSkin.Frame.Screen then return end
	local screen = currentSkin.Frame.Screen;

	addon.changeable = false;

	currentSkin.Frame:SetChangeable(false);
	setOptionsNormal(currentSkin.Frame);

	screen.pixels = {}
	for i = 1, py do
		screen.pixels[i] = {}
		for j = 1, px do
			screen.pixels[i][j] = screen:CreateTexture("Texture",nil,screen);
			pixel = screen.pixels[i][j]
			pixel:SetTexture(baseColor.r/255,baseColor.g/255,baseColor.b/255,1)
			pixel:SetSize((screen:GetWidth()/px),(screen:GetHeight()/py))
			pixel:SetPoint("TOPLEFT",screen,"TOPLEFT",(screen:GetWidth()/px)*(j-1),-1*(screen:GetHeight()/py)*(i-1));
		end
	end

	local cr,cg,cb,ca = 0,0,0,0;
	local redRange = baseColor.r - darkColor.r;
	local greenRange = baseColor.g - darkColor.g;
	local blueRange = baseColor.b - darkColor.b;
	local function setdrawcolor(red,green,blue,alpha)
		cr = (red/255)*redRange + darkColor.r;
		cg = (green/255)*greenRange + darkColor.g;
		cb = (blue/255)*blueRange + darkColor.b;
		cr = cr / 255;
		cg = cg / 255;
		cb = cb / 255;
		ca = 1;
	end
	local function drawrect(x,y,width,height)
		if (0 <= x) and (x <= px) and (0 <= y) and (y <= py) then
	 		screen.pixels[y+1][x+1]:SetTexture(cr,cg,cb,ca);
		end
	end
	addon.Emulator.colorfunc = setdrawcolor;
	addon.Emulator.drawfunc = drawrect;
	addon.Running = false;
end

local hidden = true;

function addon:Visible()
	return hidden;
end

function addon:ShowEmulator()
	addon.Running = true;
	hidden = false;
	skins[addon:GetActiveSkin()].Frame:Show();
end

function addon:HideEmulator()
	addon.Running = false;
	hidden = true;
	skins[addon:GetActiveSkin()].Frame:Hide();
end