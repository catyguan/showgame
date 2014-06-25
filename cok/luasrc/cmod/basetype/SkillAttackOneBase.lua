-- cmod/basetype/SkillAttackOneBase.lua
local Class = class.define("cmod.basetype.SkillAttackOneBase", {"cmod.basetype.SkillBase"})

function Class.checkPerform(sk, cbc, cbdata, ch)
	local target = Class.oneTarget(cbc, cbdata, ch.team, ch.pos)
	if not target then
		return nil
	end
	return {p=50, target=target}
end

function Class.aiPerform(sk, cbc, cbdata, ch, info)
	local tobj = info.target
	cls = class.forName(sk._p)
	cls.doPerform(cls, sk, cbc, cbdata, ch, tobj)
end