
local gem = GBAgem
local mt = gem.GBZ80

local string_format = string.format

function mt:Restart()
	-- Memory
	self.Memory = {}	-- Main Memory RAM
	self.ROM = {} 		-- Used for external Cart ROM, each bank is offset by 0x4000
	self.RAM = {}		-- Used for external Cart RAM

	self:LoadRom()
	for i = 0, 0x1FFFF do
		self.Memory[i] = 0
		self.RAM[i] = 0
	end

	self.VideoArray = {} -- simple bitmap of the display for mt:draw()

	self.BIOS = { 0xFE, 0xFF, 0xAF, 0x21, 0xFF, 0x9F, 0x32, 0xCB, 0x7C, 0x20, 0xFB, 0x21, 0x26, 0xFF, 0x0E, 0x11, 0x3E, 0x80, 0x32, 0xE2, 0x0C, 0x3E, 0xF3, 0xE2, 0x32, 0x3E, 0x77, 0x77, 0x3E, 0xFC, 0xE0, 0x47, 0x11, 0x04, 0x01, 0x21, 0x10, 0x80, 0x1A, 0xCD, 0x95, 0x00, 0xCD, 0x96, 0x00, 0x13, 0x7B, 0xFE, 0x34, 0x20, 0xF3, 0x11, 0xD8, 0x00, 0x06, 0x08, 0x1A, 0x13, 0x22, 0x23, 0x05, 0x20, 0xF9, 0x3E, 0x19, 0xEA, 0x10, 0x99, 0x21, 0x2F, 0x99, 0x0E, 0x0C, 0x3D, 0x28, 0x08, 0x32, 0x0D, 0x20, 0xF9, 0x2E, 0x0F, 0x18, 0xF3, 0x67, 0x3E, 0x64, 0x57, 0xE0, 0x42, 0x3E, 0x91, 0xE0, 0x40, 0x04, 0x1E, 0x02, 0x0E, 0x0C, 0xF0, 0x44, 0xFE, 0x90, 0x20, 0xFA, 0x0D, 0x20, 0xF7, 0x1D, 0x20, 0xF2, 0x0E, 0x13, 0x24, 0x7C, 0x1E, 0x83, 0xFE, 0x62, 0x28, 0x06, 0x1E, 0xC1, 0xFE, 0x64, 0x20, 0x06, 0x7B, 0xE2, 0x0C, 0x3E, 0x87, 0xE2, 0xF0, 0x42, 0x90, 0xE0, 0x42, 0x15, 0x20, 0xD2, 0x05, 0x20, 0x4F, 0x16, 0x20, 0x18, 0xCB, 0x4F, 0x06, 0x04, 0xC5, 0xCB, 0x11, 0x17, 0xC1, 0xCB, 0x11, 0x17, 0x05, 0x20, 0xF5, 0x22, 0x23, 0x22, 0x23, 0xC9, 0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x08, 0x11, 0x1F, 0x88, 0x89, 0x00, 0x0E, 0xDC, 0xCC, 0x6E, 0xE6, 0xDD, 0xDD, 0xD9, 0x99, 0xBB, 0xBB, 0x67, 0x63, 0x6E, 0x0E, 0xEC, 0xCC, 0xDD, 0xDC, 0x99, 0x9F, 0xBB, 0xB9, 0x33, 0x3E, 0x3C, 0x42, 0xB9, 0xA5, 0xB9, 0xA5, 0x42, 0x3C, 0x21, 0x04, 0x01, 0x11, 0xA8, 0x00, 0x1A, 0x13, 0xBE, 0x20, 0xFE, 0x23, 0x7D, 0xFE, 0x34, 0x20, 0xF5, 0x06, 0x19, 0x78, 0x86, 0x23, 0x05, 0x20, 0xFB, 0x86, 0x20, 0xFE, 0x3E, 0x01, 0xE0, 0x50 }
	self.BIOS[0] = 0x31		-- Used on startup, loads at 0x0 and is promptly turned off when PC hits 100


	
	-- Memory & Cart Flags
	self.EnableBios = true 	-- Enables the Bios, disabled after the bios is used
	self.CartMBCMode = 3	-- 0 for ROM mode, 1 for MBC1, 2 for MBC2, 3 for MBC3
	self.RomBank = 1 		-- The current ROM bank stored in 0x4000 to 0x7FFF
	self.RamBank = 0		-- The current RAM bank
	
	-- Registers
	self.A = 0
	self.B = 0
	self.C = 0	
	self.D = 0
	self.E = 0
	self.H = 0
	self.L = 0x20

	self.PC = 0x0
	self.SP = 0x0
	
	-- Internal Flags
	self.Cf = false -- Carry
	self.Hf = false -- Half Carry
	self.Zf = false -- Zero 
	self.Nf = false -- Subtract
	
	-- Virtual Flags
	self.IME = true		-- Interupt Master Enable
	self.Halt = false 		-- is halt engaged (do nothing until an interupt)



	-- Interupt Hardware Registers
	self.IE = 0 -- Interupt Enable Register: Bit0 = VBlank, Bit1 = LCD, Bit2 = Timer, Bit4 = Joypad
	self.IF = 0 -- Interupt Request Register
	
	


	--------------------------------
	-- LCD/GPU Hardware Registers --
	--------------------------------

	self.ScanCycle = 0	-- The number of cycles executed so far, resets at end of hblank.

	-- LCD Control Register
	self.LCDEnable = true -- Disables and enables the LCD
	self.WindowMap = 0x98000 -- Pointer to the Map used by the Window Tile map. 0 = 0x9800, 1 = 0x9C00
	self.WindowEnable = true -- Enables and Disables drawing of the window
	self.TileData = 0x8800 -- Pointer to the tiledata used by both window and bg. 0 = 0x8800, 1 =0x8000
	self.BGMap = 0x9800 -- Pointer to the Map used by the BG. 0 = 0x9800, 1 = 0x9C00
	self.SpriteSize = 8 -- Sprite Vertical size. 0 = 8, 1 = 16
	self.SpriteEnable = true -- Enables/Disables drawing of sprites
	self.BGEnable = true -- Enabled/Disables the drawing of the BG

	-- LCD Status Register
	self.CoincidenceInterupt = false
	self.ModeTwoInterupt = false
	self.ModeOneInterupt = false
	self.ModeZeroInterupt = false

	self.CoincidenceFlag = 0
	self.Mode = 0

	-- Scroll Registers
	self.ScrollX = 0
	self.ScrollY = 0
	self.WindowX = 0
	self.WindowY = 0

	-- Current scanline Y coordinate register
	self.ScanlineY = 1

	-- Value to compare with ScanLineY for Coincidence (Nothing special, just a value you can R/W to)
	self.CompareY = 0

	-- Palettes
	

	------------------------------
	-- Timer Hardware Registers --
	------------------------------
	
	-- Timer
	self.TimerEnabled = false 	-- Is the timer enabled?
	self.TimerCounter = 1024  	-- The number of cycles per timer incriment
	self.TimerCycles   = 0		-- The cycle counter for timers, resets every timer incriment.
	self.TimerDB = {16, 64, 256}; self.TimerDB[0] = 1024 -- Cheaper than an elseif stack
	self.TimerBase = 0 			-- The timer base, when timer overflows it resets itself to this.
	self.Timer = 0			-- The timer itself
	
	-- Divider Timer (Incriments every 256 cycles, no interupt)
	self.DividerCycles = 0 		-- The cycle counter for the Didiver, resets every timer incriment
	self.Divider = 0			-- Easier to store it in a variable than in memory. 

	-- Cycles and other timing
	self.TotalCycles = 0
	self.Cycle = 0

	-- 
	self.DPadByte = 0xF
	self.ButtonByte = 0xF

	self.SelectButtonKeys = true
	self.SelectDirectionKeys = false


	--Drawing Method stuff
	self.ColourDB = {150, 50, 0}; self.ColourDB[0] = 255 -- Basic palette
	self.interleve = 0x300
	self.FrameSkip = 5

	self.Pixels = {} -- Stores the pixels drawn last frame, this way we only redraw what we need to. 

	for n = 0, 23040 do
		self.Pixels[n] = 1
	end

	-- Debugging
	self.LastOpcode = 0
	self.TotalIterations = 0
	self.oldPC = 0
	self.NextPC = 0
	self.Iter = 0
	print("GB done loading")
