local mt = gem["8080"]

local string_byte = string.byte
local string_sub = string.sub

----------------------------------------------------------------------
-- Name: Restart
-- Desc: Sets/Resets all registers
----------------------------------------------------------------------
function mt:Restart()
	-- Memory & Ports
	self.Memory = {}
	for N = 0, 0xFFFF do self.Memory[N] = 0 end
	self:LoadRom()
	self.InPort = {}
	self.OutPort = {0,0,0,0,0}
	
	-- Debug Inputs
	self.InPort[1] = 0x00
	self.InPort[2] = 11
		
	-- Registers
	self.SP = 0xF000 -- 16Bit Stack Pointer
	self.PC = 0x0000 -- 16Bit Program Counter
	
	self.Shift = 0x0 -- Shift Register
	self.Offset = 0x0 -- Shift Register offset
	
	self.A = 0x00	-- 8Bit Accumulator
	--self.F = 0x00	-- Flags Register (Largely unused) Redundant due to function self:F
	self.B = 0x00	-- 8Bit General Purpose Register
	self.C = 0x00	-- 8Bit General Purpose Register
	self.D = 0x00	-- 8Bit General Purpose Register
	self.E = 0x00	-- 8Bit General Purpose Register
	
	self.H = 0x00	-- 8Bit General Purpose Register (often used as HL pair)
	self.L = 0x00	-- 8Bit General Purpose Register (often used as HL pair)
	
	self.Sf = 0		 -- Sign Flag. Set if bit 7 = 1
	self.Zf	= 0		 -- Zero Flag. Set if result = 0
	self.Hf	= 0		 -- Half Carry Flag. Set if overflow into hi 4 bits from lo 4 bits (Unused?)
	self.Pf	= 0		 -- Parity Flag. Set if value is odd.
	self.Cf	= 0		 -- Carry Flag. Set if overflow into bit 8.
	
	self.IE	= 0		 -- Interupt Enable
	
	--self.Cycles = 0
	--self.Execs = 0
	self.NextReset = 0x10
	
	self.UFOSound = CreateSound( self.entity, "gem_emulator/ufo.wav" )
	self.PlayingUFOSound = false
	
	self.FrameSkip = true
end

----------------------------------------------------------------------
-- Name: Initialize
-- Desc: Called when the instance is created
----------------------------------------------------------------------
function mt:Initialize()
	self:Restart()
end

----------------------------------------------------------------------
-- Name: Draw
-- Desc: Called in the entity's Draw hook
----------------------------------------------------------------------
local surface_DrawRect = surface.DrawRect
local surface_DrawText = surface.DrawText
local surface_SetTextPos = surface.SetTextPos
local surface_SetFont = surface.SetFont
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetTextColor = surface.SetTextColor
function mt:Draw()
	self.FrameSkip = not self.FrameSkip
	
	if self.FrameSkip then return end

	self:ClearRT()
	
	self:StartRenderTarget()
	
	surface_SetDrawColor( 255,255,255,255 )

	local pos = 0
	for i = 0x2400, 0x3FFF do
		local byte = self.Memory[i]
		for j = 0, 7 do	
			pos = pos + 1
			local bit = 1 << j
			if (bit & byte) ~= 0 then	
				local y = pos/256
				local x = pos % 256
				--surface_SetDrawColor( x,0,-x+255,255 )
				surface_DrawRect( y*2+30,-x*2+512, 2, 2 ) 
			end 
		end
	end
	
	self:EndRenderTarget()
	
	--[[
	if self:IsDebugging() then
		local x, y = 270, 0 -- Offset (Outside the screen, in midair)
		
		-- Background
		surface_SetDrawColor( 0,0,0, 255 )
		surface_DrawRect( x, y, 256, 256 )

		-- Title
		surface_SetFont( "Trebuchet18" )
		surface_SetTextColor( 255, 255, 255, 255 )
		
		-- Registers
		local toDraw = { { "AF", self:AF() }, { "BC", self:BC() }, { "DE", self:DE() }, { "HL", self:HL() }, { "PC", self.PC }, { "SP", self.SP }, { "Cycles", self.Cycles, true } }
		
		for i=1,#toDraw do
			local name, value, notHex = toDraw[i][1], toDraw[i][2], toDraw[i][3]
			surface_SetTextPos( x + 10, y + i * 20 )
			if notHex then
				surface_DrawText( name .. ": " .. value )
			else
				surface_DrawText( name .. ": " .. string_format( "%04X", value ) )
			end
		end

		surface_SetTextPos( x + 80, y + 20 )
		surface_DrawText( "OP: " .. string_format( "%s (%04X)", self.Mnemonic[self.Memory[self.PC] ], self.Memory[self.PC] ) )
		surface_SetTextPos( x + 140, y + 100 )
		surface_DrawText("IE: " .. string_format( "%04X", self.IE ) )
		surface_SetTextPos( x + 140, y + 120 )
		surface_DrawText("Z: " .. string_format( "%04X", self.Zf ) )
		surface_SetTextPos( x + 140, y + 140 )
		surface_DrawText("S: " .. string_format( "%04X", self.Sf ) )
		surface_SetTextPos( x + 140, y + 160 )
		surface_DrawText("C: " .. string_format( "%04X", self.Cf ) )
	end
	]]
end

----------------------------------------------------------------------
-- Name: KeyChanged
-- Desc: Called when the user presses a key
----------------------------------------------------------------------

function mt:KeyChanged( key, bool )
	if key == "Select" then
		self.InPort[1] = bool and self.InPort[1]|1 or self.InPort[1]&(0xFF-1)
	elseif key == "Start" then
		self.InPort[1] = bool and self.InPort[1]|4 or self.InPort[1]&(0xFF-4)
	elseif key == "A" then
		self.InPort[1] = bool and self.InPort[1]|16 or self.InPort[1]&(0xFF-16)
	elseif key == "Left" then
		self.InPort[1] = bool and self.InPort[1]|32 or self.InPort[1]&(0xFF-32)
	elseif key == "Right" then
		self.InPort[1] = bool and self.InPort[1]|64 or self.InPort[1]&(0xFF-64)
	end
