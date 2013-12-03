
GB_GAMEBOY_INSTANCE = nil
function UseControl(string,bool)
	if (GB_GAMEBOY_INSTANCE ~= nil) then
		GB_GAMEBOY_INSTANCE.Emulator:KeyChanged(string,bool)
	end
end

function StartGameBoy()
	local self = GenerateGB()
	GB_GAMEBOY_INSTANCE = self;
end
