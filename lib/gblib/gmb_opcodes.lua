local self = GnomeBoyAdvance
local gem = GBAgem
local mt = gem.GBZ80

mt.Operators = {}
local Operators = mt.Operators

local band = bit.band;
local bor = bit.bor;
local rshift = bit.rshift;
local lshift = bit.lshift;

--- 16 bit arithmatic/logic functions ---
function mt:WordInc(R1, R2)
	R1 = band((R1+1),0xFF)
	if R1 == 0 then R2 = band((R2+1), 0xFF) end
	
	self.PC = self.PC + 1
	self.Cycle = 8 
	
	return R1, R2
end

function mt:WordDec(R1, R2)
	R1 = band((R1-1 ),0xFF)
	if R1 == 0xFF then R2 = band((R2-1), 0xFF) end
	
	self.PC = self.PC + 1
	self.Cycle = 8
	
	return R1, R2
end

function mt:WordAdd(R1, R2)

	self.Hf = (band((self.H),0xF) + band(R1,0xF) + (((self.L + R2) > 0xFF) and 1 or 0)) > 0xF

	self.H = self.H + R1
	self.L = self.L + R2

	if self.L > 0xFF then
		self.H = self.H + 1
		self.L = band(self.L,0xFF)
	end
	
	if self.H > 0xFF then
		self.H = band(self.H,0xFF)
		self.Cf = true
	else
		self.Cf = false
	end
	
	self.Nf = false

	self.PC = self.PC + 1
	self.Cycle = 8
end

--- Jumps/Calls, general Flow control--

function mt:JumpSign(Val)
	if Val then
		local D8 = self:Read(self.PC+1)
		
		self.PC = self.PC + (band(D8,127)-band(D8,128)) + 2

		self.PC = band(self.PC,0xFFFF)

		self.Cycle = 12
	else
		self.PC = self.PC + 2
		self.Cycle = 8
	end
end

function mt:Jump(Val)
	if Val then
		local A16 = bor(lshift(self:Read(self.PC+2),8),self:Read(self.PC+1))
		self.PC = A16
		self.Cycle = 16
	else
		self.PC = self.PC + 3
		self.Cycle = 12
	end
end

function mt:Call(Val)
	if Val then
		local A16 = bor(lshift(self:Read(self.PC+2),8),self:Read(self.PC+1))
		self.SP = self.SP - 2
		self:Write(self.SP + 1, rshift(band((self.PC+3),0xFF00),8))
		self:Write(self.SP    , band((self.PC+3),0xFF)       )

		self.PC = A16
		self.Cycle = 24
	else
		self.PC = self.PC + 3
		self.Cycle = 12
	end
end

function mt:Return(Val)
	if Val then

		self.PC = bor(lshift(self:Read(self.SP + 1),8),self:Read(self.SP))
		self.SP = self.SP + 2
		
		self.Cycle = 20
	else
		self.PC = self.PC + 1
		self.Cycle = 8
	end
end
		
function mt:ResetPC(Addr)
	self.SP = self.SP - 2
	self:Write( self.SP + 1, rshift(band((self.PC+1),0xFF00),8) )
	self:Write( self.SP    , band((self.PC+1),0xFF) )
	
	self.PC = Addr
	self.Cycle = 16
end


--- Stack Operations --- 

function mt:StackPush( R1, R2 )
	self.SP = self.SP - 2
	self:Write( self.SP  + 1, R1 )
	self:Write( self.SP, R2 )
	
	self.PC = self.PC + 1
	self.Cycle = 16
end

function mt:StackPop()	
	local R1 = self:Read( self.SP + 1 )
	local R2 = self:Read( self.SP )
	self.SP = self.SP + 2
	
	self.PC = self.PC + 1
	self.Cycle = 12
	return R1, R2
end

-- ARITHMATIC AND LOGIC

function mt:ByteAdd(R1)
	
	self.Hf = (band(self.A,0xF) + band(R1,0xF)) > 0xF
	
	self.A = self.A + R1
	self.Cf = self.A > 0xFF
	
	self.A = band(self.A,0xFF)
	
	self.Nf = false
	self.Zf = self.A == 0
	
	self.PC = self.PC + 1
	self.Cycle = 4
end

function mt:ByteAdc(R1)

	self.Hf = (band(self.A,0xF) + band(R1,0x0F) + (self.Cf and 1 or 0)) > 0xF
	
	self.A = self.A + R1 + (self.Cf and 1 or 0)
	self.Cf = self.A > 0xFF
	
	self.A = band(self.A,0xFF)
	
	self.Nf = false
	self.Zf = self.A == 0
	
	self.PC = self.PC + 1
	self.Cycle = 4
end

function mt:ByteSub(R1)
	self.Hf = band(R1,0xF) > band(self.A,0xF) 
	self.Cf = R1 > self.A
	
	self.A = band(( self.A - R1 ),0xFF)
	
	self.Zf = self.A == 0
	self.Nf = true
	
	self.PC = self.PC + 1
	self.Cycle = 4
