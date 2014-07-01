-- cmod/pack/base/SpellHeal.lua
local Class = class.define("cmod.pack.base.SpellHeal",{"cmod.basetype.SpellBase"})

Class.UIK = "heal"

function Class.getProfile()
	return {
		title="::快速治疗",
		pic="images/sp_heal.png",
		desc="::恢复全部队员100点HP",
		CD=2
	}
end

function Class.doPerform(cbc,cbdata, sp)
	if not Class.checkPerform(Class,sp) then return false end

	local olist = cbc.listByTeam(cbdata, 1, true)
	local healv = 100
	local ev = {}
	cbc.eventBegin(cbdata, "usespell")
	ev.k = "usespell"
	ev.sid = sp.id
	ev.uik = Class.UIK
	ev.MID = ""
	Class.doHeal(Class,sp ,cbc,cbdata, nil,nil, olist, healv, ev)
	cbc.eventCommit(cbdata,"usespell", ev)

	Class.afterPerform(Class,sp, cbc,cbdata, 2)
	return true
end