end

----------------------------------------------------------------------
-- Name: Think
-- Desc: Called in the entity's Think hook
----------------------------------------------------------------------
--[[
function mt:Think()
	if self.NextReset == 0x08 then
		while self.Cycles < 16667 do
			local opcode = self.Memory[self.PC]
			self.Cycles = self.Cycles + self.CycleInc[opcode]
			self.Operators[opcode]( self )
			self.Execs = self.Execs + 1
		end
		self.Cycles = self.Cycles-16667
		if self.IE == 1 then
			self:ResetCPU(0x08)
			self.NextReset = 0x10
		end
	end
	
	if self.NextReset == 0x10 then
		while self.Cycles < 16667 do
			local opcode = self.Memory[self.PC]
			self.Cycles = self.Cycles + self.CycleInc[opcode]
			self.Operators[opcode]( self )
			self.Execs = self.Execs + 1
		end
		self.Cycles = self.Cycles-16667
		if self.IE == 1 then
			self:ResetCPU(0x10)
			self.NextReset = 0x08
		end
	end
end
]]


function mt:Think()

	for i=1,2 do
		for i=1,3000 do
			self.Operators[self.Memory[self.PC]]( self )
		end
		if self.IE == 1 then
			self:ResetCPU(0x08)
		end
		
		for i=1,3000 do
			self.Operators[self.Memory[self.PC]]( self )
		end
		if self.IE == 1 then
			self:ResetCPU(0x10)
		end
	end
end

function mt:Step()
	local opcode = self.Memory[self.PC]
	self.Cycles = self.Cycles + self.CycleInc[opcode]
	self.Operators[opcode]( self )
	self.Execs = self.Execs + 1
	if self.Cycles >= 16667 then
		self.Cycles = self.Cycles - 16667
		if self.NextReset == 0x08 and self.IE == 1 then
			self:ResetCPU( 0x08 )
			self.NextReset = 0x10
		elseif self.IE == 1 then
			self:ResetCPU( 0x10 )
			self.NextReset = 0x08
		end
	end
end

function mt:LoadRom()
	-- TODO: Erase this when gmod can read binary files
	local x = 0
	for i=1,#self.ROMstring,2 do
		self.Memory[x] = tonumber( self.ROMstring:sub(i,i+1), 16 )
		x = x + 1
	end

	-- TODO: Use this when gmod can read binary files
	--for N = 0,0x1FFF do
	--	self.Memory[N] = string_byte(string_sub(self.ROMstring,N+1,N+1))
	--end
end


-- Register Control, Combining and Memory Access

function mt:D8()	
	return self.Memory[self.PC+1]
end

function mt:D16()

	return (self.Memory[self.PC+2]<<8) + self.Memory[self.PC+1]
end

function mt:F()
	return (self.Cf + self.Hf*16 + self.IE*32 + self.Zf*64 + self.Sf*128)
end

function mt:RestoreFlags( Val )
	self.Cf = (1&Val) ~= 0 and 1 or 0
	self.Hf = (16&Val) ~= 0 and 1 or 0
	self.IE = (32&Val) ~= 0 and 1 or 0
	self.Zf = (64&Val) ~= 0 and 1 or 0
	self.Sf = (128&Val) ~= 0 and 1 or 0
end

function mt:AF()
	return (self.A<<8) | self:F()
end
	
function mt:HL()  
	return (self.H<<8) | self.L
end

function mt:BC()
	return (self.B<<8) | self.C
end

function mt:DE()
	return (self.D<<8) | self.E
end

--			  --Operation Functions--

--Stack Push
function mt:StackPush( R1, R2 )
	self.PC = self.PC+1
	self.SP = self.SP-2
	self.Memory[self.SP+1] = R1
	self.Memory[self.SP] = R2
end

-- Stack 	.
function mt:StackPop()
	self.PC = self.PC+1
	local R1 = self.Memory[self.SP+1]
	local R2 = self.Memory[self.SP]
	self.SP = self.SP+2
	return R1, R2
end

-- Jump
function mt:Jump(Val)
	if Val then
		self.PC = self:D16()
		--self.Cycles = self.Cycles + 5
	else
		self.PC = self.PC + 3
	end
end

-- Call
function mt:Call(Val)
	if Val then
		self.SP = self.SP - 2
		self.Memory[self.SP + 1] = ((self.PC+3)&0xFF00)>>8
		self.Memory[self.SP]	 = (self.PC+3)&0xFF
		self.PC = self:D16()
		--self.Cycles = self.Cycles + 7
	else
		self.PC = self.PC + 3
	end
end

-- Return
function mt:Return(Val)
	if Val then
		self.PC = (self.Memory[self.SP + 1]<<8) + self.Memory[self.SP]
		self.SP = self.SP + 2
		--self.Cycles = self.Cycles + 6
	else
		self.PC = self.PC + 1
	end
end

-- Reset
function mt:ResetCPU(Addr)
	self.SP = self.SP - 2
	self.Memory[self.SP + 1] = ((self.PC)&0xFF00)>>8
	self.Memory[self.SP]	 = (self.PC)&0xFF
	self.PC = Addr
end


-- 8Bit Inc
function mt:ByteInc(R1)
	R1 = R1+1
	self.Cf = (256&R1) ~= 0 and 1 or 0
	R1 = R1&0xFF
	self.Zf = (R1) == 0 and 1 or 0
	self.Sf = R1&128 ~= 0 and 1 or 0
	self.PC = self.PC + 1
	
	self.Hf = (((R1&15) + ((R1+1)&15))& 32) > 0 and 1 or 0
	return R1
end

-- 16Bit Inc
function mt:WordInc(R1,R2)
	self.PC = self.PC + 1
	R2 = (R2+1)&0xFF
	if R2 == 0 then R1 = (R1+1)&0xFF end
	return R1, R2	
end

