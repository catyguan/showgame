-- cmod/basetype/SkillEAttackOneBase.lua
local Class = class.define("cmod.basetype.SkillEAttackOneBase", {"cmod.basetype.SkillAttackOneBase"})

function Class.doPerform(skc,sk, cbc,cbdata, chc,mobj, tobj)
	local dmgInfo = skc.getDamage(skc,sk, cbc,cbdata, chc,mobj)
	local ev = {}
	cbc.eventBegin(cbdata, "skill")
	ev.k = "skill"
	ev.sid = sk.id
	ev.uik = skc.UIK
	ev.MID = mobj.id
	Class.doAttack(skc,sk, cbc,cbdata, skc,mobj, {tobj}, dmgInfo, ev)
	cbc.eventCommit(cbdata,"skill", ev)
end