end

----------------------------------------------------------------------
-- Name: Initialize
-- Desc: Called when the instance is created
----------------------------------------------------------------------
function mt:Initialize()
	self:Restart()
end

function mt:KeyChanged( key, bool )
	if key == "Start" then self.ButtonByte = (bool and bit.band(self.ButtonByte,(15 - 8)) or bit.bor(self.ButtonByte,8) ) end
	if key == "Select" then self.ButtonByte = (bool and bit.band(self.ButtonByte,(15 - 4)) or bit.bor(self.ButtonByte,4) ) end
	if key == "B" then self.ButtonByte = (bool and bit.band(self.ButtonByte,(15 - 2)) or bit.bor(self.ButtonByte,2) ) end
	if key == "A" then self.ButtonByte = (bool and bit.band(self.ButtonByte,(15 - 1)) or bit.bor(self.ButtonByte,1) ) end

	if key == "Down" then self.DPadByte = (bool and bit.band(self.DPadByte,(15 - 8)) or bit.bor(self.DPadByte,8) ) end
	if key == "Up" then self.DPadByte = (bool and bit.band(self.DPadByte,(15 - 4)) or bit.bor(self.DPadByte,4) ) end
	if key == "Left" then self.DPadByte = (bool and bit.band(self.DPadByte,(15 - 2)) or bit.bor(self.DPadByte,2) ) end
	if key == "Right" then self.DPadByte = (bool and bit.band(self.DPadByte,(15 - 1)) or bit.bor(self.DPadByte,1) ) end