end


function mt:ByteSbc(R1)

	local SubVal = (R1 + (self.Cf and 1 or 0))

	self.Hf = (band(R1,0xF) + (self.Cf and 1 or 0) ) > band(self.A,0xF)
	self.Cf = SubVal > self.A
	
	self.A = band(( self.A - SubVal ),0xFF)
	
	self.Zf = self.A == 0
	self.Nf = true
	
	self.PC = self.PC + 1
	self.Cycle = 4
end


function mt:ByteAnd(R1)
	self.A = band(self.A,R1)
	
	self.Zf = self.A == 0
	self.Nf = false
	self.Hf = true
	self.Cf = false
	
	self.PC = self.PC + 1
	self.Cycle = 4
end

function mt:ByteXor(R1)
	self.A = band(bor(self.A,R1),(-1-band(self.A,R1)))
	
	self.Zf = self.A == 0
	self.Nf = false
	self.Hf = false
	self.Cf = false
	
	self.PC = self.PC + 1
	self.cycle = 4
end

function mt:ByteOr(R1)
	self.A = bor(self.A,R1)
	
	self.Zf = self.A == 0
	self.Nf = false
	self.Hf = false
	self.Cf = false
	
	self.PC = self.PC + 1
	self.cycle = 4
end

function mt:ByteCmp(R1)


	self.Hf = band( R1,0xF ) > band( self.A,0xF )
	self.Cf = R1 > self.A
	
	self.Zf = band((self.A - R1),0xFF ) == 0
	self.Nf = true
	
	self.PC = self.PC + 1
	self.cycle = 4
end


-- Byte Inc and Dec
function mt:ByteInc(R1)
	self.Hf = band(R1,0xF) == 0xF
	
	R1 = band((R1+1),0xFF)
	
	self.Nf = false
	self.Zf = R1 == 0

	self.PC = self.PC + 1

	self.cycle = 4
	
	return R1
end

function mt:ByteDec(R1)
	self.Hf = (band((R1 - 1),0xF ) > band(R1,0xF))
	
	R1 = band((R1-1),0xFF)
	
	self.Nf = true
	self.Zf = R1 == 0
	
	self.PC = self.PC + 1
	self.cycle = 4
	
	return R1
end















--- MISC/CONTROL INSTRUCTIONS ---

-- NOP
Operators[ 0x00 ] =  function( self )	
	self.PC = self.PC + 1
	self.Cycle = 4
end

-- STOP
Operators[ 0x10 ] =  function( self )
	self.Halt = true

	self.PC = self.PC + 2
	self.Cycle = 4
	-- turns off the gameboy?
end

-- HALT
Operators[ 0x76 ] = function( self )
	if self.IME then
		self.Halt = true
	end
	
	self.PC = self.PC + 1
	self.Cycle = 4
end

-- Disable Interupts
Operators[ 0xF3 ] = function( self )
	self.IME = false
	
	self.PC = self.PC + 1
	self.Cycle = 4
end

--Enable Interupts
Operators[ 0xFB ] = function( self )
	self.IME = true
	
	self.PC = self.PC + 1
	self.Cycle = 4
end


-- CB opcodes
Operators[ 0xCB ] = function( self )
	self.OperatorsCB[self:Read(self.PC + 1) ]( self )
end



--- JUMPS/CALLS/RETURNS/FLOW CONTROL GENERAL --- 


-- Signed Jumps
Operators[ 0x18 ] =  function( self ) self:JumpSign( true ) end
Operators[ 0x20 ] =  function( self ) self:JumpSign( not self.Zf ) end
Operators[ 0x30 ] =  function( self ) self:JumpSign( not self.Cf ) end
Operators[ 0x28 ] =  function( self ) self:JumpSign( self.Zf ) end
Operators[ 0x38 ] =  function( self ) self:JumpSign( self.Cf ) end

-- Absolute Jumps
Operators[ 0xC3 ] =  function( self ) self:Jump( true ) end
Operators[ 0xC2 ] =  function( self ) self:Jump( not self.Zf ) end
Operators[ 0xD2 ] =  function( self ) self:Jump( not self.Cf ) end
Operators[ 0xCA ] =  function( self ) self:Jump( self.Zf ) end
Operators[ 0xDA ] =  function( self ) self:Jump( self.Cf ) end

-- Call Subroutine
Operators[ 0xCD ] =  function( self ) self:Call( true ) end
Operators[ 0xC4 ] =  function( self ) self:Call( not self.Zf ) end
Operators[ 0xD4 ] =  function( self ) self:Call( not self.Cf ) end
Operators[ 0xCC ] =  function( self ) self:Call( self.Zf ) end
Operators[ 0xDC ] =  function( self ) self:Call( self.Cf ) end

