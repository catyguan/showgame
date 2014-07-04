-- kindom/Manager.lua
require("bma.lang.ext.Table")

local Class = class.define("kindom.Manager")

local RES = class.forName("world.Resource")

local LDEBUG = LOG:debugEnabled()
local LTAG = "Leader"

local KEY_KINDOM = {"kindom"}

-- info
function Class.getInfo()
	local w = WORLD
	local l = w:prop(KEY_KINDOM)
	if l==nil then
		l = {}
		w:prop(KEY_KINDOM, l)
	end
	if not l.info then
		l.info = {}
	end
	return l.info
end

-- town
function Class.getTowns()
	local w = WORLD
	local l = w:prop(KEY_KINDOM)
	if l==nil then
		l = {}
		w:prop(KEY_KINDOM, l)
	end
	if not l.towns then
		l.towns = {}
	end
	return l.towns
end

function Class.getTown(tid)
	local tl = Class.getTowns();
	for _,t in ipairs(tl) do
		if t.id==tid then return t end
	end
	return nil
end

-- building
function Class.getBuildings()
	local w = WORLD
	local l = w:prop(KEY_KINDOM)
	if l==nil then
		l = {}
		w:prop(KEY_KINDOM, l)
	end
	if not l.buildings then
		l.buildings = {}
	end
	return l.buildings
end

function Class.getBuilding(bid)
	local l = Class.getBuildings();
	for _,b in ipairs(l) do
		if b.id==bid then return b end
	end
	return nil
end

-- resources
function Class.getResources()
	local w = WORLD
	local l = w:prop(KEY_KINDOM)
	if l==nil then
		l = {}
		w:prop(KEY_KINDOM, l)
	end
	if not l.res then
		local mx = {}
		mx[RES_GOLD] = 100
		mx[RES_FOOD] = 100
		mx[RES_GOODS] = 100
		mx[RES_MAGIC] = 100
		l.res = RES.newResourcePool(mx)
	end
	return l.res
end

function Class.payResource(resKey, v)
	local resp = Class.getResources()
	local res = resp[resKey]
	return RES.pay(res, v)
end

function Class.modifyResource(resKey, v)
	local resp = Class.getResources()
	local res = resp[resKey]
	return RES.modify(res, v)
end

-- spells
function Class.getSpells()
	local w = WORLD
	local l = w:prop(KEY_KINDOM)
	if l==nil then
		l = { spells = {} }
		w:prop(KEY_KINDOM, l)
	end
	if not l.spells then
		l.spells = {}
	end
	return l.spells
end

function Class.setSpells(splist)
	local spl = Class.getSpells()
	for _,sp in ipairs(splist) do
		local m = false
		for _,csp in ipairs(spl) do
			if csp._p == sp._p then
				csp.num = sp.num
				m = true
				break
			end
		end
		if not m then
			local o = {}
			table.copy(o, sp, true)
			table.insert(spl, o)
		end
	end
end

function Class.updateSpells(splist)
	local tmp = {}
	for _,sp in ipairs(splist) do
		tmp[sp._p] = sp.num
	end
	local spl = Class.getSpells()
	local rlist = {}
	for i,sp in ipairs(spl) do
		local num = tmp[sp._p]
		if num then
			sp.num = num
		else
			table.insert(rlist, 1, i)
		end
	end
	for _,i in ipairs(rlist) do
		table.remove(spl, i)
	end
end