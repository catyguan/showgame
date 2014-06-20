-- cmod/pack/base/SkillDef.lua
local Class = class.define("cmod.pack.base.SkillDef")

function Class.getProfile()
	return {
		title="::防御",
		desc="::恢复自身{DEF}点防盾",
		AP=20,
		CD=2,
		target="self"
	}
end

function Class.listRelProfile()
	return {"cmod.pack.base.EffDef"}
end

function Class.checkPerform(sk, cbc, cbdata, ch)
	if cbc.hasEffect(cbdata, ch, sk.id) then return nil end
	if sk.XCD and sk.XCD>0 then return nil end
	return {p=10}
end

function Class.aiPerform(sk, cbc, cbdata, ch, info)
	Class.doPerform(sk, cbc, cbdata, ch, nil)
end

function Class.doPerform(sk, cbc, cbdata, mobj, tobj)	
	local eff = class.forName("cmod.pack.base.EffDef").newEff(mobj.BASE_DEF, 2)
	cbc.applyEffect(cbdata, mobj, eff)
	sk.XCD = 2

	local data = {}
	cbc.copyProp(data, mobj, "view")
	cbc.event(cbdata, 
		{
			k="skill", uik="SkillDef",
			MID=mobj.id,
			refresh = {
				{id=mobj.id, data=data}
			}
		}
	)
end