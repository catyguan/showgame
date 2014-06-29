-- cmod/basetype/SkillAttackOneBase.lua
local Class = class.define("cmod.basetype.SkillAttackOneBase", {"cmod.basetype.SkillBase"})

function Class.checkPerform(skc,sk, cbc,cbdata, chc,ch)
	local target = Class.oneTarget(cbc, cbdata, ch.team, ch.pos)
	if not target then
		return nil
	end
	return {p=50, target=target}
end

function Class.aiPerform(skc,sk, cbc,cbdata, chc,ch, info)
	local tobj = info.target
	skc.doPerform(skc,sk, cbc,cbdata, chc,ch, tobj)
end