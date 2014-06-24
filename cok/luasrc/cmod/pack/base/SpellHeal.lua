-- cmod/pack/base/SpellHeal.lua
local Class = class.define("cmod.pack.base.SpellHeal",{"cmod.spell.SpellBase"})

function Class.getProfile()
	return {
		title="::快速治疗",
		pic="images/sp_heal.png",
		desc="::恢复全部队员50点HP",
		CD=2
	}
end

function Class.doPerform(cbc, cbdata, sp)
	if not Class.checkPerform(sp) then return false end

	local ilist = cbc.listIdByTeam(cbdata, 1)
	local refresh = {}
	for _, cid in ipairs(ilist) do
		local ch = cbdata.rt.chars[cid]
		cbc.modifyProp(cbdata, ch, "HP", 50)
		local tdata = {}
		cbc.copyCharView(tdata, ch)
		table.insert(refresh, {id=ch.id, data=tdata})
	end	
	cbc.event(cbdata, {
		k="skill", uik="SpellHeal",
		refresh = refresh
	})
	Class.afterPerform(cbc, cbdata, sp, 2)
	return true
end
