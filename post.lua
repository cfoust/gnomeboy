local self = GnomeBoyAdvance
local gem = GBAgem
function GBALoadROM( curfile, filetype )
	self.Emulator = gem.New( curfile, filetype )
	
end

function UseControl(string,bool)
	self.Emulator:KeyChanged(string,bool)
end
function StartGameBoy()
	GBALoadROM(MegaRom,"GBZ80")
	local framelimit = 40;
	local sinceLast = 0;
	local time = 1000/framelimit;
	self:SetScript("OnUpdate",function(self,elapsed)
		sinceLast = sinceLast + elapsed*1000;
		if (sinceLast > time) then
			self.Emulator:Think();
			self.Emulator:Draw();
			sinceLast = 0;
		end
	end);
end
