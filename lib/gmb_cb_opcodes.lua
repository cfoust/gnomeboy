local self = GnomeBoyAdvance
local gem = GBAgem
local mt = gem.GBZ80

mt.OperatorsCB = {}
local OperatorsCB = mt.OperatorsCB

local band = bit.band;
local bor = bit.bor;
local rshift = bit.rshift;
local lshift = bit.lshift;

--- BIT FUNCTIONS ---
function mt:SetBit(R1,N)
	local Bit = lshift(1,N)
	R1 = bor(R1,Bit)
	
	self.PC = self.PC + 2
	self.Cycle = 8
	return R1
end

function mt:RstBit(R1,N)

	local Bit = lshift(1,N)
	R1 = band(R1,(255-Bit))
	
	self.PC = self.PC + 2
	self.Cycle = 8
	return R1
end

function mt:TstBit(R1,N)
	local Bit = lshift(1,N)
	local test = band(R1,Bit)
	
	self.Nf = false
	self.Hf = true
	self.Zf = test == 0
	
	self.PC = self.PC + 2
	self.Cycle = 8
end

function mt:RotateLeftCarry(R1)
	local Bit7 = band(R1,128) == 128
	
	R1 = bor(band((lshift(R1,1)),0xFE),(Bit7 and 1 or 0))
	self.Cf = Bit7
	self.Zf = R1 == 0
	self.Nf = false
	self.Hf = false
	
	self.PC = self.PC + 2
	self.Cycle = 8
	
	return R1
end

function mt:RotateRightCarry(R1)
	local Bit0 = band(R1,1) == 1
	
	R1 = bor(band(rshift(R1,1),0xFF),(Bit0 and 128 or 0))

	self.Cf = Bit0
	self.Zf = R1 == 0
	self.Nf = false
	self.Hf = false
	
	self.PC = self.PC + 2
	self.Cycle = 8
	
	return R1
end

function mt:RotateLeft(R1)
	local Bit7 = band(R1,128) == 128

	R1 = bor(band((lshift(R1,1)),0xFE),(self.Cf and 1 or 0))

	self.Cf = Bit7
	self.Zf = R1 == 0

	self.Nf = false
	self.Hf = false

	self.PC = self.PC + 2
	self.Cycle = 8

	return R1
	
end

function mt:RotateRight(R1)
	local Bit0 = band(R1,1) == 1
	
	R1 = bor(band(rshift(R1,1),0xFF),(self.Cf and 128 or 0))
	
	self.Nf = false
	self.Hf = false
	
	self.Cf = Bit0
	self.Zf = R1 == 0
	
	self.PC = self.PC + 2
	self.Cycle = 8
	
	return R1
end

function mt:ArithmaticShiftLeft(R1)

	local Bit7 = band(R1,128) == 128

	R1 = band((lshift(R1,1)),0xFE) --- 0xFE for a reason, this is arithmatic shift.

	self.Cf = Bit7
	self.Zf = R1 == 0
	self.Hf = false
	self.Nf = false

	self.PC = self.PC + 2
	self.Cycle = 8

	return R1
end

function mt:ArithmaticShiftRight(R1)

	local Bit7 = band(R1,128) == 128
	local Bit0 = band(R1,1)   == 1

	R1 = bor(band(rshift(R1,1),0xFF ),(Bit7 and 128 or 0))

	self.Cf = Bit0
	self.Zf = R1 == 0
	self.Hf = false
	self.Nf = false

	self.PC = self.PC + 2
	self.Cycle = 8

	return R1
end

function mt:ShiftRight(R1)

	local Bit0 = band(R1,1) == 1

	R1 = band(rshift(R1,1),0xFF)

	self.Cf = Bit0
	self.Zf = R1 == 0
	self.Hf = false
	self.Nf = false

	self.Cycle = 8
	self.PC = self.PC + 2

	return R1
end

function mt:Swap(R1)

	R1 = bor(rshift(band(R1,0xF0),4),lshift(band(R1,0x0F),4)) 

	self.Zf = R1 == 0
	self.Cf = false
	self.Hf = false
	self.Nf = false

	self.Cycle = 8
	self.PC = self.PC + 2

	return R1
end



	


----------------------------------------------------------------------------------------------------------
-- CB CB CB -- CB CB CB -- CB CB CB -- CB CB CB -- CB CB CB -- CB CB CB -- CB CB CB -- CB CB CB --
 