-- 8Bit Dec
function mt:ByteDec(R1)
	R1 = (R1-1)&0xFF
	self.Zf = R1 == 0 and 1 or 0
	self.Sf = R1&128 ~= 0 and 1 or 0
	self.Cf = 0
	self.PC = self.PC + 1
	
	self.Hf = (((R1&15) + ((R1-1)&15))& 32) > 0 and 1 or 0
	return R1
end

-- 16Bit Dec
function mt:WordDec(R1,R2)
	R2 = (R2-1)&0xFF
	if R2 == 0xFF then R1 = (R1-1)&0xFF end
	self.PC = self.PC + 1
	return R1, R2
end

-- Logical AND
function mt:And(R1)
	self.A = self.A&R1
	self.Cf = 0
	self.Hf = 0
	self.Zf = self.A == 0 and 1 or 0
	self.Sf = R1&128 ~= 0 and 1 or 0
	self.PC = self.PC + 1
end

--Logical OR
function mt:Or(R1)
	self.A = self.A|R1
	self.Cf = 0
	self.Hf = 0
	self.Zf = self.A == 0 and 1 or 0
	self.Sf = self.A&128 ~= 0 and 1 or 0
	self.PC = self.PC + 1
end

-- Logical Xor
function mt:Xor(R1)
	self.A = (self.A | R1) & (-1-(self.A & R1))
	self.Cf = 0
	self.Hf = 0
	self.Zf = self.A == 0 and 1 or 0
	self.Sf = self.A&128 ~= 0 and 1 or 0
	self.PC = self.PC + 1
end

-- Arithmatic
function mt:ByteAdd(R1)
	self.Hf = (((self.A&15) + ((self.A+R1)&15))& 32) > 0 and 1 or 0
	
	self.A = self.A + R1
	self.Cf = (self.A&256) ~= 0 and 1 or 0
	self.A = self.A&0xFF
	self.Zf = self.A == 0 and 1 or 0
	self.Sf = self.A&128 ~= 0 and 1 or 0
	self.PC = self.PC + 1
end

function mt:ByteSub(R1)
	self.Hf = (((self.A&15) + ((self.A-R1)&15))& 32) > 0 and 1 or 0

	local Tmp = (self.A-R1)&0xFF
	if (Tmp >= self.A) and R1 ~= 0 then
		self.Cf = 1
	else
		self.Cf = 0
	end
	self.A = Tmp
	self.Sf = (self.A&128) ~= 0 and 1 or 0
	self.Zf = self.A == 0 and 1 or 0
	self.PC = self.PC + 1
end

function mt:ByteAddCarry(R1)
	self.Hf = (((self.A&15) + ((self.A+R1+self.Cf)&15))& 32) > 0 and 1 or 0

	self.A = self.A + R1 + self.Cf
	self.Cf = (self.A&256) ~= 0 and 1 or 0
	self.A = self.A&0xFF
	self.Zf = self.A == 0 and 1 or 0
	self.Sf = (self.A&128) ~= 0 and 1 or 0
	self.PC = self.PC + 1
end
	
function mt:ByteCmp(R1)
	self.Hf = (((self.A&15) + ((self.A-R1)&15))& 32) > 0 and 1 or 0

	local Tmp = (self.A-R1)&0xFF
	if (Tmp >= self.A) and R1 ~= 0 then
		self.Cf = 1
	else
		self.Cf = 0
	end
	self.Sf = (Tmp&128) ~= 0 and 1 or 0
	self.Zf = Tmp == 0 and 1 or 0
	self.PC = self.PC + 1
end

function mt:WordAdd(R1,R2)
	self.H = self.H + R1
	self.L = self.L + R2
	
	if self.L&0x100 == 0x100 then
		self.H = self.H+1
		self.L = self.L&0xFF
	end
	
	if self.H&0x100 == 0x100 then
		self.H = self.H&0xFF
		self.Cf = 1
	end
	
	self.PC = self.PC + 1
end


-----------------------------------------------------------------------------------------


mt.Operators = {}
local Operators = mt.Operators

-- Control & Interupt
Operators[0x00] = function( self ) self.PC = self.PC + 1 end -- NOP

Operators[0xF3] = function( self ) -- Interupt Disable
	self.IE = 0
	self.PC = self.PC + 1
end 

Operators[0xFB] = function( self ) -- Interupt Enable
	self.IE = 1
	self.PC = self.PC + 1
end

-- Input & Output (Special cases for shift register, Audio, High Score, Coins and Input to be done seperately)
Operators[0xDB] = function ( self ) -- Read Input Port 
	self.A = self.InPort[self.Memory[self.PC+1]]
	self.PC = self.PC + 2
end 


Operators[0xD3] = function ( self ) 
	if self:D8() == 4 then
		self.Shift = (self.Shift>>8)|(self.A<<8)
		self.InPort[3] = (((self.Shift<<self.Offset))>>8)&0xFF
	elseif self:D8() == 2 then
		self.Offset = self.A&7
		self.InPort[3] = (((self.Shift<<self.Offset))>>8)&0xFF
		
	--SOUND STUFF
	elseif self:D8() == 3 then
		local OldPort3 = self.OutPort[3]
		local Port3 = self.A
		
		if Port3&1 == 1 and not self.PlayingUFOSound then
			self.PlayingUFOSound = true
			self.UFOSound:Play()
		elseif Port3&1 == 0 and self.PlayingUFOSound then
			self.PlayingUFOSound = false
			self.UFOSound:Stop()
		end
		
		if Port3&2 > OldPort3&2 then
			self.entity:EmitSound( "gem_emulator/shot.wav" )
		end
		
		if Port3&4 > OldPort3&4 then
			self.entity:EmitSound( "gem_emulator/basehit.wav" )
		end
		
		if Port3&8 > OldPort3&8 then
			self.entity:EmitSound( "gem_emulator/invhit.wav" )
		end
		
		if Port3&16 > OldPort3&16 then
			self.entity:EmitSound( "gem_emulator/extralife.wav" )
		end
		
		if Port3&32 > OldPort3&32 then
			self.entity:EmitSound( "gem_emulator/beginplay.wav" )
		end
		
	elseif self:D8() == 5 then
		local OldPort5 = self.OutPort[5]
		local Port5 = self.A
	
		if Port5&1 > OldPort5&1 then
			self.entity:EmitSound( "gem_emulator/walk1.wav" )
		end
		
		if Port5&2 > OldPort5&2 then
			self.entity:EmitSound( "gem_emulator/walk2.wav" )
		end
		
		if Port5&4 > OldPort5&4 then
			self.entity:EmitSound( "gem_emulator/walk3.wav" )
		end
		
		if Port5&8 > OldPort5&8 then
			self.entity:EmitSound( "gem_emulator/walk4.wav" )
		end
		
		if Port5&16 > OldPort5&16 then
			self.entity:EmitSound( "gem_emulator/ufohit.wav" )
		end
	end
	
	self.OutPort[self:D8()] = self.A
	
	
	self.PC = self.PC + 2