-- Return from Subroutine
Operators[ 0xC9 ] = function( self ) self:Return( true ); self.Cycle = 16 end
Operators[ 0xD9 ] = function( self ) self.IME = true; self:Return( true ); self.Cycle = 16 end
Operators[ 0xC0 ] = function( self ) self:Return( not self.Zf ) end
Operators[ 0xD0 ] = function( self ) self:Return( not self.Cf ) end
Operators[ 0xC8 ] = function( self ) self:Return( self.Zf ) end
Operators[ 0xD8 ] = function( self ) self:Return( self.Cf ) end

-- ResetPC
Operators[ 0xC7 ] = function( self ) self:ResetPC( 0x00 ) end
Operators[ 0xD7 ] = function( self ) self:ResetPC( 0x10 ) end
Operators[ 0xE7 ] = function( self ) self:ResetPC( 0x20 ) end
Operators[ 0xF7 ] = function( self ) self:ResetPC( 0x30 ) end

Operators[ 0xCF ] = function( self ) self:ResetPC( 0x08 ) end
Operators[ 0xDF ] = function( self ) self:ResetPC( 0x18 ) end
Operators[ 0xEF ] = function( self ) self:ResetPC( 0x28 ) end
Operators[ 0xFF ] = function( self ) self:ResetPC( 0x38 ) end

-- Jump to address in HL

Operators[ 0xE9 ] = function( self )
	self.PC = bor(lshift(self.H,8),self.L)
	
	self.Cycle = 4
end

--- 16 BIT ARITHMATIC & LOGIC ---

-- Incrimnt 16 Bit Register
Operators[ 0x03 ] =  function( self ) self.C,self.B = self:WordInc(self.C,self.B) end
Operators[ 0x13 ] =  function( self ) self.E,self.D = self:WordInc(self.E,self.D) end
Operators[ 0x23 ] =  function( self ) self.L,self.H = self:WordInc(self.L,self.H) end
Operators[ 0x33 ] =  function( self ) self.SP = self.SP + 1; self.PC = self.PC + 1; self.Cycle = 8 end

-- Decriment 16 Bit Register
Operators[ 0x0B ] =  function( self ) self.C,self.B = self:WordDec(self.C,self.B) end
Operators[ 0x1B ] =  function( self ) self.E,self.D = self:WordDec(self.E,self.D) end
Operators[ 0x2B ] =  function( self ) self.L,self.H = self:WordDec(self.L,self.H) end
Operators[ 0x3B ] =  function( self ) self.SP = self.SP - 1; self.PC = self.PC + 1; self.Cycle = 8 end

--Add 16 Bit Register to HL
Operators[ 0x09 ] =  function( self ) self:WordAdd(self.B, self.C) end
Operators[ 0x19 ] =  function( self ) self:WordAdd(self.D, self.E) end
Operators[ 0x29 ] =  function( self ) self:WordAdd(self.H, self.L) end
Operators[ 0x39 ] =  function( self ) self:WordAdd( band(rshift(self.SP,8),0xFF) , band(self.SP , 0xFF) ) end -- Split the SP up first

-- Add signed immediate to SP
Operators[ 0xE8 ] =  function( self )
	local D8 = self:Read(self.PC+1)
	local S8 = band(D8,127)-band(D8,128)-- This turns a regular 8 bit unsigned number into a signed number. 
	local SP = self.SP + S8

	if S8 >= 0 then
		self.Cf = ( band(self.SP,0xFF) + ( S8 ) ) > 0xFF
		self.Hf = ( band(self.SP,0xF) + band( S8,0xF ) ) > 0xF
	else
		self.Cf = band(SP,0xFF) <= band(self.SP,0xFF)
		self.Hf = band(SP,0xF) <= band(self.SP,0xF)
	end

	self.SP = band( SP, 0xFFFF )

	self.Zf = false
	self.Nf = false

	self.PC = self.PC + 2
	self.Cycle = 16
end



-- Regular 8 bit loads

-- Load into B
Operators[ 0x40 ] =  function( self ) self.B = self.B; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x41 ] =  function( self ) self.B = self.C; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x42 ] =  function( self ) self.B = self.D; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x43 ] =  function( self ) self.B = self.E; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x44 ] =  function( self ) self.B = self.H; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x45 ] =  function( self ) self.B = self.L; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x46 ] =  function( self ) self.B = self:Read(bor(lshift(self.H,8),self.L)); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x47 ] =  function( self ) self.B = self.A; self.Cycle = 4; self.PC = self.PC + 1 end

-- Load into C
Operators[ 0x48 ] =  function( self ) self.C = self.B; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x49 ] =  function( self ) self.C = self.C; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x4A ] =  function( self ) self.C = self.D; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x4B ] =  function( self ) self.C = self.E; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x4C ] =  function( self ) self.C = self.H; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x4D ] =  function( self ) self.C = self.L; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x4E ] =  function( self ) self.C = self:Read(bor(lshift(self.H,8),self.L)); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x4F ] =  function( self ) self.C = self.A; self.Cycle = 4; self.PC = self.PC + 1 end