--Operators[ 0xBE ] = function( self ) self:ByteCmp( self:Read(bor(lshift(self.H,8),self.L)) ); self.Cycle = 8 end


-- Rotate Left with Carry
OperatorsCB[ 0x00 ] = function( self ) self.B = self:RotateLeftCarry( self.B ) end
OperatorsCB[ 0x01 ] = function( self ) self.C = self:RotateLeftCarry( self.C ) end
OperatorsCB[ 0x02 ] = function( self ) self.D = self:RotateLeftCarry( self.D ) end
OperatorsCB[ 0x03 ] = function( self ) self.E = self:RotateLeftCarry( self.E ) end
OperatorsCB[ 0x04 ] = function( self ) self.H = self:RotateLeftCarry( self.H ) end
OperatorsCB[ 0x05 ] = function( self ) self.L = self:RotateLeftCarry( self.L ) end
OperatorsCB[ 0x06 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RotateLeftCarry( self:Read(bor(lshift(self.H,8),self.L)) ) ); self.Cycle = 16 end
OperatorsCB[ 0x07 ] = function( self ) self.A = self:RotateLeftCarry( self.A ) end

-- Rotate Right with Carry
OperatorsCB[ 0x08 ] = function( self ) self.B = self:RotateRightCarry( self.B ) end
OperatorsCB[ 0x09 ] = function( self ) self.C = self:RotateRightCarry( self.C ) end
OperatorsCB[ 0x0A ] = function( self ) self.D = self:RotateRightCarry( self.D ) end
OperatorsCB[ 0x0B ] = function( self ) self.E = self:RotateRightCarry( self.E ) end
OperatorsCB[ 0x0C ] = function( self ) self.H = self:RotateRightCarry( self.H ) end
OperatorsCB[ 0x0D ] = function( self ) self.L = self:RotateRightCarry( self.L ) end
OperatorsCB[ 0x0E ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RotateRightCarry( self:Read(bor(lshift(self.H,8),self.L)) ) ); self.Cycle = 16 end
OperatorsCB[ 0x0F ] = function( self ) self.A = self:RotateRightCarry( self.A ) end

-- Rotate Left
OperatorsCB[ 0x10 ] = function( self ) self.B = self:RotateLeft( self.B ) end
OperatorsCB[ 0x11 ] = function( self ) self.C = self:RotateLeft( self.C ) end
OperatorsCB[ 0x12 ] = function( self ) self.D = self:RotateLeft( self.D ) end
OperatorsCB[ 0x13 ] = function( self ) self.E = self:RotateLeft( self.E ) end
OperatorsCB[ 0x14 ] = function( self ) self.H = self:RotateLeft( self.H ) end
OperatorsCB[ 0x15 ] = function( self ) self.L = self:RotateLeft( self.L ) end
OperatorsCB[ 0x16 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RotateLeft( self:Read(bor(lshift(self.H,8),self.L)) ) ); self.Cycle = 16 end
OperatorsCB[ 0x17 ] = function( self ) self.A = self:RotateLeft( self.A ) end

-- Rotate Right
OperatorsCB[ 0x18 ] = function( self ) self.B = self:RotateRight( self.B ) end
OperatorsCB[ 0x19 ] = function( self ) self.C = self:RotateRight( self.C ) end
OperatorsCB[ 0x1A ] = function( self ) self.D = self:RotateRight( self.D ) end
OperatorsCB[ 0x1B ] = function( self ) self.E = self:RotateRight( self.E ) end
OperatorsCB[ 0x1C ] = function( self ) self.H = self:RotateRight( self.H ) end
OperatorsCB[ 0x1D ] = function( self ) self.L = self:RotateRight( self.L ) end
OperatorsCB[ 0x1E ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RotateRight( self:Read(bor(lshift(self.H,8),self.L)) ) ); self.Cycle = 16 end
OperatorsCB[ 0x1F ] = function( self ) self.A = self:RotateRight( self.A ) end

