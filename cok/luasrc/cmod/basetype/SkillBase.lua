-- cmod/basetype/SkillBase.lua
local Class = class.define("cmod.basetype.SkillBase")

local POSP = {
	{1,2,3,4,5,6,7,8},
	{3,1,2,4,7,5,6,8},
	{4,2,1,3,8,6,5,7},
	{4,3,2,1,8,7,6,5},
}


function Class.posTarget(cbc, data, myTeamId, myPos)
	local tid = cbc.opTeam(myTeamId)
	local tp = 100
	local tch1, tch2
	if myPos>4 then myPos = myPos - 4 end

	for _, ch in pairs(data.rt.chars) do
		if tid==ch.team then
			local p = POSP[myPos][ch.pos]
			if p == tp then
				if tch1~=nil then
					tch2 = ch
				else
					tch1 = ch
				end
			elseif p < tp then
				tp = p
				tch1 = ch
				tch2 = nil
			end
		end
	end
	return tch1, tch2
end

function Class.oneTarget(cbc, data, myTeamId, myPos)
	local t1, t2 = Class.posTarget(cbc, data, myTeamId, myPos)	
	local target
	if t1~=nil then
		target = t1
		if t2~=nil then
			if math.random(2)==2 then target = t2 end
		end
	end	
	return target
end


function Class.doAttack(skc,sk, cbc,cbdata, mchc,mobj, tobjList, dmg, ev)
	for _,tobj in ipairs(tobjList) do
		local tchc = class.forName(tobj._p)
		local info = cbc.doAttack(cbdata, mchc,mobj, tchc,tobj, dmg)

		local refresh
		if info.hited then
			if skc.whenHit~=nil then
				skc.whenHit(sk, cbc,cbdata, tchc,tobj, info)
			end

			local tdata = {}
			cbc.copyCharView(tdata, tobj)
			if not ev.refresh then ev.refresh = {} end
			table.insert(ev.refresh, {id=tobj.id, data=tdata})
		end

		if not ev.info then ev.info = {} end
		info.TID = tobj.id
		table.insert(ev.info, info)

		if tobj.HP==0 then
			cbc.doDie(cbdata, tchc,tobj)
		end
	end
end