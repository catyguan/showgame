-- cmod/pack/base/SkillStunHit.lua
local Class = class.define("cmod.pack.base.SkillStunHit",{"cmod.basetype.SkillAttackOneBase"})

Class.UIK = "SkillAttack"

function Class.getProfile()
	return {
		title="::撞击",
		desc="::对一名敌人造成0.9*STR点伤害并小几率使其眩晕",
		CD=0,
		target="one"
	}
end

function Class.listRelProfile()
	return {
		{_p="cmod.pack.base.EffStun"}
	}
end

function Class.whenHit(skc,sk, cbc,cbdata, tch,ch, info)
	local v = math.random(100)
	if v<=15 then
		local eff = class.forName("cmod.pack.base.EffStun").newEff(1)
		cbc.applyEffect(cbdata, tch,ch, eff)	
	end	
end

function Class.getDamage(skc,sk, cbc,cbdata, tch,ch)
	return 1.0*ch.STR
end