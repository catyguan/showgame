-- cmod/pack/base/SkillAttack.lua
local Class = class.define("cmod.pack.base.SkillAttack")

function Class.getProfile()
	return {
		title="::攻击",
		desc="::对一名敌人造成{ATK}点伤害",
		AP=30,
		CD=0,
		target="one"
	}
end