-- Load into D
Operators[ 0x50 ] =  function( self ) self.D = self.B; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x51 ] =  function( self ) self.D = self.C; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x52 ] =  function( self ) self.D = self.D; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x53 ] =  function( self ) self.D = self.E; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x54 ] =  function( self ) self.D = self.H; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x55 ] =  function( self ) self.D = self.L; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x56 ] =  function( self ) self.D = self:Read(bor(lshift(self.H,8),self.L)); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x57 ] =  function( self ) self.D = self.A; self.Cycle = 4; self.PC = self.PC + 1 end

-- Load into E
Operators[ 0x58 ] =  function( self ) self.E = self.B; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x59 ] =  function( self ) self.E = self.C; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x5A ] =  function( self ) self.E = self.D; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x5B ] =  function( self ) self.E = self.E; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x5C ] =  function( self ) self.E = self.H; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x5D ] =  function( self ) self.E = self.L; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x5E ] =  function( self ) self.E = self:Read(bor(lshift(self.H,8),self.L)); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x5F ] =  function( self ) self.E = self.A; self.Cycle = 4; self.PC = self.PC + 1 end

-- Load into H
Operators[ 0x60 ] =  function( self ) self.H = self.B; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x61 ] =  function( self ) self.H = self.C; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x62 ] =  function( self ) self.H = self.D; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x63 ] =  function( self ) self.H = self.E; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x64 ] =  function( self ) self.H = self.H; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x65 ] =  function( self ) self.H = self.L; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x66 ] =  function( self ) self.H = self:Read(bor(lshift(self.H,8),self.L)); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x67 ] =  function( self ) self.H = self.A; self.Cycle = 4; self.PC = self.PC + 1 end

-- Load into L
Operators[ 0x68 ] =  function( self ) self.L = self.B; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x69 ] =  function( self ) self.L = self.C; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x6A ] =  function( self ) self.L = self.D; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x6B ] =  function( self ) self.L = self.E; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x6C ] =  function( self ) self.L = self.H; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x6D ] =  function( self ) self.L = self.L; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x6E ] =  function( self ) self.L = self:Read(bor(lshift(self.H,8),self.L)); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x6F ] =  function( self ) self.L = self.A; self.Cycle = 4; self.PC = self.PC + 1 end

-- Load into (HL)
Operators[ 0x70 ] =  function( self ) self:Write(bor(lshift(self.H,8),self.L), self.B); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x71 ] =  function( self ) self:Write(bor(lshift(self.H,8),self.L), self.C); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x72 ] =  function( self ) self:Write(bor(lshift(self.H,8),self.L), self.D); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x73 ] =  function( self ) self:Write(bor(lshift(self.H,8),self.L), self.E); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x74 ] =  function( self ) self:Write(bor(lshift(self.H,8),self.L), self.H); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x75 ] =  function( self ) self:Write(bor(lshift(self.H,8),self.L), self.L); self.Cycle = 8; self.PC = self.PC + 1 end

Operators[ 0x77 ] =  function( self ) self:Write(bor(lshift(self.H,8),self.L), self.A); self.Cycle = 8; self.PC = self.PC + 1 end

-- Load into A
Operators[ 0x78 ] =  function( self ) self.A = self.B; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x79 ] =  function( self ) self.A = self.C; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x7A ] =  function( self ) self.A = self.D; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x7B ] =  function( self ) self.A = self.E; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x7C ] =  function( self ) self.A = self.H; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x7D ] =  function( self ) self.A = self.L; self.Cycle = 4; self.PC = self.PC + 1 end
Operators[ 0x7E ] =  function( self ) self.A = self:Read(bor(lshift(self.H,8),self.L)); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0x7F ] =  function( self ) self.A = self.A; self.Cycle = 4; self.PC = self.PC + 1 end


-- Load immediate data into register
Operators[ 0x06 ] =  function( self ) self.B = self:Read(self.PC+1); self.Cycle = 8; self.PC = self.PC + 2 end
Operators[ 0x0E ] =  function( self ) self.C = self:Read(self.PC+1); self.Cycle = 8; self.PC = self.PC + 2 end
Operators[ 0x16 ] =  function( self ) self.D = self:Read(self.PC+1); self.Cycle = 8; self.PC = self.PC + 2 end
Operators[ 0x1E ] =  function( self ) self.E = self:Read(self.PC+1); self.Cycle = 8; self.PC = self.PC + 2 end
Operators[ 0x26 ] =  function( self ) self.H = self:Read(self.PC+1); self.Cycle = 8; self.PC = self.PC + 2 end
Operators[ 0x2E ] =  function( self ) self.L = self:Read(self.PC+1); self.Cycle = 8; self.PC = self.PC + 2 end
Operators[ 0x36 ] =  function( self ) self:Write(bor(lshift(self.H,8),self.L), self:Read(self.PC+1)); self.Cycle = 12; self.PC = self.PC + 2 end
Operators[ 0x3E ] =  function( self ) self.A = self:Read(self.PC+1); self.Cycle = 8; self.PC = self.PC + 2 end