--Arithmatic Shift Left
OperatorsCB[ 0x20 ] = function( self ) self.B = self:ArithmaticShiftLeft( self.B ) end
OperatorsCB[ 0x21 ] = function( self ) self.C = self:ArithmaticShiftLeft( self.C ) end
OperatorsCB[ 0x22 ] = function( self ) self.D = self:ArithmaticShiftLeft( self.D ) end
OperatorsCB[ 0x23 ] = function( self ) self.E = self:ArithmaticShiftLeft( self.E ) end
OperatorsCB[ 0x24 ] = function( self ) self.H = self:ArithmaticShiftLeft( self.H ) end
OperatorsCB[ 0x25 ] = function( self ) self.L = self:ArithmaticShiftLeft( self.L ) end
OperatorsCB[ 0x26 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:ArithmaticShiftLeft( self:Read(bor(lshift(self.H,8),self.L)) ) ); self.Cycle = 16 end
OperatorsCB[ 0x27 ] = function( self ) self.A = self:ArithmaticShiftLeft( self.A ) end

--Arithmatic Shift Right
OperatorsCB[ 0x28 ] = function( self ) self.B = self:ArithmaticShiftRight( self.B ) end
OperatorsCB[ 0x29 ] = function( self ) self.C = self:ArithmaticShiftRight( self.C ) end
OperatorsCB[ 0x2A ] = function( self ) self.D = self:ArithmaticShiftRight( self.D ) end
OperatorsCB[ 0x2B ] = function( self ) self.E = self:ArithmaticShiftRight( self.E ) end
OperatorsCB[ 0x2C ] = function( self ) self.H = self:ArithmaticShiftRight( self.H ) end
OperatorsCB[ 0x2D ] = function( self ) self.L = self:ArithmaticShiftRight( self.L ) end
OperatorsCB[ 0x2E ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:ArithmaticShiftRight( self:Read(bor(lshift(self.H,8),self.L)) ) ); self.Cycle = 16 end
OperatorsCB[ 0x2F ] = function( self ) self.A = self:ArithmaticShiftRight( self.A ) end

--Swap
OperatorsCB[ 0x30 ] = function( self ) self.B = self:Swap( self.B ) end
OperatorsCB[ 0x31 ] = function( self ) self.C = self:Swap( self.C ) end
OperatorsCB[ 0x32 ] = function( self ) self.D = self:Swap( self.D ) end
OperatorsCB[ 0x33 ] = function( self ) self.E = self:Swap( self.E ) end
OperatorsCB[ 0x34 ] = function( self ) self.H = self:Swap( self.H ) end
OperatorsCB[ 0x35 ] = function( self ) self.L = self:Swap( self.L ) end
OperatorsCB[ 0x36 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:Swap( self:Read(bor(lshift(self.H,8),self.L)) ) ); self.Cycle = 16 end
OperatorsCB[ 0x37 ] = function( self ) self.A = self:Swap( self.A ) end

--ShiftRight
OperatorsCB[ 0x38 ] = function( self ) self.B = self:ShiftRight( self.B ) end
OperatorsCB[ 0x39 ] = function( self ) self.C = self:ShiftRight( self.C ) end
OperatorsCB[ 0x3A ] = function( self ) self.D = self:ShiftRight( self.D ) end
OperatorsCB[ 0x3B ] = function( self ) self.E = self:ShiftRight( self.E ) end
OperatorsCB[ 0x3C ] = function( self ) self.H = self:ShiftRight( self.H ) end
OperatorsCB[ 0x3D ] = function( self ) self.L = self:ShiftRight( self.L ) end
OperatorsCB[ 0x3E ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:ShiftRight( self:Read(bor(lshift(self.H,8),self.L)) ) ); self.Cycle = 16 end
OperatorsCB[ 0x3F ] = function( self ) self.A = self:ShiftRight( self.A ) end







-- TEST BIT aka BIT
OperatorsCB[ 0x40 ] = function( self ) self:TstBit( self.B ,0 ) end
OperatorsCB[ 0x41 ] = function( self ) self:TstBit( self.C ,0 ) end
OperatorsCB[ 0x42 ] = function( self ) self:TstBit( self.D ,0 ) end
OperatorsCB[ 0x43 ] = function( self ) self:TstBit( self.E ,0 ) end
OperatorsCB[ 0x44 ] = function( self ) self:TstBit( self.H ,0 ) end
OperatorsCB[ 0x45 ] = function( self ) self:TstBit( self.L ,0 ) end
OperatorsCB[ 0x46 ] = function( self ) self:TstBit( self:Read(bor(lshift(self.H,8),self.L)) ,0 ); self.Cycle = 16 end
OperatorsCB[ 0x47 ] = function( self ) self:TstBit( self.A ,0 ) end

