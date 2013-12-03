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

local function GenerateGB()
  local self = CreateFrame("Frame","GnomeBoy",UIParent)
  do
    -- self:EnableMouse(true)
    -- self:RegisterForDrag("LeftButton")
    -- self:SetMovable(true)
    -- self:SetClampedToScreen(true)
    -- self:SetScript("OnDragStart",function(self)
    --   if (self.RUNNING ~= nil) then
    --     if (self.RUNNING == true) then
    --       self.RUNNING = false;
    --     end
    --   end
    --   self:StartMoving() 
    --   end)
    -- self:SetScript("OnDragStop",function(self)
    --   if (self.RUNNING ~= nil) then
    --     if (self.RUNNING == false) then
    --       self.RUNNING = true;
    --     end
    --   end
    --   self:StopMovingOrSizing() 
    -- end)
    self:SetFrameLevel(5)
  end

  local function ratioW(ratio)
    return self:GetWidth()*ratio;
  end

  local function ratioH(ratio)
    return self:GetHeight()*ratio;
  end

  function self:setUp(self,size)
    self:SetSize(size,(840/512)*size)
  end
  function self:Resolute()
    self.Screen:SetPoint("TOPLEFT",self,"TOPLEFT",ratioW(969/4000),-1*ratioH(890/6563))
    self.Screen:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",ratioW(3022/4000),-1*ratioH(2765/6563))
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
  self:Show()

  self.Screen = CreateFrame("Frame",nil,self)
  self.Screen:SetFrameLevel(7)
  self.Screen:SetPoint("TOPLEFT",self,"TOPLEFT",ratioW(969/4000),-1*ratioH(890/6563))
  self.Screen:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",ratioW(3022/4000),-1*ratioH(2765/6563))

  return self;
end


-- local base = CreateFrame("Frame","GnomeBoyAdvance");
local base = GenerateGB().Screen;
local px,py = 160,144;
base.pixels = {}
local pixel;
for i = 1, py do
	base.pixels[i] = {}
	for j = 1, px do
		base.pixels[i][j] = base:CreateTexture("Texture",nil,base);
		pixel = base.pixels[i][j]
		pixel:SetTexture(0,0,0,1)
		pixel:SetSize((base:GetWidth()/px),(base:GetHeight()/py))
		pixel:SetPoint("TOPLEFT",base,"TOPLEFT",(base:GetWidth()/px)*(j-1),-1*(base:GetHeight()/py)*(i-1));
	end
end
local cr,cg,cb,ca = 0,0,0,0;
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
local redRange = baseColor.r - darkColor.r;
local greenRange = baseColor.g - darkColor.g;
local blueRange = baseColor.b - darkColor.b;
function GBA_surface_SetDrawColor(red,green,blue,alpha)
  cr = (red/255)*redRange + darkColor.r;
  cg = (green/255)*greenRange + darkColor.g;
  cb = (blue/255)*blueRange + darkColor.b;
  cr = cr / 255;
  cg = cg / 255;
  cb = cb / 255;
	ca = alpha/255;
end
local xm = 1000;
local min = 1000;
function GBA_surface_drawRect(x,y,width,height)
  if (0 <= x) and (x <= px) and (0 <= y) and (y <= py) then
    base.pixels[y+1][x+1]:SetTexture(cr,cg,cb,ca);
  end
end

BINDING_HEADER_GNOMEBOYADVANCE = "Gnome Boy Advance"