-- The wierd 8 bit loads
-- Load A into 0xFF00 + immediate data or visa-versa
Operators[ 0xE0 ] = function( self ) self:Write( 0xFF00 + self:Read(self.PC+1), self.A); self.Cycle = 12; self.PC = self.PC + 2 end
Operators[ 0xF0 ] = function( self ) self.A = self:Read( 0xFF00 + self:Read(self.PC+1)); self.Cycle = 12; self.PC = self.PC + 2 end

-- Load A into 0xFF + C or visa-versa. 
Operators[ 0xE2 ] = function( self ) self:Write( 0xFF00 + self.C, self.A ); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0xF2 ] = function( self ) self.A = self:Read( 0xFF00 + self.C ); self.Cycle = 8; self.PC = self.PC + 1 end

-- Load A into immediate addres (A16) or visa-versa
Operators[ 0xEA ] = function( self )
	local A16 = bor(lshift(self:Read(self.PC+2),8),self:Read(self.PC+1))
	self:Write( A16, self.A)
	
	self.Cycle = 16
	self.PC = self.PC + 3
end

Operators[ 0xFA ] = function( self )
	local A16 = bor(lshift(self:Read(self.PC+2),8),self:Read(self.PC+1))

	self.A = self:Read( A16 )
	
	self.Cycle = 16
	self.PC = self.PC + 3
end

Operators[ 0x02 ] = function( self )
	local A16 = bor(lshift(self.B,8),self.C)
	self:Write( A16, self.A )

	self.Cycle = 8
	self.PC = self.PC + 1
end

Operators[ 0x12 ] = function( self )
	local A16 = bor(lshift(self.D,8),self.E)
	self:Write( A16, self.A )

	self.Cycle = 8
	self.PC = self.PC + 1
end

Operators[ 0x22 ] = function( self )

	self:Write( bor(lshift(self.H,8),self.L), self.A )

	self.L = self.L + 1
	if self.L > 0xFF then
		self.L = band(self.L,0xFF)
		self.H = band((self.H + 1),0xFF)
	end


	self.Cycle = 8
	self.PC = self.PC + 1
end

Operators[ 0x32 ] = function( self )

	self:Write( bor(lshift(self.H,8),self.L), self.A )

	self.L = self.L - 1
	if self.L < 0 then
		self.L = band(self.L,0xFF)
		self.H = band((self.H - 1),0xFF)
	end

	self.Cycle = 8
	self.PC = self.PC + 1
end


Operators[ 0x0A ] = function( self )
	local A16 = bor(lshift(self.B,8),self.C)
	self.A = self:Read( A16 )

	self.Cycle = 8
	self.PC = self.PC + 1
end

Operators[ 0x1A ] = function( self )
	local A16 = bor(lshift(self.D,8),self.E)
	self.A = self:Read( A16 )

	self.Cycle = 8
	self.PC = self.PC + 1
end

Operators[ 0x2A ] = function( self )

	self.A = self:Read( bor(lshift(self.H,8),self.L) )

	self.L = self.L + 1
	if self.L > 0xFF then
		self.L = band(self.L,0xFF)
		self.H = band((self.H + 1),0xFF)
	end

	self.Cycle = 8
	self.PC = self.PC + 1
end

Operators[ 0x3A ] = function( self )

	self.A = self:Read( bor(lshift(self.H,8),self.L) )

	self.L = self.L - 1
	if self.L < 0 then
		self.L = band(self.L,0xFF)
		self.H = band((self.H - 1),0xFF)
	end

	self.Cycle = 8
	self.PC = self.PC + 1
end



--- 8 Bit Arithmatic and Logic ---

-- ADD
Operators[ 0x80 ] = function( self ) self:ByteAdd(self.B) end
Operators[ 0x81 ] = function( self ) self:ByteAdd(self.C) end
Operators[ 0x82 ] = function( self ) self:ByteAdd(self.D) end
Operators[ 0x83 ] = function( self ) self:ByteAdd(self.E) end
Operators[ 0x84 ] = function( self ) self:ByteAdd(self.H) end
Operators[ 0x85 ] = function( self ) self:ByteAdd(self.L) end
Operators[ 0x86 ] = function( self ) self:ByteAdd( self:Read( bor(lshift(self.H,8),self.L)) ); self.Cycle = 8 end
Operators[ 0x87 ] = function( self ) self:ByteAdd(self.A) end

