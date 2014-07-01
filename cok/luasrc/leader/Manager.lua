-- leader/Manager.lua
require("bma.lang.ext.Table")

local Class = class.define("leader.Manager")

local LDEBUG = LOG:debugEnabled()
local LTAG = "Leader"

local KEY_LEADER = {"leader"}

function Class.getSpells()
	local w = WORLD
	local l = w:prop(KEY_LEADER)
	if l==nil then
		l = { spells = {} }
		w:prop(KEY_LEADER, l)
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