OperatorsCB[ 0x48 ] = function( self ) self:TstBit( self.B ,1 ) end
OperatorsCB[ 0x49 ] = function( self ) self:TstBit( self.C ,1 ) end
OperatorsCB[ 0x4A ] = function( self ) self:TstBit( self.D ,1 ) end
OperatorsCB[ 0x4B ] = function( self ) self:TstBit( self.E ,1 ) end
OperatorsCB[ 0x4C ] = function( self ) self:TstBit( self.H ,1 ) end
OperatorsCB[ 0x4D ] = function( self ) self:TstBit( self.L ,1 ) end
OperatorsCB[ 0x4E ] = function( self ) self:TstBit( self:Read(bor(lshift(self.H,8),self.L)) ,1 ); self.Cycle = 16 end
OperatorsCB[ 0x4F ] = function( self ) self:TstBit( self.A ,1 ) end

OperatorsCB[ 0x50 ] = function( self ) self:TstBit( self.B ,2 ) end
OperatorsCB[ 0x51 ] = function( self ) self:TstBit( self.C ,2 ) end
OperatorsCB[ 0x52 ] = function( self ) self:TstBit( self.D ,2 ) end
OperatorsCB[ 0x53 ] = function( self ) self:TstBit( self.E ,2 ) end
OperatorsCB[ 0x54 ] = function( self ) self:TstBit( self.H ,2 ) end
OperatorsCB[ 0x55 ] = function( self ) self:TstBit( self.L ,2 ) end
OperatorsCB[ 0x56 ] = function( self ) self:TstBit( self:Read(bor(lshift(self.H,8),self.L)) ,2 ); self.Cycle = 16 end
OperatorsCB[ 0x57 ] = function( self ) self:TstBit( self.A ,2 ) end

OperatorsCB[ 0x58 ] = function( self ) self:TstBit( self.B ,3 ) end
OperatorsCB[ 0x59 ] = function( self ) self:TstBit( self.C ,3 ) end
OperatorsCB[ 0x5A ] = function( self ) self:TstBit( self.D ,3 ) end
OperatorsCB[ 0x5B ] = function( self ) self:TstBit( self.E ,3 ) end
OperatorsCB[ 0x5C ] = function( self ) self:TstBit( self.H ,3 ) end
OperatorsCB[ 0x5D ] = function( self ) self:TstBit( self.L ,3 ) end
OperatorsCB[ 0x5E ] = function( self ) self:TstBit( self:Read(bor(lshift(self.H,8),self.L)) ,3 ); self.Cycle = 16 end
OperatorsCB[ 0x5F ] = function( self ) self:TstBit( self.A ,3 ) end

OperatorsCB[ 0x60 ] = function( self ) self:TstBit( self.B ,4 ) end
OperatorsCB[ 0x61 ] = function( self ) self:TstBit( self.C ,4 ) end
OperatorsCB[ 0x62 ] = function( self ) self:TstBit( self.D ,4 ) end
OperatorsCB[ 0x63 ] = function( self ) self:TstBit( self.E ,4 ) end
OperatorsCB[ 0x64 ] = function( self ) self:TstBit( self.H ,4 ) end
OperatorsCB[ 0x65 ] = function( self ) self:TstBit( self.L ,4 ) end
OperatorsCB[ 0x66 ] = function( self ) self:TstBit( self:Read(bor(lshift(self.H,8),self.L)) ,4 ); self.Cycle = 16 end
OperatorsCB[ 0x67 ] = function( self ) self:TstBit( self.A ,4 ) end

OperatorsCB[ 0x68 ] = function( self ) self:TstBit( self.B ,5 ) end
OperatorsCB[ 0x69 ] = function( self ) self:TstBit( self.C ,5 ) end
OperatorsCB[ 0x6A ] = function( self ) self:TstBit( self.D ,5 ) end
OperatorsCB[ 0x6B ] = function( self ) self:TstBit( self.E ,5 ) end
OperatorsCB[ 0x6C ] = function( self ) self:TstBit( self.H ,5 ) end
OperatorsCB[ 0x6D ] = function( self ) self:TstBit( self.L ,5 ) end
OperatorsCB[ 0x6E ] = function( self ) self:TstBit( self:Read(bor(lshift(self.H,8),self.L)) ,5 ); self.Cycle = 16 end
OperatorsCB[ 0x6F ] = function( self ) self:TstBit( self.A ,5 ) end

