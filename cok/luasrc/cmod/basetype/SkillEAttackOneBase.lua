-- cmod/basetype/SkillEAttackOneBase.lua
local Class = class.define("cmod.basetype.SkillEAttackOneBase", {"cmod.basetype.SkillAttackOneBase"})

function Class.doPerform(cls, sk, cbc, cbdata, mobj, tobj)
	local dmgInfo = cls.getDamage(cls, sk, cbc, cbdata, mobj)
	Class.doAttack(sk, cbc, cbdata, mobj, {tobj}, dmgInfo, cls.UIK)
end
