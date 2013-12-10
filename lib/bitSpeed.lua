

-- From http://lua-users.org/wiki/FuncTables

local function pack( ... )
    return arg
end

local function memoize( fn )
    local function fnKey( ... )
        local key = ""
        for i = 1, table.getn( arg ) do
            key = key .. "[" .. tostring( arg[ i ] ) .. "]"
        end
        return key 
    end

    local object = {
        __call  = function( targetTable, ... )
            local key = fnKey( ... )
            local values = targetTable.__memoized[ key ]

            if ( values == nil ) then
                values = pack( fn( ... ) )
                targetTable.__memoized[ key ] = values
            end

            if ( table.getn( values ) > 0 ) then
                return unpack( values )
            end

            return nil
        end,
        __forget = function( self ) self.__memoized = {} end,
        __memoized = {},
        __mode = "v",
    }

    return setmetatable( object, object )
end

GB_BIT_OPTIMIZED = {
	["band"] = memoize(bit.band),
	["bor"] = memoize(bit.bor),
	["rshift"] = memoize(bit.rshift),
	["lshift"] = memoize(bit.lshift)
}