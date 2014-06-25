-- cmod/basetype/SkillBase.lua
local Class = class.define("cmod.basetype.SkillBase")

local POSP = {
	{1,2,3,4,5,6},
	{2,1,2,4,3,4},
	{3,2,1,6,5,4},
}


function Class.posTarget(cbc, data, myTeamId, myPos)
	local tid = cbc.opTeam(myTeamId)
	local tp = 100
	local tch1, tch2
	if myPos>3 then myPos = myPos - 3 end

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


function Class.doAttack(sk, cbc, cbdata, mobj, tobjList, dmg, uik, hitf)
	for _,tobj in ipairs(tobjList) do
		local info = cbc.doAttack(cbdata, mobj, tobj, dmg)

		local refresh
		if info.hited then
			if hitf~=nil then
				hitf(sk, cbc, cbdata, tobj, info)
			end

			local tdata = {}
			cbc.copyProp(tdata, tobj, "view")
			refresh = {
				-- {id=mobj.id, data=mdata},
				{id=tobj.id, data=tdata}
			}
		end

		cbc.event(cbdata, 
			{
				k="skill", uik=uik,
				MID=mobj.id, TID=tobj.id,
				info=info,
				refresh = refresh
			}
		)


		if tobj.HP==0 then
			cbc.doDie(cbdata, tobj)
		end
	end
end