end

-- Processor flow control


-- JUMP
Operators[0xC3] = function( self ) self:Jump(true) end -- Unconditional Jump
Operators[0xC2] = function( self ) self:Jump(self.Zf == 0) end -- Jump if not Zero
Operators[0xCA] = function( self ) self:Jump(self.Zf ~= 0) end -- Jump if Zero
Operators[0xD2] = function( self ) self:Jump(self.Cf == 0) end -- Jump if not Carry
Operators[0xDA] = function( self ) self:Jump(self.Cf ~= 0) end -- Jump if Carry
Operators[0xF2] = function( self ) self:Jump(self.Sf == 0) end -- Jump if not Sign
Operators[0xFA] = function( self ) self:Jump(self.Sf ~= 0) end -- Jump if Sign

-- CALL
Operators[0xCD] = function( self ) self:Call(true) end -- Uncondition Call
Operators[0xC4] = function( self ) self:Call(self.Zf == 0) end -- Call if not Zero
Operators[0xCC] = function( self ) self:Call(self.Zf ~= 0) end -- Call if Zero
Operators[0xD4] = function( self ) self:Call(self.Cf == 0) end -- Call if not Carry
Operators[0xDC] = function( self ) self:Call(self.Cf ~= 0) end -- Call if Carry

-- RETURN
Operators[0xC9] = function( self ) self:Return(true) end -- Uncondition Return
Operators[0xC0] = function( self ) self:Return(self.Zf == 0) end -- Return if not Zero
Operators[0xC8] = function( self ) self:Return(self.Zf ~= 0) end -- Return if Zero
Operators[0xD0] = function( self ) self:Return(self.Cf == 0) end -- Return if not Carry
Operators[0xD8] = function( self ) self:Return(self.Cf ~= 0) end -- Return if Carry

-- RESET
Operators[0xC7] = function( self ) self:ResetCPU(0x0) end -- Reset PC to 0x0
Operators[0xCF] = function( self ) self:ResetCPU(0x8) end
Operators[0xD7] = function( self ) self:ResetCPU(0x10) end
Operators[0xDF] = function( self ) self:ResetCPU(0x18) end
Operators[0xE7] = function( self ) self:ResetCPU(0x20) end
Operators[0xEF] = function( self ) self:ResetCPU(0x28) end
Operators[0xF7] = function( self ) self:ResetCPU(0x30) end
Operators[0xFF] = function( self ) self:ResetCPU(0x38) end

-- Stack Management

-- Stack Push
Operators[0xC5] = function( self ) self:StackPush(self.B,self.C) end
Operators[0xD5] = function( self ) self:StackPush(self.D,self.E) end
Operators[0xE5] = function( self ) self:StackPush(self.H,self.L) end
Operators[0xF5] = function( self ) self:StackPush(self.A,self:F()) end -- Note that F is a function, this function combines the flags into one register

-- Stack Pop
Operators[0xC1] = function( self ) self.B, self.C = self:StackPop() end
Operators[0xD1] = function( self ) self.D, self.E = self:StackPop() end
Operators[0xE1] = function( self ) self.H, self.L = self:StackPop() end
Operators[0xF1] = function( self )
	local tempA, tempF = self:StackPop()
	self.A = tempA
	self:RestoreFlags(tempF)
end


-- Incriment and Decriment

-- 8Bit Inc
Operators[0x3C] = function( self ) self.A = self:ByteInc(self.A) end
Operators[0x04] = function( self ) self.B = self:ByteInc(self.B) end
Operators[0x0C] = function( self ) self.C = self:ByteInc(self.C) end
Operators[0x14] = function( self ) self.D = self:ByteInc(self.D) end
Operators[0x1C] = function( self ) self.E = self:ByteInc(self.E) end
Operators[0x24] = function( self ) self.H = self:ByteInc(self.H) end
Operators[0x2C] = function( self ) self.L = self:ByteInc(self.L) end
Operators[0x34] = function( self ) self.Memory[self:HL()] = self:ByteInc(self.Memory[self:HL()]) end -- Inc 8Bit value in Memory HL

-- 16Bit Inc
Operators[0x03] = function( self ) self.B,self.C = self:WordInc(self.B,self.C) end
Operators[0x13] = function( self ) self.D,self.E = self:WordInc(self.D,self.E) end
Operators[0x23] = function( self ) self.H,self.L = self:WordInc(self.H,self.L) end
Operators[0x33] = function( self )  -- SP is already 16 bit long and doesn't need its own function
	self.SP = self.SP + 1
	self.PC = self.PC + 1
end

-- 8Bit Dec
Operators[0x3D] = function( self ) self.A = self:ByteDec(self.A) end
Operators[0x05] = function( self ) self.B = self:ByteDec(self.B) end
Operators[0x0D] = function( self ) self.C = self:ByteDec(self.C) end
Operators[0x15] = function( self ) self.D = self:ByteDec(self.D) end
Operators[0x1D] = function( self ) self.E = self:ByteDec(self.E) end
Operators[0x25] = function( self ) self.H = self:ByteDec(self.H) end
Operators[0x2D] = function( self ) self.L = self:ByteDec(self.L) end
Operators[0x35] = function( self ) self.Memory[self:HL()] = self:ByteDec(self.Memory[self:HL()]) end -- Dec 8Bit value in Memory HL