-- ADD with Carry (ADC)
Operators[ 0x88 ] = function( self ) self:ByteAdc(self.B) end
Operators[ 0x89 ] = function( self ) self:ByteAdc(self.C) end
Operators[ 0x8A ] = function( self ) self:ByteAdc(self.D) end
Operators[ 0x8B ] = function( self ) self:ByteAdc(self.E) end
Operators[ 0x8C ] = function( self ) self:ByteAdc(self.H) end
Operators[ 0x8D ] = function( self ) self:ByteAdc(self.L) end
Operators[ 0x8E ] = function( self ) self:ByteAdc( self:Read( bor(lshift(self.H,8),self.L) ) ); self.Cycle = 8 end
Operators[ 0x8F ] = function( self ) self:ByteAdc(self.A) end

-- SUB
Operators[ 0x90 ] = function( self ) self:ByteSub(self.B) end
Operators[ 0x91 ] = function( self ) self:ByteSub(self.C) end
Operators[ 0x92 ] = function( self ) self:ByteSub(self.D) end
Operators[ 0x93 ] = function( self ) self:ByteSub(self.E) end
Operators[ 0x94 ] = function( self ) self:ByteSub(self.H) end
Operators[ 0x95 ] = function( self ) self:ByteSub(self.L) end
Operators[ 0x96 ] = function( self ) self:ByteSub( self:Read( bor(lshift(self.H,8),self.L) ) ); self.Cycle = 8 end
Operators[ 0x97 ] = function( self ) self:ByteSub(self.A) end

-- SUB with Borrow (ABC)
Operators[ 0x98 ] = function( self ) self:ByteSbc(self.B) end
Operators[ 0x99 ] = function( self ) self:ByteSbc(self.C) end
Operators[ 0x9A ] = function( self ) self:ByteSbc(self.D) end
Operators[ 0x9B ] = function( self ) self:ByteSbc(self.E) end
Operators[ 0x9C ] = function( self ) self:ByteSbc(self.H) end
Operators[ 0x9D ] = function( self ) self:ByteSbc(self.L) end
Operators[ 0x9E ] = function( self ) self:ByteSbc( self:Read( bor(lshift(self.H,8),self.L) ) ); self.Cycle = 8 end
Operators[ 0x9F ] = function( self ) self:ByteSbc(self.A) end

-- AND
Operators[ 0xA0 ] = function( self ) self:ByteAnd(self.B) end
Operators[ 0xA1 ] = function( self ) self:ByteAnd(self.C) end
Operators[ 0xA2 ] = function( self ) self:ByteAnd(self.D) end
Operators[ 0xA3 ] = function( self ) self:ByteAnd(self.E) end
Operators[ 0xA4 ] = function( self ) self:ByteAnd(self.H) end
Operators[ 0xA5 ] = function( self ) self:ByteAnd(self.L) end
Operators[ 0xA6 ] = function( self ) self:ByteAnd( self:Read(bor(lshift(self.H,8),self.L)) ); self.Cycle = 8 end
Operators[ 0xA7 ] = function( self ) self:ByteAnd(self.A) end

-- XOR
Operators[ 0xA8 ] = function( self ) self:ByteXor(self.B) end
Operators[ 0xA9 ] = function( self ) self:ByteXor(self.C) end
Operators[ 0xAA ] = function( self ) self:ByteXor(self.D) end
Operators[ 0xAB ] = function( self ) self:ByteXor(self.E) end
Operators[ 0xAC ] = function( self ) self:ByteXor(self.H) end
Operators[ 0xAD ] = function( self ) self:ByteXor(self.L) end
Operators[ 0xAE ] = function( self ) self:ByteXor( self:Read(bor(lshift(self.H,8),self.L)) ); self.Cycle = 8 end
Operators[ 0xAF ] = function( self ) self:ByteXor(self.A) end

-- OR
Operators[ 0xB0 ] = function( self ) self:ByteOr(self.B) end
Operators[ 0xB1 ] = function( self ) self:ByteOr(self.C) end
Operators[ 0xB2 ] = function( self ) self:ByteOr(self.D) end
Operators[ 0xB3 ] = function( self ) self:ByteOr(self.E) end
Operators[ 0xB4 ] = function( self ) self:ByteOr(self.H) end
Operators[ 0xB5 ] = function( self ) self:ByteOr(self.L) end
Operators[ 0xB6 ] = function( self ) self:ByteOr( self:Read(bor(lshift(self.H,8),self.L)) ); self.Cycle = 8 end
Operators[ 0xB7 ] = function( self ) self:ByteOr(self.A) end

-- CMP
Operators[ 0xB8 ] = function( self ) self:ByteCmp(self.B) end
Operators[ 0xB9 ] = function( self ) self:ByteCmp(self.C) end
Operators[ 0xBA ] = function( self ) self:ByteCmp(self.D) end
Operators[ 0xBB ] = function( self ) self:ByteCmp(self.E) end
Operators[ 0xBC ] = function( self ) self:ByteCmp(self.H) end
Operators[ 0xBD ] = function( self ) self:ByteCmp(self.L) end
Operators[ 0xBE ] = function( self ) self:ByteCmp( self:Read(bor(lshift(self.H,8),self.L)) ); self.Cycle = 8 end
Operators[ 0xBF ] = function( self ) self:ByteCmp(self.A) end


