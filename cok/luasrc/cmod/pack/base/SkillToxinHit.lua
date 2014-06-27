-- cmod/pack/base/SkillToxinHit.lua
local Class = class.define("cmod.pack.base.SkillToxinHit",{"cmod.basetype.SkillEAttackOneBase"})

Class.UIK = "SkillAttack"

function Class.getProfile()
	return {
		title="::毒系攻击",
		desc="::对一名敌人造成0.8*STR点伤害和0.5*SKL点毒系伤害",
		CD=0,
		target="one"
	}
end

function Class.getDamage(cls, sk, cbc, cbdata, mobj)
	return { pdmg=0.9*mobj.STR, edmgp=0.5*mobj.SKL }
end