-- 16Bit Dec
Operators[0x0B] = function( self ) self.B,self.C = self:WordDec(self.B,self.C) end
Operators[0x1B] = function( self ) self.D,self.E = self:WordDec(self.D,self.E) end
Operators[0x2B] = function( self ) self.H,self.L = self:WordDec(self.H,self.L) end
Operators[0x3B] = function( self )  -- SP is already 16 bit long and doesn't need its own function
	self.SP = self.SP - 1
	self.PC = self.PC + 1
end

-- Logic

-- AND
Operators[0xA7] = function( self ) self:And(self.A) end
Operators[0xA0] = function( self ) self:And(self.B) end
Operators[0xA1] = function( self ) self:And(self.C) end
Operators[0xA2] = function( self ) self:And(self.D) end
Operators[0xA3] = function( self ) self:And(self.E) end
Operators[0xA4] = function( self ) self:And(self.H) end
Operators[0xA5] = function( self ) self:And(self.L) end
Operators[0xA6] = function( self ) self:And(self.Memory[self:HL()]) end
Operators[0xE6] = function( self ) self:And(self:D8()); self.PC = self.PC + 1 end

-- OR
Operators[0xB7] = function( self ) self:Or(self.A) end
Operators[0xB0] = function( self ) self:Or(self.B) end
Operators[0xB1] = function( self ) self:Or(self.C) end
Operators[0xB2] = function( self ) self:Or(self.D) end
Operators[0xB3] = function( self ) self:Or(self.E) end
Operators[0xB4] = function( self ) self:Or(self.H) end
Operators[0xB5] = function( self ) self:Or(self.L) end
Operators[0xB6] = function( self ) self:Or(self.Memory[self:HL()]) end
Operators[0xF6] = function( self ) self:Or(self:D8()); self.PC = self.PC + 1 end

-- XOR
Operators[0xAF] = function( self ) self:Xor(self.A) end
Operators[0xA8] = function( self ) self:Xor(self.B) end
Operators[0xA9] = function( self ) self:Xor(self.C) end
Operators[0xAA] = function( self ) self:Xor(self.D) end
Operators[0xAB] = function( self ) self:Xor(self.E) end
Operators[0xAC] = function( self ) self:Xor(self.H) end
Operators[0xAD] = function( self ) self:Xor(self.L) end
Operators[0xAE] = function( self ) self:Xor(self.Memory[self:HL()]) end
Operators[0xEE] = function( self ) self:Xor(self:D8()); self.PC = self.PC + 1 end

-- CMA
Operators[0x2F] = function( self )
	self. A = (self.A | 0xFF) & (-1-(self.A & 0xFF))
	self.PC = self.PC + 1
end


--Shifts & Rotates
Operators[0x0F] = function( self )
	self.A = ((self.A>>1)|(self.A<<7))&0xFF
	self.Cf = (self.A&128) ~= 0 and 1 or 0
	self.PC = self.PC + 1
end

Operators[0x1F] = function( self )
		-- local Tmp = self.A
		-- self.A = (self.A>>1)
		-- if self.Cf == 1 then
			-- self.A = (self.A|128)
			-- self.Cf = (Tmp&1)
		-- end
		
		local Tmp = self.Cf*128
		
		if self.A&1 ~= 0 then
			self.Cf = 1
		else
			self.Cf = 0
		end
		
		self.A = ((self.A&254)>>1)|Tmp
		
		
		self.PC = self.PC + 1
end	

Operators[0x07] = function( self )
	self.A = ((self.A<<1)|(self.A>>7))&0xFF
	self.Cf = (self.A&1)
	self.PC = self.PC + 1
end

--Set Carry to 1
Operators[0x37] = function( self ) self.Cf = 1; self.PC = self.PC + 1 end

-- LOADS, MOVES AND STORES

--8 Bit
Operators[0x7F] = function( self ) self.A = self.A; self.PC = self.PC + 1 end
Operators[0x78] = function( self ) self.A = self.B; self.PC = self.PC + 1 end
Operators[0x79] = function( self ) self.A = self.C; self.PC = self.PC + 1 end
Operators[0x7A] = function( self ) self.A = self.D; self.PC = self.PC + 1 end
Operators[0x7B] = function( self ) self.A = self.E; self.PC = self.PC + 1 end
Operators[0x7C] = function( self ) self.A = self.H; self.PC = self.PC + 1 end
Operators[0x7D] = function( self ) self.A = self.L; self.PC = self.PC + 1 end
Operators[0x7E] = function( self ) self.A = self.Memory[self:HL()]; self.PC = self.PC + 1 end

Operators[0x47] = function( self ) self.B = self.A; self.PC = self.PC + 1 end
Operators[0x40] = function( self ) self.B = self.B; self.PC = self.PC + 1 end
Operators[0x41] = function( self ) self.B = self.C; self.PC = self.PC + 1 end
Operators[0x42] = function( self ) self.B = self.D; self.PC = self.PC + 1 end
Operators[0x43] = function( self ) self.B = self.E; self.PC = self.PC + 1 end
Operators[0x44] = function( self ) self.B = self.H; self.PC = self.PC + 1 end
Operators[0x45] = function( self ) self.B = self.L; self.PC = self.PC + 1 end
Operators[0x46] = function( self ) self.B = self.Memory[self:HL()]; self.PC = self.PC + 1 end

Operators[0x4F] = function( self ) self.C = self.A; self.PC = self.PC + 1 end
Operators[0x48] = function( self ) self.C = self.B; self.PC = self.PC + 1 end
Operators[0x49] = function( self ) self.C = self.C; self.PC = self.PC + 1 end
Operators[0x4A] = function( self ) self.C = self.D; self.PC = self.PC + 1 end
Operators[0x4B] = function( self ) self.C = self.E; self.PC = self.PC + 1 end
Operators[0x4C] = function( self ) self.C = self.H; self.PC = self.PC + 1 end
Operators[0x4D] = function( self ) self.C = self.L; self.PC = self.PC + 1 end
Operators[0x4E] = function( self ) self.C = self.Memory[self:HL()]; self.PC = self.PC + 1 end