-- All of the above but on immediate data
Operators[ 0xC6 ] = function( self ) self:ByteAdd( self:Read(self.PC+1) ); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0xD6 ] = function( self ) self:ByteSub( self:Read(self.PC+1) ); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0xE6 ] = function( self ) self:ByteAnd( self:Read(self.PC+1) ); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0xF6 ] = function( self ) self:ByteOr( self:Read(self.PC+1) ); self.Cycle = 8; self.PC = self.PC + 1 end

Operators[ 0xCE ] = function( self ) self:ByteAdc( self:Read(self.PC+1) ); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0xDE ] = function( self ) self:ByteSbc( self:Read(self.PC+1) ); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0xEE ] = function( self ) self:ByteXor( self:Read(self.PC+1) ); self.Cycle = 8; self.PC = self.PC + 1 end
Operators[ 0xFE ] = function( self ) self:ByteCmp( self:Read(self.PC+1) ); self.Cycle = 8; self.PC = self.PC + 1 end


-- Bitwise not on A
Operators[ 0x2F ] = function( self )
	self.A = 255-self.A
	
	self.Hf = true
	self.Nf = true
	
	self.PC = self.PC + 1
	self.Cycle = 4
end



-- Byte Incriment

Operators[ 0x04 ] = function( self ) self.B = self:ByteInc(self.B) end
Operators[ 0x0C ] = function( self ) self.C = self:ByteInc(self.C) end
Operators[ 0x14 ] = function( self ) self.D = self:ByteInc(self.D) end
Operators[ 0x1C ] = function( self ) self.E = self:ByteInc(self.E) end
Operators[ 0x24 ] = function( self ) self.H = self:ByteInc(self.H) end
Operators[ 0x2C ] = function( self ) self.L = self:ByteInc(self.L) end
Operators[ 0x34 ] = function( self )
	local R1 = self:Read(bor(lshift(self.H,8),self.L))
	local R1 = self:ByteInc(R1)
	self:Write( bor(lshift(self.H,8),self.L), R1 )
	
	self.Cycle = 12
end
Operators[ 0x3C ] = function( self ) self.A = self:ByteInc(self.A) end


-- Byte Decriment

Operators[ 0x05 ] = function( self ) self.B = self:ByteDec(self.B) end
Operators[ 0x0D ] = function( self ) self.C = self:ByteDec(self.C) end
Operators[ 0x15 ] = function( self ) self.D = self:ByteDec(self.D) end
Operators[ 0x1D ] = function( self ) self.E = self:ByteDec(self.E) end
Operators[ 0x25 ] = function( self ) self.H = self:ByteDec(self.H) end
Operators[ 0x2D ] = function( self ) self.L = self:ByteDec(self.L) end
Operators[ 0x35 ] = function( self )
	local R1 = self:Read(bor(lshift(self.H,8),self.L))
	local R1 = self:ByteDec(R1)
	self:Write( bor(lshift(self.H,8),self.L), R1 )
	
	self.Cycle = 12
end
Operators[ 0x3D ] = function( self ) self.A = self:ByteDec(self.A) end





-- STACK PUSH
Operators[ 0xC5 ] = function( self ) self:StackPush(self.B, self.C) end
Operators[ 0xD5 ] = function( self ) self:StackPush(self.D, self.E) end
Operators[ 0xE5 ] = function( self ) self:StackPush(self.H, self.L) end
Operators[ 0xF5 ] = function( self )
	self.F = 0
	if self.Cf then self.F = bor(self.F,16) end
	if self.Hf then self.F = bor(self.F,32) end
	if self.Nf then self.F = bor(self.F,64) end
	if self.Zf then self.F = bor(self.F,128) end
	
	self:StackPush(self.A, self.F)
end

-- STACK POP
Operators[ 0xC1 ] = function( self ) self.B, self.C = self:StackPop() end
Operators[ 0xD1 ] = function( self ) self.D, self.E = self:StackPop() end
Operators[ 0xE1 ] = function( self ) self.H, self.L = self:StackPop() end
Operators[ 0xF1 ] = function( self )
	self.A, self.F = self:StackPop()
	
	if band(self.F,16) == 16 then self.Cf = true else self.Cf = false end
	if band(self.F,32) == 32 then self.Hf = true else self.Hf = false end
	if band(self.F,64) == 64 then self.Nf = true else self.Nf = false end
	if band(self.F,128) == 128 then self.Zf = true else self.Zf = false end
end


-- 16 bit load immediate

Operators[ 0x01 ] = function( self ) 
	self.B = self:Read(self.PC + 2)
	self.C = self:Read(self.PC + 1)
	
	self.PC = self.PC + 3
	self.Cycle = 12
end

Operators[ 0x11 ] = function( self ) 
	self.D = self:Read(self.PC + 2)
	self.E = self:Read(self.PC + 1)
	
	self.PC = self.PC + 3
	self.Cycle = 12
