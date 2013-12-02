local ns = {}
print("GnomeBoyAdvance Alpha loaded")

local function _wd() return "Interface\\AddOns\\GnomeBoyAdvance\\" end

local function GenerateTV()
  local self = CreateFrame("Frame","GnomeBoy",UIParent)


  do
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true)
    self:SetClampedToScreen(true)
    self:SetScript("OnDragStart",function(self) self:StartMoving() end)
    self:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
    self:SetFrameLevel(6)
  end



  function self:setUp(self,size)
    self:SetSize(size,(254/302)*size)
  end
  function self:Resolute(size)
    self:setUp(self,size)
    self.plus:SetPoint("TOPLEFT",self,"TOPLEFT",(31/1000)*self:GetWidth(),-1*(144/842)*self:GetHeight())
    self.plus:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",(70/1000)*self:GetWidth(),-1*(183/842)*self:GetHeight())
    self.minus:SetPoint("TOPLEFT",self,"TOPLEFT",(31/1000)*self:GetWidth(),-1*(187/842)*self:GetHeight())
    self.minus:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",(70/1000)*self:GetWidth(),-1*(226/842)*self:GetHeight())
    self.close:SetPoint("TOPLEFT",self,"TOPLEFT",(31/1000)*self:GetWidth(),-1*(588/842)*self:GetHeight())
    self.close:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",(70/1000)*self:GetWidth(),-1*(627/842)*self:GetHeight())
    self.Screen:SetPoint("TOPLEFT",self,"TOPLEFT",math.floor((46/512)*self:GetWidth()),-1*math.floor((46/431)*self:GetHeight()))
    self.Screen:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-1*math.floor((53/512)*self:GetWidth()),math.floor((105/431)*self:GetHeight()))
  end
  function self:SetSizeDelta(delta)
    if ((self:GetWidth()+delta) > 220) and ((self:GetWidth()+delta) < 700) then self:Resolute(self:GetWidth()+delta) end
  end
  self:setUp(self,350)

  self:SetPoint("CENTER",UIParent,"CENTER")
  self:Show()

  self.art = CreateFrame("Frame",nil,self)
  self.art:SetAllPoints(self)
  do
    self.bg = self.art:CreateTexture(nil,"OVERLAY",nil,5)
    self.bg:SetTexture(_wd() .. "Textures\\TV\\tv.tga")
    self.bg:SetTexCoord(0,1,0,431/512)
    self.bg:SetAllPoints(self.art)
    self.bg:Show()
  end
  do--Initializes buttons
    do
      self.plus = CreateFrame("Button",nil,self.art)
      self.plus:SetPoint("TOPLEFT",self,"TOPLEFT",(31/1000)*self:GetWidth(),-1*(144/842)*self:GetHeight())
      self.plus:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",(70/1000)*self:GetWidth(),-1*(183/842)*self:GetHeight())
      self.plus.bg = self.plus:CreateTexture(nil,"OVERLAY",nil,6);
      self.plus.bg:SetAllPoints(self.plus)
      self.plus.bg:SetTexture(_wd() .. "Textures\\TV\\plus.tga")
      self.plus:EnableMouse(true)
      self.plus:RegisterForClicks("LeftButtonUp")
      self.plus:SetScript("OnClick",function(frame,button,down)
        self:SetSizeDelta(30);
      end)
    end
    do
      self.minus = CreateFrame("Button",nil,self.art)
      self.minus:SetPoint("TOPLEFT",self,"TOPLEFT",(31/1000)*self:GetWidth(),-1*(187/842)*self:GetHeight())
      self.minus:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",(70/1000)*self:GetWidth(),-1*(226/842)*self:GetHeight())
      self.minus.bg = self.minus:CreateTexture(nil,"OVERLAY",nil,6);
      self.minus.bg:SetAllPoints(self.minus)
      self.minus.bg:SetTexture(_wd() .. "Textures\\TV\\minus.tga")
      self.minus:EnableMouse(true)
      self.minus:RegisterForClicks("LeftButtonUp")
      self.minus:SetScript("OnClick",function(frame,button,down)
        self:SetSizeDelta(-30);
      end)
    end
    do
      self.close = CreateFrame("Button",nil,self.art)
      self.close:SetPoint("TOPLEFT",self,"TOPLEFT",(31/1000)*self:GetWidth(),-1*(588/842)*self:GetHeight())
      self.close:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",(70/1000)*self:GetWidth(),-1*(627/842)*self:GetHeight())
      self.close.bg = self.close:CreateTexture(nil,"OVERLAY",nil,6);
      self.close.bg:SetAllPoints(self.close)
      self.close.bg:SetTexture(_wd() .. "Textures\\TV\\close.tga")
      self.close:EnableMouse(true)
      self.close:RegisterForClicks("LeftButtonUp")
      self.close:SetScript("OnClick",function(frame,button,down)
        self:Hide()
      end)
    end
  end
  do
    self.art:SetClampedToScreen(true)
  end

  self.Screen = CreateFrame("Frame",nil,self)
  self.Screen:SetFrameLevel(5)
  self.Screen:SetPoint("TOPLEFT",self,"TOPLEFT",math.floor((46/512)*self:GetWidth()),-1*math.floor((46/431)*self:GetHeight()))
  self.Screen:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-1*math.floor((53/512)*self:GetWidth()),math.floor((105/431)*self:GetHeight()))

  return self;
end


-- local base = CreateFrame("Frame","GnomeBoyAdvance");
local base = GenerateTV().Screen;
local px,py = 160,144;
-- base:SetPoint("CENTER")
-- base:SetSize(px*2,py*2)
-- base:SetMovable(); 
-- base:SetScript("OnDragStart", base.StartMoving) 
base:SetBackdrop({
  -- path to the background texture
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
  -- path to the border texture
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
  -- true to repeat the background texture to fill the frame, false to scale it
  tile = true,
  -- size (width or height) of the square repeating background tiles (in pixels)
  tileSize = 32,
  -- thickness of edge segments and square size of edge corners (in pixels)
  edgeSize = 32,
  -- distance from the edges of the frame to those of the background texture (in pixels)
  insets = {
    left = 11,
    right = 12,
    top = 12,
    bottom = 11
  }
})
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
function GBA_surface_SetDrawColor(red,green,blue,alpha)
	cr,cg,cb,ca = red/255, green/255, blue/255, alpha/255;
end
local xm = 1000;
local min = 1000;
function GBA_surface_drawRect(x,y,width,height)
  if (0 <= x) and (x <= px) and (0 <= y) and (y <= py) then
    base.pixels[y+1][x+1]:SetTexture(cr,cg,cb,ca)
  end
	
end

BINDING_HEADER_GNOMEBOYADVANCE = "Gnome Boy Advance"