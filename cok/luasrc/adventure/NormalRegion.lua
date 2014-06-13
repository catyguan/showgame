-- adventure/NormalRegion.lua
local Class = class.define("adventure.NormalRegion", {"adventure.Region"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "AdvNormalRegion"

function Class.firstArea(cls, data, area)
	local r = {}
	r.width=5
	r.height=1
	r.boss = false
	r.cells = {}

	local c1 = {
		id=1,x=1,y=1,kind="entry",canEnter=true,visible=true, roads={2}
	}
	r.cells[1] = c1

	local c2 = {
		id=2,x=2,y=1,kind="mod",canEnter=true,visible=true, roads={1,3}
	}
	r.cells[2] = c2

	local c3 = {
		id=3,x=3,y=1,kind="box",canEnter=false,visible=true, roads={2,4}
	}
	r.cells[3] = c3

	local c4 = {
		id=4,x=4,y=1,kind="mod",canEnter=false,visible=false, roads={3,5}
	}
	r.cells[4] = c4

	local c5 = {
		id=5,x=5,y=1,kind="exit",canEnter=false,visible=false, roads={4}
	}
	r.cells[5] = c5

	return r
end