OperatorsCB[ 0x70 ] = function( self ) self:TstBit( self.B ,6 ) end
OperatorsCB[ 0x71 ] = function( self ) self:TstBit( self.C ,6 ) end
OperatorsCB[ 0x72 ] = function( self ) self:TstBit( self.D ,6 ) end
OperatorsCB[ 0x73 ] = function( self ) self:TstBit( self.E ,6 ) end
OperatorsCB[ 0x74 ] = function( self ) self:TstBit( self.H ,6 ) end
OperatorsCB[ 0x75 ] = function( self ) self:TstBit( self.L ,6 ) end
OperatorsCB[ 0x76 ] = function( self ) self:TstBit( self:Read(bor(lshift(self.H,8),self.L)) ,6 ); self.Cycle = 16 end
OperatorsCB[ 0x77 ] = function( self ) self:TstBit( self.A ,6 ) end

OperatorsCB[ 0x78 ] = function( self ) self:TstBit( self.B ,7 ) end
OperatorsCB[ 0x79 ] = function( self ) self:TstBit( self.C ,7 ) end
OperatorsCB[ 0x7A ] = function( self ) self:TstBit( self.D ,7 ) end
OperatorsCB[ 0x7B ] = function( self ) self:TstBit( self.E ,7 ) end
OperatorsCB[ 0x7C ] = function( self ) self:TstBit( self.H ,7 ) end
OperatorsCB[ 0x7D ] = function( self ) self:TstBit( self.L ,7 ) end
OperatorsCB[ 0x7E ] = function( self ) self:TstBit( self:Read(bor(lshift(self.H,8),self.L)) ,7 ); self.Cycle = 16 end
OperatorsCB[ 0x7F ] = function( self ) self:TstBit( self.A ,7 ) end


------ RESET

OperatorsCB[ 0x80 ] = function( self ) self.B = self:RstBit( self.B ,0 ) end
OperatorsCB[ 0x81 ] = function( self ) self.C = self:RstBit( self.C ,0 ) end
OperatorsCB[ 0x82 ] = function( self ) self.D = self:RstBit( self.D ,0 ) end
OperatorsCB[ 0x83 ] = function( self ) self.E = self:RstBit( self.E ,0 ) end
OperatorsCB[ 0x84 ] = function( self ) self.H = self:RstBit( self.H ,0 ) end
OperatorsCB[ 0x85 ] = function( self ) self.L = self:RstBit( self.L ,0 ) end
OperatorsCB[ 0x86 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RstBit( self:Read(bor(lshift(self.H,8),self.L))  ,0 )); self.Cycle = 16 end
OperatorsCB[ 0x87 ] = function( self ) self.A = self:RstBit( self.A ,0 ) end

OperatorsCB[ 0x88 ] = function( self ) self.B = self:RstBit( self.B ,1 ) end
OperatorsCB[ 0x89 ] = function( self ) self.C = self:RstBit( self.C ,1 ) end
OperatorsCB[ 0x8A ] = function( self ) self.D = self:RstBit( self.D ,1 ) end
OperatorsCB[ 0x8B ] = function( self ) self.E = self:RstBit( self.E ,1 ) end
OperatorsCB[ 0x8C ] = function( self ) self.H = self:RstBit( self.H ,1 ) end
OperatorsCB[ 0x8D ] = function( self ) self.L = self:RstBit( self.L ,1 ) end
OperatorsCB[ 0x8E ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RstBit( self:Read(bor(lshift(self.H,8),self.L)) ,1 )); self.Cycle = 16 end
OperatorsCB[ 0x8F ] = function( self ) self.A = self:RstBit( self.A ,1 ) end

