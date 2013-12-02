local self = GnomeBoy
local gem = GBAgem
function GBALoadROM( curfile, filetype )
	self.Emulator = gem.New( curfile, filetype )
	
end

function UseControl(string,bool)
	self.Emulator:KeyChanged(string,bool)
end

GB_RUNNING = true
function StartGameBoy()
	GBALoadROM("Tetris.gb","GBZ80")
	local framelimit = 25;
	local sinceLast = 0;
	local time = 1000/framelimit;
	self:SetScript("OnUpdate",function(self,elapsed)
		if (GB_RUNNING) then
			sinceLast = sinceLast + elapsed*1000;
			if (sinceLast > time) then
				self.Emulator:Think();
				self.Emulator:Draw();
				sinceLast = 0;
			end
		end
		
	end);
end
