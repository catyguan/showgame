-- adventure/Manager.lua
require("bma.lang.ext.Table")

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

local KEY_WAGON = {"adv", "wagon"}

function Class.getWagon()
	local w = WORLD
	local v = w:prop(KEY_WAGON)
	if v==nil then
		v = {
			chars={}
		}
		w:prop(KEY_WAGON, v)
	end
	return v
end

local KEY_COMBAT = {"adv", "combat"}
function Class.startCombat(opts, emenyTeam, myGroup, myWagon)
	local w = WORLD
	local data = w:prop(KEY_COMBAT)
	if data~=nil then
		return false
	end
	local vopts = {}
	local vemenyTeam = {}
	local vmyGroup = {}
	local vmyWagon

	table.copy(vopts, opts, true)
	table.copy(vemenyTeam, emenyTeam, true)
	table.copy(vmyGroup, myGroup, true)
	if myWagon~=nil then
		vmyWagon = {}
		table.copy(vmyWagon, myWagon, true)
	end

	data = {
		stage="prepare",
		opts=vopts,
		emenyTeam=vemenyTeam,
		team=vmyGroup,
		wagon=vmyWagon
	}
	w:prop(KEY_COMBAT, data)
	Class.flowProcess()
	return true
end

local CF = function(list, id)
	for _, ch in ipairs(list) do
		if ch.id == id then return ch end
	end
	return nil
end

local NC = function(ch)
	local r = {}
	table.copy(r, ch, true)
	return r
end

function Class.setupCombat(team)
	local w = WORLD
	local cb = w:prop(KEY_COMBAT)
	local wg = w:prop(KEY_WAGON)
	local tmp = {}
	table.copy(tmp, cb.team.chars, true)
	cb.team.chars = {}
	for _, s in ipairs(team) do
		-- check if in team
		local mch
		if true then
			local ch = CF(tmp, s.id)
			if ch~=nil then
				mch = ch
			end
		end
		if mch==nil  and cb.wagon then			
			local ch = CF(cb.wagon.chars, s.id)
			if ch~=nil then
				mch = NC(ch)				
			end
		end
		if mch==nil and wg then
			local ch = CF(wg.chars, s.id)
			if ch~=nil then
				mch = NC(ch)
			end
		end
		if mch==nil then
			error(string.format("setupCombat invalid char '%s'", s.id))
		end
		if mch.prop==nil then mch.prop = {} end
		mch.prop.pos = s.pos
		table.insert(cb.team.chars, mch)
	end
	-- var_dump(cb.team)
	cb.stage = "combat"
	cb.emenyTeam.stage = 1
end

local NC2 = function(ch, team)
	local tch = {}
	table.copy(tch, ch, true)
	if not tch.prop then tch.prop = {} end
	tch.prop.team = team
	return tch
end

function Class.flowProcess()
	local w = WORLD
	local ctx = w:prop(KEY_COMBAT)
	if ctx.stage=="prepare" then
		local ui = class.forName("adventure.ui.CombatPrepare")
		ui.uiEnter()
	elseif ctx.stage=="combat" then
		local cbx = w:prop(KEY_COMBAT)
		local cbm = class.forName("adventure.Combatd")

		local cb = cbm.newCombat()		
		local elist = cbx.emenyTeam.groups[cbx.emenyTeam.stage]
		local chlist = elist.chars
		for _, ch in ipairs(chlist) do
			cbm.newChar(cb, NC2(ch, 2))
		end
		local chlist = cbx.team.chars
		for _, ch in ipairs(chlist) do
			cbm.newChar(cb, NC2(ch, 1))
		end
		-- local splist = cbjson.spells
		-- for _,spdata in ipairs(splist) do
		-- 	cbm.addSpell(cb, spdata)
		-- end
		ctx.stage = "combating"
		cbm.prepare(cb)
	end
	return true
end

function Class.endCombat()
	-- body
end