OperatorsCB[ 0x90 ] = function( self ) self.B = self:RstBit( self.B ,2 ) end
OperatorsCB[ 0x91 ] = function( self ) self.C = self:RstBit( self.C ,2 ) end
OperatorsCB[ 0x92 ] = function( self ) self.D = self:RstBit( self.D ,2 ) end
OperatorsCB[ 0x93 ] = function( self ) self.E = self:RstBit( self.E ,2 ) end
OperatorsCB[ 0x94 ] = function( self ) self.H = self:RstBit( self.H ,2 ) end
OperatorsCB[ 0x95 ] = function( self ) self.L = self:RstBit( self.L ,2 ) end
OperatorsCB[ 0x96 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RstBit( self:Read(bor(lshift(self.H,8),self.L)) ,2 )); self.Cycle = 16 end
OperatorsCB[ 0x97 ] = function( self ) self.A = self:RstBit( self.A ,2 ) end

OperatorsCB[ 0x98 ] = function( self ) self.B = self:RstBit( self.B ,3 ) end
OperatorsCB[ 0x99 ] = function( self ) self.C = self:RstBit( self.C ,3 ) end
OperatorsCB[ 0x9A ] = function( self ) self.D = self:RstBit( self.D ,3 ) end
OperatorsCB[ 0x9B ] = function( self ) self.E = self:RstBit( self.E ,3 ) end
OperatorsCB[ 0x9C ] = function( self ) self.H = self:RstBit( self.H ,3 ) end
OperatorsCB[ 0x9D ] = function( self ) self.L = self:RstBit( self.L ,3 ) end
OperatorsCB[ 0x9E ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RstBit( self:Read(bor(lshift(self.H,8),self.L)) ,3 )); self.Cycle = 16 end
OperatorsCB[ 0x9F ] = function( self ) self.A = self:RstBit( self.A ,3 ) end

OperatorsCB[ 0xA0 ] = function( self ) self.B = self:RstBit( self.B ,4 ) end
OperatorsCB[ 0xA1 ] = function( self ) self.C = self:RstBit( self.C ,4 ) end
OperatorsCB[ 0xA2 ] = function( self ) self.D = self:RstBit( self.D ,4 ) end
OperatorsCB[ 0xA3 ] = function( self ) self.E = self:RstBit( self.E ,4 ) end
OperatorsCB[ 0xA4 ] = function( self ) self.H = self:RstBit( self.H ,4 ) end
OperatorsCB[ 0xA5 ] = function( self ) self.L = self:RstBit( self.L ,4 ) end
OperatorsCB[ 0xA6 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RstBit( self:Read(bor(lshift(self.H,8),self.L)) ,4 )); self.Cycle = 16 end
OperatorsCB[ 0xA7 ] = function( self ) self.A = self:RstBit( self.A ,4 ) end

OperatorsCB[ 0xA8 ] = function( self ) self.B = self:RstBit( self.B ,5 ) end
OperatorsCB[ 0xA9 ] = function( self ) self.C = self:RstBit( self.C ,5 ) end
OperatorsCB[ 0xAA ] = function( self ) self.D = self:RstBit( self.D ,5 ) end
OperatorsCB[ 0xAB ] = function( self ) self.E = self:RstBit( self.E ,5 ) end
OperatorsCB[ 0xAC ] = function( self ) self.H = self:RstBit( self.H ,5 ) end
OperatorsCB[ 0xAD ] = function( self ) self.L = self:RstBit( self.L ,5 ) end
OperatorsCB[ 0xAE ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RstBit( self:Read(bor(lshift(self.H,8),self.L)) ,5 )); self.Cycle = 16 end
OperatorsCB[ 0xAF ] = function( self ) self.A = self:RstBit( self.A ,5 ) end

OperatorsCB[ 0xB0 ] = function( self ) self.B = self:RstBit( self.B ,6 ) end
OperatorsCB[ 0xB1 ] = function( self ) self.C = self:RstBit( self.C ,6 ) end
OperatorsCB[ 0xB2 ] = function( self ) self.D = self:RstBit( self.D ,6 ) end
OperatorsCB[ 0xB3 ] = function( self ) self.E = self:RstBit( self.E ,6 ) end
OperatorsCB[ 0xB4 ] = function( self ) self.H = self:RstBit( self.H ,6 ) end
OperatorsCB[ 0xB5 ] = function( self ) self.L = self:RstBit( self.L ,6 ) end
OperatorsCB[ 0xB6 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RstBit( self:Read(bor(lshift(self.H,8),self.L)) ,6 )); self.Cycle = 16 end
OperatorsCB[ 0xB7 ] = function( self ) self.A = self:RstBit( self.A ,6 ) end