end
function mt:Think()
	self.TotalCycles = 0

	while self.TotalCycles < 70224*2 do
		self:Step()
	end
end

function mt:NextLine()
	self.NextPC = self.PC + 1
	self:DisableDebugging()
end
----------------
--Step function excutes a single operation at a time. 
----------------
function mt:Step()
	if not self.Halt then
		local TotalCycle = 0
		while TotalCycle < 200 do
			self.Operators[self:Read(self.PC)]( self )
			TotalCycle = TotalCycle + self.Cycle
		end
		self.Cycle = TotalCycle
	else
		self.Cycle = 200
	end

	local Cycle = self.Cycle
	--Incriment all the counters based on cycles.
	self.TotalCycles = self.TotalCycles + Cycle


	--Manage the timers

	-- Divider, consider changing this to subtract 256 from Divider Cycles rather than setting to 0, test this as it might boost compatability.
	self.DividerCycles = self.DividerCycles + Cycle
	while self.DividerCycles > 255 do
		self.Divider = bit.band((self.Divider + 1),0xFF)
		self.DividerCycles = self.DividerCycles - 256
	end


	if self.TimerEnabled then -- if the timer is enabled
		self.TimerCycles = self.TimerCycles + Cycle -- incriment the cycles until next timer inc
		while self.TimerCycles > self.TimerCounter do -- if they overflow, then reset the timer cycles and incriment the timer
			self.Timer = self.Timer +1
			self.TimerCycles = self.TimerCycles - self.TimerCounter
			if self.Timer > 255 then -- if the timer overflows, reset the timer and do the timer interupt. 
				self.Timer = self.TimerBase
				self.IF = bit.bor(self.IF,4)
			end
		end
	end
	--Scanline management, might need to insert drawing code in here eventually for proper GPU emulation :o
	if self.LCDEnable then

		local ScanCycle = self.ScanCycle
		local ScanlineY = self.ScanlineY
		local Mode = self.Mode

		ScanCycle = ScanCycle + Cycle

		if ScanCycle > 456 then
			ScanCycle = ScanCycle - 456
			ScanlineY = ScanlineY + 1
		end

		if ScanlineY > 153 then
			ScanlineY = 0
		end

		if ScanlineY >= 145 and ScanlineY <= 153 then

			if Mode ~= 1 and self.ModeOneInterupt then self.IF = bit.bor(self.IF,2) end -- request LCD interupt for entering Mode 1
			if Mode ~= 1 and ScanlineY == 145 then self.IF = bit.bor(self.IF,1) end -- Reques VBlank
			Mode = 1

		elseif ScanlineY >= 0 and ScanlineY <= 144 then -- not vblank

			if ScanCycle >= 1 and ScanCycle <= 80 then
				if Mode ~= 2 and self.ModeTwoInterupt then self.IF = bit.bor(self.IF,2) end -- request LCD interupt for entering Mode 2
				Mode = 2
			elseif ScanCycle >= 81 and ScanCycle <= 252 then
				Mode = 3
			elseif ScanCycle >= 253 and ScanCycle <= 456 then
				if Mode ~= 0 and self.ModeZeroInterupt then self.IF = bit.bor(self.IF,2) end -- request LCD interupt for entering Mode 0
				Mode = 0
			end

		end

		self.ScanlineY = ScanlineY
		self.ScanCycle = ScanCycle
		self.Mode = Mode
	else
		self.ScanlineY = 0
		self.ScanCycle = 0
		self.Mode = 0
	end


	if ScanlineY == self.CompareY and self.CoincidenceInterupt then
		self.IF = bit.bor(self.IF,2) -- request LCD interrupt
	end
	if self.IME and self.IE > 0 and self.IF > 0 then
		if (bit.band(self.IE,1) == 1) and (bit.band(self.IF,1) == 1) then --VBlank interrupt
			--self:EnableDebugging()
			self.IME = false
			self.Halt = false

			self.IF = bit.band(self.IF,(255 - 1))

			self.SP = self.SP - 2
			self:Write(self.SP + 1, bit.rshift((bit.band((self.PC),0xFF00)),8))
			self:Write(self.SP    , bit.band((self.PC),0xFF       ))

			self.PC = 0x40
		elseif (bit.band(self.IE,2) == 2) and (bit.band(self.IF,2) == 2) then -- LCD Interrupt
			self.IME = false
			self.Halt = false

			self.IF = bit.band(self.IF,(255 - 2))

			self.SP = self.SP - 2
			self:Write(self.SP + 1, bit.rshift((bit.band((self.PC),0xFF00)),8))
			self:Write(self.SP    , bit.band((self.PC),0xFF       ))

			self.PC = 0x48
		elseif (bit.band(self.IE,4) == 4) and (bit.band(self.IF,4) == 4) then -- TImer Interrupt

			self.IME = false
			self.Halt = false

			self.IF = bit.band(self.IF,(255 - 4))

			self.SP = self.SP - 2
			self:Write(self.SP + 1, bit.rshift((bit.band((self.PC),0xFF00)),8))
			self:Write(self.SP    , bit.band((self.PC),0xFF       ))

			self.PC = 0x50
		elseif (bit.band(self.IE,8) == 8) and (bit.band(self.IF,8) == 8) then -- Serial Interrupt

			self.IME = false
			self.Halt = false

			self.IF = bit.band(self.IF,(255 - 8))

			self.SP = self.SP - 2
			self:Write(self.SP + 1, bit.rshift((bit.band((self.PC),0xFF00)),8))
			self:Write(self.SP    , bit.band((self.PC),0xFF       ))

			self.PC = 0x58
		elseif (bit.band(self.IE,16) == 16) and (bit.band(self.IF,16) == 16) then -- Joy Interrupt

			self.IME = false
			self.Halt = false

			self.IF = bit.band(self.IF,(255 - 16))

			self.SP = self.SP - 2
			self:Write(self.SP + 1, bit.rshift((bit.band((self.PC),0xFF00)),8))
			self:Write(self.SP    , bit.band((self.PC),0xFF       ))

			self.PC = 0x60
		end
	end
end

local string_byte = string.byte
local string_sub = string.sub

function mt:LoadRom()
	local x = 0
	print("Length: ", #self.ROMstring)
	for i=1,#self.ROMstring,2 do
		self.ROM[x] = tonumber( self.ROMstring:sub(i,i+1), 16 )
		x = x + 1
	end
end