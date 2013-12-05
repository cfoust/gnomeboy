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
end

function addon:ShowEmulator()
	skins[addon:GetActiveSkin()].Frame:Show();
end

function addon:HideEmulator()
	skins[addon:GetActiveSkin()].Frame:Hide();
end