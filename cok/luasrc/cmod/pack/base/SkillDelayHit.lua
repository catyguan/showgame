-- cmod/pack/base/SkillDelayHit.lua
local Class = class.define("cmod.pack.base.SkillDelayHit",{"cmod.basetype.SkillAttackOneBase"})

Class.UIK = "hit"

function Class.getProfile()
	return {
		title="::击退",
		desc="::对一名敌人造成1.0*STR点伤害并减少其攻击速度",
		CD=0,
		target="one"
	}
end

function Class.listRelProfile()
	return {
		{_p="cmod.pack.base.EffSlow"}
	}
end

function Class.whenHit(skc,sk, cbc,cbdata, chc,ch, info)
	local v = math.ceil(ch.SPD*0.15)
	local eff = class.forName("cmod.pack.base.EffSlow").newEff(v, 1)
	cbc.applyEffect(cbdata, tch,ch, eff)
end

function Class.getDamage(skc,sk, cbc,cbdata, tch,ch)
	return 1.0*ch.STR
end