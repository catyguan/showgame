-- cmod/basetype/CharBase.lua
require("world.PRandom")

local Class = class.define("cmod.basetype.CharBase")

function Class.levelUp(prop, lvl, grow)
	if lvl==1 then return end
	for k,gv in pairs(grow) do
		local v = prop[k]
		if v~=nil then
			nv = v * math.pow(1 + gv, lvl-1)
			prop[k] = math.ceil(nv)
		end
	end
end

function Class.doAI(cbc, cbdata, ch)
	Class.doRandomSkill(cbc, cbdata, ch)
end

function Class.doRandomSkill(cbc, cbdata, ch)
	local sklist = {}
	for _,sk in ipairs(ch.skills) do
		local skp = class.forName(sk._p)
		if skp.checkPerform then
			local info = skp.checkPerform(sk, cbc, cbdata, ch)
			if info~=nil then
				info._THIS = sk
				if not info.p then info.p = 1 end
				table.insert(sklist, info)
			end
		end
	end
	if #sklist==0 then
		cbc.event(cbdata, {
			k="skill", uik="wait",
			MID=ch.id
		})
		cbdata.stage="charEnd"
		return
	end

	local idx = PRandom(sklist)
	local sinfo = sklist[idx]
	local skp = class.forName(sinfo._THIS._p)
	skp.aiPerform(sinfo._THIS, cbc, cbdata, ch, sinfo)
end