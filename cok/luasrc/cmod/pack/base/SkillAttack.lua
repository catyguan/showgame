-- cmod/pack/base/SkillAttack.lua
local Class = class.define("cmod.pack.base.SkillAttack")

function Class.getProfile()
	return {
		title="::攻击",
		desc="::对一名敌人造成{ATK}点伤害",
		AP=20,
		CD=0,
		target="one"
	}
end

function Class.checkPerform(sk, cbc, cbdata, ch)	
	local idlist = cbc.listIdByTeam(cbdata, 1)
	if #idlist==0 then
		return nil
	end
	return {p=50, target=idlist}
end

function Class.aiPerform(sk, cbc, cbdata, ch, info)
	local tid = info.target[1]
	local tobj = cbdata.rt.chars[tid]
	Class.doPerform(sk, cbc, cbdata, ch, tobj)
end

function Class.doPerform(sk, cbc, cbdata, mobj, tobj)
	local dmg = mobj.ATK
	local info = cbc.doAttack(cbdata, mobj, tobj, dmg)

	local refresh
	if info.hited then
		-- local mdata = {}
		-- cbc.copyProp(mdata, mobj, "view")
		local tdata = {}
		cbc.copyProp(tdata, tobj, "view")
		refresh = {
			-- {id=mobj.id, data=mdata},
			{id=tobj.id, data=tdata}
		}
	end

	cbc.event(cbdata, 
		{
			k="skill", uik="SkillAttack",
			MID=mobj.id, TID=tobj.id,
			info=info,
			refresh = refresh
		}
	)


	if tobj.HP==0 then
		cbc.doDie(cbdata, tobj)
	end

end