OperatorsCB[ 0xB8 ] = function( self ) self.B = self:RstBit( self.B ,7 ) end
OperatorsCB[ 0xB9 ] = function( self ) self.C = self:RstBit( self.C ,7 ) end
OperatorsCB[ 0xBA ] = function( self ) self.D = self:RstBit( self.D ,7 ) end
OperatorsCB[ 0xBB ] = function( self ) self.E = self:RstBit( self.E ,7 ) end
OperatorsCB[ 0xBC ] = function( self ) self.H = self:RstBit( self.H ,7 ) end
OperatorsCB[ 0xBD ] = function( self ) self.L = self:RstBit( self.L ,7 ) end
OperatorsCB[ 0xBE ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:RstBit( self:Read(bor(lshift(self.H,8),self.L)) ,7 )); self.Cycle = 16 end
OperatorsCB[ 0xBF ] = function( self ) self.A = self:RstBit( self.A ,7 ) end


--- SET BIT



OperatorsCB[ 0xC0 ] = function( self ) self.B = self:SetBit( self.B ,0 ) end
OperatorsCB[ 0xC1 ] = function( self ) self.C = self:SetBit( self.C ,0 ) end
OperatorsCB[ 0xC2 ] = function( self ) self.D = self:SetBit( self.D ,0 ) end
OperatorsCB[ 0xC3 ] = function( self ) self.E = self:SetBit( self.E ,0 ) end
OperatorsCB[ 0xC4 ] = function( self ) self.H = self:SetBit( self.H ,0 ) end
OperatorsCB[ 0xC5 ] = function( self ) self.L = self:SetBit( self.L ,0 ) end
OperatorsCB[ 0xC6 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:SetBit( self:Read(bor(lshift(self.H,8),self.L)) ,0 )); self.Cycle = 16 end
OperatorsCB[ 0xC7 ] = function( self ) self.A = self:SetBit( self.A ,0 ) end

OperatorsCB[ 0xC8 ] = function( self ) self.B = self:SetBit( self.B ,1 ) end
OperatorsCB[ 0xC9 ] = function( self ) self.C = self:SetBit( self.C ,1 ) end
OperatorsCB[ 0xCA ] = function( self ) self.D = self:SetBit( self.D ,1 ) end
OperatorsCB[ 0xCB ] = function( self ) self.E = self:SetBit( self.E ,1 ) end
OperatorsCB[ 0xCC ] = function( self ) self.H = self:SetBit( self.H ,1 ) end
OperatorsCB[ 0xCD ] = function( self ) self.L = self:SetBit( self.L ,1 ) end
OperatorsCB[ 0xCE ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:SetBit( self:Read(bor(lshift(self.H,8),self.L)) ,1 )); self.Cycle = 16 end
OperatorsCB[ 0xCF ] = function( self ) self.A = self:SetBit( self.A ,1 ) end

OperatorsCB[ 0xD0 ] = function( self ) self.B = self:SetBit( self.B ,2 ) end
OperatorsCB[ 0xD1 ] = function( self ) self.C = self:SetBit( self.C ,2 ) end
OperatorsCB[ 0xD2 ] = function( self ) self.D = self:SetBit( self.D ,2 ) end
OperatorsCB[ 0xD3 ] = function( self ) self.E = self:SetBit( self.E ,2 ) end
OperatorsCB[ 0xD4 ] = function( self ) self.H = self:SetBit( self.H ,2 ) end
OperatorsCB[ 0xD5 ] = function( self ) self.L = self:SetBit( self.L ,2 ) end
OperatorsCB[ 0xD6 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:SetBit( self:Read(bor(lshift(self.H,8),self.L)) ,2 )); self.Cycle = 16 end
OperatorsCB[ 0xD7 ] = function( self ) self.A = self:SetBit( self.A ,2 ) end

OperatorsCB[ 0xD8 ] = function( self ) self.B = self:SetBit( self.B ,3 ) end
OperatorsCB[ 0xD9 ] = function( self ) self.C = self:SetBit( self.C ,3 ) end
OperatorsCB[ 0xDA ] = function( self ) self.D = self:SetBit( self.D ,3 ) end
OperatorsCB[ 0xDB ] = function( self ) self.E = self:SetBit( self.E ,3 ) end
OperatorsCB[ 0xDC ] = function( self ) self.H = self:SetBit( self.H ,3 ) end
OperatorsCB[ 0xDD ] = function( self ) self.L = self:SetBit( self.L ,3 ) end
OperatorsCB[ 0xDE ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:SetBit( self:Read(bor(lshift(self.H,8),self.L)) ,3 )); self.Cycle = 16 end
OperatorsCB[ 0xDF ] = function( self ) self.A = self:SetBit( self.A ,3 ) end

