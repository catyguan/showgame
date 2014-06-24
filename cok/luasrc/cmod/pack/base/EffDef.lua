-- cmod/pack/base/EffDef.lua
local Class = class.define("cmod.pack.base.EffDef", {"cmod.skill.SkillBase"})

function Class.getProfile()
	return {
		title="::防御姿势",
		pic="images/eff_def.png",
		desc="::提升{XDEF}点防御，持续{LAST}回合"
	}
end

function Class.newEff(def, last)
	return {
		_p = Class.className,
		unique = true,
		XDEF = 100+def,
		LAST = last
	}
end

function Class.copyViewData(des, src)
	des.XDEF = src.XDEF
	des.LAST = src.LAST
end

function Class.apply(cbc, cbdata, eff, ch)
	cbc.modifyProp(cbdata, ch, "DEF", eff.XDEF)
end

function Class.remove(cbc, cbdata, eff, ch)
	cbc.modifyProp(cbdata, ch, "DEF", -eff.XDEF)
end
