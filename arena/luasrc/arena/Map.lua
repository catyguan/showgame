-- arena/Map.lua
local MClass = class.define("arena.Map")
local MPosClass = class.define("arena.MapPos")

local LDEBUG = LOG:debugEnabled()
local LTAG = "Map"

ARENA_MAP_GROUP_A = "A"
ARENA_MAP_GROUP_B = "B"
ARENA_MAP_X_MIN = 1
ARENA_MAP_X_MAX = 3
ARENA_MAP_Y_MIN = 1
ARENA_MAP_Y_MAX = 3

ARENA_MAP = function()
	local a = ARENA()
	return a.map
end

--[[
-- A -------------------> B
<A,3,1><A,2,1><A,1,1> | <B,1,1:1><B,2,1:4><B,3,1:7>
<A,3,2><A,2,2><A,1,2> | <B,1,2:2><B,2,2:5:5><B,3,2:8>
<A,3,3><A,2,3><A,1,3> | <B,1,3:3><B,2,3:6:6><B,3,3:9>
]]

-- <<MapPos>>
function MPosClass:ctor(g,x,y)
	self.g = g
	self.x = x
	self.y = y
	self.index = (x-1)*3 + y
end

function MPosClass:key()
	return string.format("%s%d%d", self.g, self.x, self.y)
end

function MPosClass:distance( pos )			
	if self.g == pos.g then		
		local lx = math.abs(self.x-pos.x)
		local ly = math.abs(self.y-pos.y)
		return (lx+ly)*100
	else
		local lx = pos.x
		local ly = math.abs(self.y-pos.y)
		return lx*100+ly*75
	end
end

-- <<Map>>
function MClass:ctor()
	self.units = {A={}, B={}}
end

function MClass:getUnit(pos)
	local g = self.units[pos.g]	
	if g==nil then return nil end
	return g[pos.index]
end

function MClass:oppose(g)
	if g==ARENA_MAP_GROUP_A then
		return ARENA_MAP_GROUP_B
	else
		return ARENA_MAP_GROUP_A
	end
end

function MClass:set(mapUnit)
	if type(mapUnit)=="string" then mapUnit = OBJ(mapUnit) end
	local pos = mapUnit:prop("pos")
	if pos==nil then
		LOG:warn(LTAG,"%s pos invalid",mapUnit:dstr())
		return false
	end
	local g = self.units[pos.g]	
	if g==nil then 
		LOG:warn(LTAG,"%s pos group invalid",pos:key())
		return false
	end
	local old = g[pos.index]
	if old~=nil then
		LOG:warn(LTAG,"<%s> object exists - %s",pos:key(), old:dstr())
		return false
	end
	g[pos.index] = mapUnit
	if LOG:debugEnabled() then
		LOG:debug(LTAG,"<%s> in  %s",pos:key(), mapUnit:dstr())
	end
	return true
end

function MClass:unset(mapUnit)
	if type(mapUnit)=="string" then mapUnit = OBJ(mapUnit) end
	local pos = mapUnit:prop("pos")
	if pos==nil then
		return false
	end
	local g = self.units[pos.g]	
	if g==nil then 
		LOG:warn(LTAG,"%s pos group invalid",pos:key())
		return false
	end
	local old = g[pos.index]
	if old~=mapUint then
		return false
	end
	g[pos.index] = nil
	if LOG:debugEnabled() then
		LOG:debug(LTAG,"<%s> out %s",pos:key(), mapUnit:dstr())
	end
	return true
end

function MClass:group(gn)
	local r = {}
	local g = self.units[gn]
	if g~=nil then
		for _,ob in pairs(g) do
			table.insert(r, ob)
		end
	end
	return r
end