-- cmod/basetype/SpellBase.lua
local Class = class.define("cmod.basetype.SpellBase", {"cmod.basetype.SkillBase"})

function Class.checkPerform(spc,sp)
	if sp.num <=0 then return false end
	if sp.CD and sp.CD>0 then return false end
	return true
end

function Class.afterPerform(spc,sp, cbc,cbdata, cd)
	if sp.num and sp.num >0 then
		sp.num = sp.num - 1
	end
	sp.CD = cd
	sp.CDT = 0
end