OperatorsCB[ 0xE0 ] = function( self ) self.B = self:SetBit( self.B ,4 ) end
OperatorsCB[ 0xE1 ] = function( self ) self.C = self:SetBit( self.C ,4 ) end
OperatorsCB[ 0xE2 ] = function( self ) self.D = self:SetBit( self.D ,4 ) end
OperatorsCB[ 0xE3 ] = function( self ) self.E = self:SetBit( self.E ,4 ) end
OperatorsCB[ 0xE4 ] = function( self ) self.H = self:SetBit( self.H ,4 ) end
OperatorsCB[ 0xE5 ] = function( self ) self.L = self:SetBit( self.L ,4 ) end
OperatorsCB[ 0xE6 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:SetBit( self:Read(bor(lshift(self.H,8),self.L)) ,4 )); self.Cycle = 16 end
OperatorsCB[ 0xE7 ] = function( self ) self.A = self:SetBit( self.A ,4 ) end

OperatorsCB[ 0xE8 ] = function( self ) self.B = self:SetBit( self.B ,5 ) end
OperatorsCB[ 0xE9 ] = function( self ) self.C = self:SetBit( self.C ,5 ) end
OperatorsCB[ 0xEA ] = function( self ) self.D = self:SetBit( self.D ,5 ) end
OperatorsCB[ 0xEB ] = function( self ) self.E = self:SetBit( self.E ,5 ) end
OperatorsCB[ 0xEC ] = function( self ) self.H = self:SetBit( self.H ,5 ) end
OperatorsCB[ 0xED ] = function( self ) self.L = self:SetBit( self.L ,5 ) end
OperatorsCB[ 0xEE ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:SetBit( self:Read(bor(lshift(self.H,8),self.L)) ,5 )); self.Cycle = 16 end
OperatorsCB[ 0xEF ] = function( self ) self.A = self:SetBit( self.A ,5 ) end

OperatorsCB[ 0xF0 ] = function( self ) self.B = self:SetBit( self.B ,6 ) end
OperatorsCB[ 0xF1 ] = function( self ) self.C = self:SetBit( self.C ,6 ) end
OperatorsCB[ 0xF2 ] = function( self ) self.D = self:SetBit( self.D ,6 ) end
OperatorsCB[ 0xF3 ] = function( self ) self.E = self:SetBit( self.E ,6 ) end
OperatorsCB[ 0xF4 ] = function( self ) self.H = self:SetBit( self.H ,6 ) end
OperatorsCB[ 0xF5 ] = function( self ) self.L = self:SetBit( self.L ,6 ) end
OperatorsCB[ 0xF6 ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:SetBit( self:Read(bor(lshift(self.H,8),self.L)) ,6 )); self.Cycle = 16 end
OperatorsCB[ 0xF7 ] = function( self ) self.A = self:SetBit( self.A ,6 ) end

OperatorsCB[ 0xF8 ] = function( self ) self.B = self:SetBit( self.B ,7 ) end
OperatorsCB[ 0xF9 ] = function( self ) self.C = self:SetBit( self.C ,7 ) end
OperatorsCB[ 0xFA ] = function( self ) self.D = self:SetBit( self.D ,7 ) end
OperatorsCB[ 0xFB ] = function( self ) self.E = self:SetBit( self.E ,7 ) end
OperatorsCB[ 0xFC ] = function( self ) self.H = self:SetBit( self.H ,7 ) end
OperatorsCB[ 0xFD ] = function( self ) self.L = self:SetBit( self.L ,7 ) end
OperatorsCB[ 0xFE ] = function( self ) self:Write(bor(lshift(self.H,8),self.L), self:SetBit( self:Read(bor(lshift(self.H,8),self.L)) ,7 )); self.Cycle = 16 end
OperatorsCB[ 0xFF ] = function( self ) self.A = self:SetBit( self.A ,7 ) end






