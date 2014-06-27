-- cmod/pack/base/SkillDelayHit.lua
local Class = class.define("cmod.pack.base.SkillDelayHit",{"cmod.basetype.SkillAttackOneBase"})

Class.UIK = "SkillAttack"

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

local hitf = function(sk, cbc, cbdata, ch, info)
	local v = math.ceil(ch.SPD*0.15)
	local eff = class.forName("cmod.pack.base.EffSlow").newEff(v, 1)
	cbc.applyEffect(cbdata, ch, eff)
end

function Class.doPerform(cls, sk, cbc, cbdata, mobj, tobj)
	cls.doAttack(sk, cbc, cbdata, mobj, {tobj}, 1.0*mobj.STR, cls.UIK, hitf)
end