end

Operators[ 0x21 ] = function( self ) 
	self.H = self:Read(self.PC + 2)
	self.L = self:Read(self.PC + 1)
	
	self.PC = self.PC + 3
	self.Cycle = 12
end

Operators[ 0x31 ] = function( self ) 
	self.SP = bor(( lshift(self:Read( self.PC + 2 ),8) ),self:Read(self.PC + 1))
	
	self.PC = self.PC + 3
	self.Cycle = 12
end


-- Save SP at 16 bit immeiate address
Operators[ 0x08 ] = function( self ) 

	local A16 = bor(( lshift(self:Read( self.PC + 2 ),8) ),self:Read(self.PC + 1))
	local SPhi = rshift(band(self.SP,0xFF00),8)
	local SPlo = band( self.SP,0xFF )
	
	self:Write(A16,SPlo)
	self:Write(A16+1,SPhi)
	
	self.Cycle = 20
	self.PC = self.PC + 3
end

-- Load SP + signed immediate into HL
Operators[ 0xF8 ] = function( self ) 
	local D8 = self:Read(self.PC+1)
	local S8 = (band(D8,127)-band(D8,128))
	local SP = self.SP + S8 
	
	if S8 >= 0 then
		self.Cf = ( band(self.SP,0xFF) + ( S8 ) ) > 0xFF
		self.Hf = ( band(self.SP,0xF) + band( S8,0xF ) ) > 0xF
	else
		self.Cf = band(SP, 0xFF) <= band(self.SP, 0xFF)
		self.Hf = band(SP,0xF) <= band(self.SP,0xF)
	end

	self.Zf = false
	self.Nf = false
	
	self.H = rshift(band(SP,0xFF00),8)
	self.L = band(SP,0xFF)
	
	self.Cycle = 12
	self.PC = self.PC + 2
end

-- Load HL into SP
Operators[ 0xF9 ] = function( self ) 
	self.SP = bor(lshift(self.H,8),self.L)
	
	self.Cycle = 8
	self.PC = self.PC + 1
end


-- Carry Operations
Operators[ 0x37 ] = function( self ) 
	self.Cf = true
	self.Hf = false
	self.Nf = false
	
	self.PC = self.PC + 1
	self.Cycle = 4
end

Operators[ 0x3F ] = function( self ) 

	self.Cf = not self.Cf
	self.Hf = false
	self.Nf = false
	
	self.PC = self.PC + 1
	self.Cycle = 4
end

-- DAA, this one is a bitch, I copied this from some other guys source code and that guy copied it too, credit to codeslinger.
Operators[ 0x27 ] = function( self ) 


	if self.Nf then
		if band(self.A,0x0F) > 9 or self.Hf then
			self.A = (self.A - 6)
			
			if band(self.A,0xF0) == 0xF0 then self.Cf = true end
		end
		
		if band(self.A,0xF0) > 0x90 or self.Cf then self.A = (self.A - 0x60); self.Cf = true end

	else
		if band(self.A,0xF) > 9 or self.Hf then
			self.A = (self.A + 0x06)
		end
		
		if band(self.A,0xF0) > 0x90 or self.Cf then self.A = (self.A + 0x60); self.Cf = true end
	end

	--self.Cf = self.A > 0xFF

	self.A = band(self.A,0xFF)

	self.Zf = self.A == 0
	self.Hf = false	


	
	self.PC = self.PC + 1
	self.Cycle = 4
end


--- ROTATES

Operators[ 0x17 ] = function( self ) 
	local Bit7 = band(self.A,128) == 128
	
	self.A = bor(band(lshift(self.A,1),0xFF),(self.Cf and 1 or 0))

	self.Cf = Bit7
	self.Zf = false
	self.Nf = false
	self.Hf = false

	self.PC = self.PC + 1
	self.Cycle = 4

end

Operators[ 0x1F ] = function( self )
	local Bit0 = band(self.A,1) == 1

	self.A = bor(band(rshift(self.A,1),0xFF),(self.Cf and 128 or 0))

	self.Cf = Bit0
	self.Zf = false
	self.Nf = false
	self.Hf = false

	self.PC = self.PC + 1
	self.Cycle = 4
end

Operators[ 0x07 ] = function( self )
	local Bit7 = band(self.A,128) == 128

	self.A = bor(band(lshift(self.A,1),0xFF),(Bit7 and 1 or 0))

	self.Cf = Bit7
	self.Zf = false
	self.Nf = false
	self.Hf = false

	self.PC = self.PC + 1
	self.Cycle = 4
end

Operators[ 0x0F ] = function( self )
	local Bit0 = band(self.A,1) == 1

	self.A = bor(band(rshift(self.A,1),0xFF),(Bit0 and 128 or 0))

	self.Cf = Bit0
	self.Zf = false
	self.Nf = false
	self.Hf = false

	self.PC = self.PC + 1
	self.Cycle = 4
end


