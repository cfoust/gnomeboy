
GB_GAMEBOY_INSTANCE = nil
function UseControl(string,bool)
	if (GB_GAMEBOY_INSTANCE ~= nil) then
		GB_GAMEBOY_INSTANCE.Emulator:KeyChanged(string,bool)
	end
end

function StartGameBoy()
	local self = GB_INITIALIZE()
	-- local self = GenerateGB()
	GB_GAMEBOY_INSTANCE = self;
	local gem = GBAgem
	function GBALoadROM( curfile, filetype )
		self.Emulator = gem.New( curfile, filetype )
	end
	
	
	GBALoadROM("Tetris.gb","GBZ80")
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