Operators[0x57] = function( self ) self.D = self.A; self.PC = self.PC + 1 end
Operators[0x50] = function( self ) self.D = self.B; self.PC = self.PC + 1 end
Operators[0x51] = function( self ) self.D = self.C; self.PC = self.PC + 1 end
Operators[0x52] = function( self ) self.D = self.D; self.PC = self.PC + 1 end
Operators[0x53] = function( self ) self.D = self.E; self.PC = self.PC + 1 end
Operators[0x54] = function( self ) self.D = self.H; self.PC = self.PC + 1 end
Operators[0x55] = function( self ) self.D = self.L; self.PC = self.PC + 1 end
Operators[0x56] = function( self ) self.D = self.Memory[self:HL()]; self.PC = self.PC + 1 end

Operators[0x5F] = function( self ) self.E = self.A; self.PC = self.PC + 1 end
Operators[0x58] = function( self ) self.E = self.B; self.PC = self.PC + 1 end
Operators[0x59] = function( self ) self.E = self.C; self.PC = self.PC + 1 end
Operators[0x5A] = function( self ) self.E = self.D; self.PC = self.PC + 1 end
Operators[0x5B] = function( self ) self.E = self.E; self.PC = self.PC + 1 end
Operators[0x5C] = function( self ) self.E = self.H; self.PC = self.PC + 1 end
Operators[0x5D] = function( self ) self.E = self.L; self.PC = self.PC + 1 end
Operators[0x5E] = function( self ) self.E = self.Memory[self:HL()]; self.PC = self.PC + 1 end

Operators[0x67] = function( self ) self.H = self.A; self.PC = self.PC + 1 end
Operators[0x60] = function( self ) self.H = self.B; self.PC = self.PC + 1 end
Operators[0x61] = function( self ) self.H = self.C; self.PC = self.PC + 1 end
Operators[0x62] = function( self ) self.H = self.D; self.PC = self.PC + 1 end
Operators[0x63] = function( self ) self.H = self.E; self.PC = self.PC + 1 end
Operators[0x64] = function( self ) self.H = self.H; self.PC = self.PC + 1 end
Operators[0x65] = function( self ) self.H = self.L; self.PC = self.PC + 1 end
Operators[0x66] = function( self ) self.H = self.Memory[self:HL()]; self.PC = self.PC + 1 end

Operators[0x6F] = function( self ) self.L = self.A; self.PC = self.PC + 1 end
Operators[0x68] = function( self ) self.L = self.B; self.PC = self.PC + 1 end
Operators[0x69] = function( self ) self.L = self.C; self.PC = self.PC + 1 end
Operators[0x6A] = function( self ) self.L = self.D; self.PC = self.PC + 1 end
Operators[0x6B] = function( self ) self.L = self.E; self.PC = self.PC + 1 end
Operators[0x6C] = function( self ) self.L = self.H; self.PC = self.PC + 1 end
Operators[0x6D] = function( self ) self.L = self.L; self.PC = self.PC + 1 end
Operators[0x6E] = function( self ) self.L = self.Memory[self:HL()]; self.PC = self.PC + 1 end

Operators[0x77] = function( self ) self.Memory[self:HL()] = self.A; self.PC = self.PC + 1 end
Operators[0x70] = function( self ) self.Memory[self:HL()] = self.B; self.PC = self.PC + 1 end
Operators[0x71] = function( self ) self.Memory[self:HL()] = self.C; self.PC = self.PC + 1 end
Operators[0x72] = function( self ) self.Memory[self:HL()] = self.D; self.PC = self.PC + 1 end
Operators[0x73] = function( self ) self.Memory[self:HL()] = self.E; self.PC = self.PC + 1 end
Operators[0x74] = function( self ) self.Memory[self:HL()] = self.H; self.PC = self.PC + 1 end
Operators[0x75] = function( self ) self.Memory[self:HL()] = self.L; self.PC = self.PC + 1 end

-- Memory Loads (uses 16 bit registr pair or Immediate 16 bit data)
Operators[0x0A] = function( self ) self.A = self.Memory[self:BC()]; self.PC = self.PC + 1 end
Operators[0x1A] = function( self ) self.A = self.Memory[self:DE()]; self.PC = self.PC + 1 end
Operators[0x3A] = function( self ) self.A = self.Memory[self:D16()]; self.PC = self.PC + 3 end

-- Load 16 bit immediate into 16 bit register pair
Operators[0x01] = function( self ) self.B = self.Memory[self.PC+2]; self.C = self.Memory[self.PC+1]; self.PC = self.PC + 3 end
Operators[0x11] = function( self ) self.D = self.Memory[self.PC+2]; self.E = self.Memory[self.PC+1]; self.PC = self.PC + 3 end
Operators[0x21] = function( self ) self.H = self.Memory[self.PC+2]; self.L = self.Memory[self.PC+1]; self.PC = self.PC + 3 end
Operators[0x31] = function( self ) self.SP = self:D16(); self.PC = self.PC + 3 end

-- Load 8 Bit immediate into 8 bit register
Operators[0x3E] = function( self ) self.A = self.Memory[self.PC+1]; self.PC = self.PC + 2 end
Operators[0x06] = function( self ) self.B = self.Memory[self.PC+1]; self.PC = self.PC + 2 end
Operators[0x0E] = function( self ) self.C = self.Memory[self.PC+1]; self.PC = self.PC + 2 end
Operators[0x16] = function( self ) self.D = self.Memory[self.PC+1]; self.PC = self.PC + 2 end
Operators[0x1E] = function( self ) self.E = self.Memory[self.PC+1]; self.PC = self.PC + 2 end
Operators[0x26] = function( self ) self.H = self.Memory[self.PC+1]; self.PC = self.PC + 2 end
Operators[0x2E] = function( self ) self.L = self.Memory[self.PC+1]; self.PC = self.PC + 2 end
Operators[0x36] = function( self ) self.Memory[self:HL()] = self.Memory[self.PC+1]; self.PC = self.PC + 2 end

