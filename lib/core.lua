local self = GnomeBoyAdvance
GBAgem = {}
local gem = GBAgem -- Faster access
gem.mt = {} -- The metatable
gem.mt.base = gem -- Faster access to the base global table
gem.mt.__index = gem.mt
gem.GBZ80 = {}

----------------------------------------------------------------------
-- Name: New
-- Desc: Creates a new instance of the emulator
----------------------------------------------------------------------
function gem.New(ROMstring, emulatortype )
	--print("Received ", string.sub(ROMstring,1,5),emulatortype)
	local new = setmetatable({}, gem.mt)
	new.ROMstring = ROMstring
	new.emulatortype = emulatortype
	
	if emulatortype == "GBZ80" then
		for k,v in pairs( gem.GBZ80 ) do
			new[k] = v
		end
	end
	new:Initialize()
	return new
end

----------------------------------------------------------------------
-- Name: Error
-- Desc: Helper function for erroring
----------------------------------------------------------------------
function gem.mt:Error( msg )
	print( msg )
end

----------------------------------------------------------------------
-- Name: Initialize
-- Desc: Called when the instance is created
----------------------------------------------------------------------
function gem.mt:Initialize()
	-- Placeholder
end

----------------------------------------------------------------------
-- Name: Draw
-- Desc: Called in the entity's Draw hook
----------------------------------------------------------------------
function gem.mt:Draw()
end

----------------------------------------------------------------------
-- Name: Think
-- Desc: Called in the entity's Think hook
----------------------------------------------------------------------
function gem.mt:Think()
	-- Process here
end

----------------------------------------------------------------------
-- Name: OnRemove
-- Desc: Called when the entity is removed
----------------------------------------------------------------------
function gem.mt:OnRemove()
	-- Do shutdown stuff here (backup state? maybe)
end

----------------------------------------------------------------------
-- Name: KeyChanged
-- Desc: Called when the user presses/releases a key
----------------------------------------------------------------------
function gem.mt:KeyChanged( key, bool )

end

----------------------------------------------------------------------
-- Name: IsDebugging
-- Desc: Returns true if the emulator is in debug mode
----------------------------------------------------------------------
function gem.mt:IsDebugging()
	return (self.Debugging == true)
end

----------------------------------------------------------------------
-- Name: EnableDebugging
-- Desc: User wants to enable debugging
----------------------------------------------------------------------
function gem.mt:EnableDebugging()
	if self:IsDebugging() then return false end
	self._Think = self.Think
	self.Think = function() end
	self.Debugging = true
	return true
end

----------------------------------------------------------------------
-- Name: DisableDebugging
-- Desc: User wants to disable debugging
----------------------------------------------------------------------
function gem.mt:DisableDebugging()
	if not self:IsDebugging() then return false end
	self.Think = self._Think
	self._Think = nil
	self.Debugging = false
	return true
end

----------------------------------------------------------------------
-- Name: Step
-- Desc: Debug stepping
----------------------------------------------------------------------
function gem.mt:Step()
end

----------------------------------------------------------------------
-- Name: DumpHistory
-- Desc: Dump history to file
----------------------------------------------------------------------
function gem.mt:DumpHistory()
	print(table.concat( self.History, "\n" ))
end