local ns = {}
print("GnomeBoyAdvance Alpha loaded")
local base = CreateFrame("Frame","GnomeBoyAdvance");
local px,py = 160,144;
base:SetPoint("CENTER")
base:SetSize(px*2,py*2)
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
for i = 1, 144 do
	base.pixels[i] = {}
	for j = 1, 160 do
		base.pixels[i][j] = base:CreateTexture("Texture",nil,base);
		pixel = base.pixels[i][j]
		pixel:SetTexture(1,0,0,1)
		pixel:SetSize((base:GetWidth()/160),(base:GetHeight()/144))
		pixel:SetPoint("TOPLEFT",base,"TOPLEFT",(base:GetWidth()/160)*(j-1),-1*(base:GetHeight()/144)*(i-1));
	end
end
local cr,cg,cb,ca = 0,0,0,0;
function GBA_surface_SetDrawColor(red,green,blue,alpha)
	cr,cg,cb,ca = red/255, green/255, blue/255, alpha/255;
end
local xm = 1000;
local min = 1000;
function GBA_surface_drawRect(x,y,width,height)
  if (0 <= x) and (x <= 160) and (0 <= y) and (y <= 144) then
    base.pixels[y+1][x+1]:SetTexture(cr,cg,cb,ca)
  end
	
end

BINDING_HEADER_GNOMEBOYADVANCE = "Gnome Boy Advance"