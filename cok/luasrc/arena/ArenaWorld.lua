-- arena/ArenaWorld.lua
local Class = class.forName("arena.Arena")

local LDEBUG = LOG:debugEnabled()
local LTAG = "Arena"

ARENA_GROUP_ATK = 1
ARENA_GROUP_DEF = 2

-- <<world function>>
-- summon a object on battlefield
-- the object must in matrix objects
function Class:summon( obj )
	if not self.map:set(obj) then
		return false
	end
	if LDEBUG then
		LOG:debug(LTAG, "%s >> summon(%s)",self:dumpTime(), obj:id())
	end
	if self.events:Valid() then
		local ev = {
			n = "summon",
			t = self._prop.time,
			oid = obj:id(),
			pos = obj:pos()
		}
		this.events:fire(ev)
	end
	return true
end

function Class:arenaEnd(why, winner)
	if self:isEnd() then
		return
	end

	if LDEBUG then
		LOG:debug(LTAG, "%s >> arenaEnd(%s, %d)",self:dumpTime(), why, winner)
	end
	self:doEnd()

	if self.events:Valid() then
		local ev = {
			n = "arenaEnd",
			t = self._prop.time,
			why = why,
			winner = winner
		}
		this.events:fire(ev)
	end	
end