-- cmod/pack/base/SkillDef.lua
local Class = class.define("cmod.pack.base.SkillDef")

function Class.getProfile()
	return {
		title="::防御",
		desc="::恢复自身{DEF}点防盾",
		AP=30,
		CD=2,
		target="self"
	}
end

function Class.listRelProfile()
	return {"cmod.pack.base.EffDef"}
end

function Class.doPerform(sk, cbc, cbdata, mobj, tobj)	
	local eff = class.forName("cmod.pack.base.EffDef").newEff(mobj.BASE_DEF, 2)
	cbc.applyEffect(cbdata, mobj, eff)

	local data = {}
	cbc.copyProp(data, mobj, "view")
	cbc.event(cbdata, 
		{
			k="skill", uik="SkillDef",
			ME=mobj.id,
			data=data,
		}
	)
	return true
end