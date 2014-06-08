-- world/WorldManager.lua
local Class = class.define("world.WorldManager")

local LDEBUG = LOG:debugEnabled()
local LTAG = "WorldManager"

local idk = function(id)
	return "k"..id
end

function Class:ctor()
	self.worlds = {}
end

function Class:newWorld(id)
	local kid  = idk(id)
	local old = self.worlds[kid]
	if old ~= nil then
		return old
	end
	if LDEBUG then
		LOG:debug(LTAG,"new world "..id)
	end

	local o = class.new("world.World")
	o.id = id

	self.worlds[kid] = o
	
	return o
end

function Class:getWorld( id )
	return self.worlds[idk(id)]
end

function Class:closeWorld( id )	
	local key = idk(id)
	local o = self.worlds[key]	
	if o~=nil then
		if LDEBUG then		
			LOG:debug(LTAG,"close world "..id)
		end
		self.worlds[key] = nil
		o:close()
	end
end
