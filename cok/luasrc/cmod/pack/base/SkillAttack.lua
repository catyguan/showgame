-- cmod/pack/base/SkillAttack.lua
local Class = class.define("cmod.pack.base.SkillAttack",{"cmod.basetype.SkillEAttackOneBase"})

Class.UIK = "hit"

function Class.getProfile()
	return {
		title="::猛击",
		desc="::对一名敌人造成1.0*STR点伤害",
		CD=0,
		target="one"
	}
end

function Class.getDamage(skc,sk, cbc,cbdata, tch,ch)
	return 1.0*ch.STR
end
