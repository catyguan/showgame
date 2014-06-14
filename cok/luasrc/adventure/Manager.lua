-- adventure/Manager.lua
local Class = class.define("adventure.Manager")

local LDEBUG = LOG:debugEnabled()
local LTAG = "AdvManager"

-- random or quest
function Class.queryRegions()
	local w = WORLD

	-- regions from Quest
	local qm = class.forName("quest.Manager")
	local rlist = qm.callAll("queryRegion")
	local r = {}
	for i=1,2 do
		if #rlist>0 then
			local idx = math.random(#rlist)
			local map = rlist[idx]
			table.remove(rlist, idx)
			table.insert(r, map)
		end
	end

	-- regions from CMod
	local cmm = class.forName("cmod.Manager")
	local rflist = cmm.callAll("queryRegionFactory")
	local r = {}
	if #rflist>0 then
		while #r<3 do
			local idx = math.random(#rflist)
			local rf = rflist[idx]
			local q = rf()
			table.insert(r, q)
		end
	end

	return r
end