--Load 8 bit data into address pointed by 16 bit register pair
Operators[0x02] = function( self ) self.Memory[self:BC()] = self.A; self.PC = self.PC + 1 end
Operators[0x12] = function( self ) self.Memory[self:DE()] = self.A; self.PC = self.PC + 1 end
Operators[0x32] = function( self ) self.Memory[self:D16()] = self.A; self.PC = self.PC + 3 end
Operators[0x22] = function( self ) self.Memory[self:D16()+1] = self.H; self.Memory[self:D16()] = self.L; self.PC = self.PC + 3 end
Operators[0x2A] = function( self ) self.H = self.Memory[self:D16()+1]; self.L = self.Memory[self:D16()]; self.PC = self.PC + 3 end

-- Transfers
Operators[0xEB] = function( self )
	local Tmp1 = self.H
	local Tmp2 = self.L
	self.H = self.D
	self.L = self.E
	self.D = Tmp1
	self.E = Tmp2
	self.PC = self.PC + 1
end

Operators[0xE3] = function( self )--XTHL
	local Tmp1 = self.H
	local Tmp2 = self.L
	self.H = self.Memory[self.SP+1]
	self.L = self.Memory[self.SP]
	self.Memory[self.SP+1] = Tmp1
	self.Memory[self.SP] = Tmp2
	self.PC = self.PC + 1
end 

Operators[0xE9] = function( self ) self.PC = self:HL() end -- PCHL


-- Arithmatic

-- Add
Operators[0x87] = function( self ) self:ByteAdd(self.A) end
Operators[0x80] = function( self ) self:ByteAdd(self.B) end
Operators[0x81] = function( self ) self:ByteAdd(self.C) end
Operators[0x82] = function( self ) self:ByteAdd(self.D) end
Operators[0x83] = function( self ) self:ByteAdd(self.E) end
Operators[0x84] = function( self ) self:ByteAdd(self.H) end
Operators[0x85] = function( self ) self:ByteAdd(self.L) end
Operators[0x86] = function( self ) self:ByteAdd(self.Memory[self:HL()]) end
Operators[0xC6] = function( self ) self:ByteAdd(self:D8()); self.PC = self.PC + 1 end

-- Sub
Operators[0x97] = function( self ) self:ByteSub(self.A) end
Operators[0x90] = function( self ) self:ByteSub(self.B) end
Operators[0x91] = function( self ) self:ByteSub(self.C) end
Operators[0x92] = function( self ) self:ByteSub(self.D) end
Operators[0x93] = function( self ) self:ByteSub(self.E) end
Operators[0x94] = function( self ) self:ByteSub(self.H) end
Operators[0x95] = function( self ) self:ByteSub(self.L) end
Operators[0x96] = function( self ) self:ByteSub(self.Memory[self:HL()]) end
Operators[0xD6] = function( self ) self:ByteSub(self:D8()); self.PC = self.PC + 1 end

-- Add with Carry
Operators[0x8F] = function( self ) self:ByteAddCarry(self.A) end
Operators[0x88] = function( self ) self:ByteAddCarry(self.B) end
Operators[0x89] = function( self ) self:ByteAddCarry(self.C) end
Operators[0x8A] = function( self ) self:ByteAddCarry(self.D) end
Operators[0x8B] = function( self ) self:ByteAddCarry(self.E) end
Operators[0x8C] = function( self ) self:ByteAddCarry(self.H) end
Operators[0x8D] = function( self ) self:ByteAddCarry(self.L) end
Operators[0x8E] = function( self ) self:ByteAddCarry(self.Memory[self:HL()]) end
Operators[0xCE] = function( self ) self:ByteAddCarry(self:D8()); self.PC = self.PC + 1 end

-- Compare

Operators[0xBF] = function( self ) self:ByteCmp(self.A) end
Operators[0xB8] = function( self ) self:ByteCmp(self.B) end
Operators[0xB9] = function( self ) self:ByteCmp(self.C) end
Operators[0xBA] = function( self ) self:ByteCmp(self.D) end
Operators[0xBB] = function( self ) self:ByteCmp(self.E) end
Operators[0xBC] = function( self ) self:ByteCmp(self.H) end
Operators[0xBD] = function( self ) self:ByteCmp(self.L) end
Operators[0xBE] = function( self ) self:ByteCmp(self.Memory[self:HL()]) end
Operators[0xFE] = function( self ) self:ByteCmp(self:D8()); self.PC = self.PC + 1 end

-- SBBI	

Operators[0xDE] = function ( self ) 
	local Tmp = (self.A-self:D8()-self.Cf)&0xFF
	self.Cf = Tmp >= self.A and (self:D8() ~= 0 or self.Cf ~= 0) and 1 or 0
	self.Sf = (Tmp&128) ~= 0 and 1 or 0
	self.Zf = Tmp == 0 and 1 or 0
	self.A = Tmp
	self.PC = self.PC + 2
end

--16 Bit Add

Operators[0x09] = function( self ) self:WordAdd(self.B,self.C) end
Operators[0x19] = function( self ) self:WordAdd(self.D,self.E) end
Operators[0x29] = function( self ) self:WordAdd(self.H,self.L) end
Operators[0x39] = function( self ) self:WordAdd((self.SP&0xFF00)>>8,self.SP&0xFF) end

--DAA, do this to get scores working and not glitchy

Operators[0x27] = function( self ) 
	
	if (self.A&0xF) > 9 or self.Hf == 1 then
		self.A = self.A + 0x06
	end
	
	self.Hf = (((self.A&15) + ((self.A-0x06)&15))& 32) > 0 and 1 or 0
	
	if self.A > 0x9F or self.Cf == 1 then
		self.A = self.A + 0x60
	end
	
	if self.A > 0xFF then
		self.Cf = 1
		self.A = self.A&0xFF
	else
		self.Cf = 0
	end
	self.Sf = (self.A&128) ~= 0 and 1 or 0
	self.Zf = self.A == 0 and 1 or 0

	self.PC = self.PC + 1
end

mt.CycleInc = {
	   10,7, 6, 5, 5, 7, 4, 0, 11,7, 6, 5, 5, 7, 4,
	0, 10,7, 6, 5, 5, 7, 4, 0, 11,7, 6, 5, 5, 7, 4,
	0, 10,16,6, 5, 5, 7, 4, 0, 11,16,6, 5, 5, 7, 4,
	0, 10,13,6, 10,10,10,4, 0, 11,13,6, 5, 5, 7, 4,
	5, 5, 5, 5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 7, 5,
	5, 5, 5, 5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 7, 5,
	5, 5, 5, 5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 7, 5,
	7, 7, 7, 7, 7, 7, 7, 7, 5, 5, 5, 5, 5, 5, 7, 5,
	4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,
	4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,
	4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,
	4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,
	5, 10,10,5,11,11,7, 11,5, 4,10,0, 11,10,7, 11,
	5, 10,10,10,11,11,7, 11,5, 0, 10,10,11,0, 7, 11,
	5, 10,10,4,11,11,7, 11,5, 4, 10,4, 11,0, 7, 11,
	5, 10,10,4, 11,11,7, 11,5, 5, 10,4, 11,0, 7, 11
}
mt.CycleInc[0] = 4

mt.Mnemonic = {
		"lxi b,#",	"stax b",		"inx b",		"inr b",		"dcr b",		"mvi b,#",		"rlc",			"ill",			"dad b",	"ldax b",	"dcx b",	"inr c",	"dcr c",	"mvi c,#",	"rrc",
		"ill",		"lxi d,#",		"stax d",		"inx d",		"inr d",		"dcr d",		"mvi d,#",		"ral",			"ill",	 	"dad d",	"ldax d",	"dcx d",	"inr e",	"dcr e",	"mvi e,#",	"rar",
		"ill",		"lxi h,#",		"shld",			"inx h",		"inr h",		"dcr h",		"mvi h,#",		"daa",			"ill",		"dad h",	"lhld",		"dcx h",	"inr l",	"dcr l",	"mvi l,#",	"cma",
		"ill",		"lxi sp,#",		"sta $",		"inx sp",		"inr M",		"dcr M",		"mvi M,#",		"stc",			"ill",		"dad sp",	"lda $",	"dcx sp",	"inr a",	"dcr a",	"mvi a,#",	"cmc",
		"mov b,b",	"mov b,c",		"mov b,d",		"mov b,e",		"mov b,h",		"mov b,l",		"mov b,M",		"mov b,a",		"mov c,b",	"mov c,c",	"mov c,d",	"mov c,e",	"mov c,h",	"mov c,l",	"mov c,M",	"mov c,a",
		"mov d,b",	"mov d,c",		"mov d,d",		"mov d,e",		"mov d,h",		"mov d,l",		"mov d,M",		"mov d,a",		"mov e,b",	"mov e,c",	"mov e,d",	"mov e,e",	"mov e,h",	"mov e,l",	"mov e,M",	"mov e,a",
		"mov h,b",	"mov h,c",		"mov h,d",		"mov h,e",		"mov h,h",		"mov h,l",		"mov h,M",		"mov h,a",		"mov l,b",	"mov l,c",	"mov l,d",	"mov l,e",	"mov l,h",	"mov l,l",	"mov l,M",	"mov l,a",
		"mov M,b",	"mov M,c",		"mov M,d",		"mov M,e",		"mov M,h",		"mov M,l",		"hlt",			"mov M,a",		"mov a,b",	"mov a,c",	"mov a,d",	"mov a,e",	"mov a,h",	"mov a,l",	"mov a,M",	"mov a,a",
		"add b",	"add c",		"add d",		"add e",		"add h",		"add l",		"add M",		"add a",		"adc b",	"adc c",	"adc d",	"adc e",	"adc h",	"adc l",	"adc M",	"adc a",
		"sub b",	"sub c",		"sub d",		"sub e",		"sub h",		"sub l",		"sub M",		"sub a",		"sbb b",	"sbb c",	"sbb d",	"sbb e",	"sbb h",	"sbb l",	"sbb M",	"sbb a",
		"ana b",	"ana c",		"ana d",		"ana e",		"ana h",		"ana l",		"ana M",		"ana a",		"xra b",	"xra c",	"xra d",	"xra e",	"xra h",	"xra l",	"xra M",	"xra a",
		"ora b",	"ora c",		"ora d",		"ora e",		"ora h",		"ora l",		"ora M",		"ora a",		"cmp b",	"cmp c",	"cmp d",	"cmp e",	"cmp h",	"cmp l",	"cmp M",	"cmp a",
		"rnz",		"pop b",		"jnz $",		"jmp $",		"cnz $",		"push b",		"adi #",		"rst 0",		"rz",		"ret",		"jz $",		"ill",		"cz $",		"call $",	"aci #",	"rst 1",
		"rnc",		"pop d",		"jnc $",		"out p",		"cnc $",		"push d",		"sui #",		"rst 2",		"rc",		"ill",		"jc $",		"in p",		"cc $",		"ill",		"sbi #",	"rst 3",
		"rpo",		"pop h",		"jpo $",		"xthl",			"cpo $",		"push h",		"ani #",		"rst 4",		"rpe",		"pchl",		"jpe $",	"xchg",		"cpe $",	"ill",		"xri #",	"rst 5",
		"rp",		"pop psw",		"jp $",			"di",			"cp $",			"push psw",		"ori #",		"rst 6",		"rm",		"sphl",		"jm $",		"ei",		"cm $",		"ill",		"cpi #",	"rst 7"
}
mt.Mnemonic[0] =   "nop"