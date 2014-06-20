-- adventure/Combatd.lua
require("bma.lang.ext.Table")

local Class = class.define("adventure.Combatd")

local LDEBUG = LOG:debugEnabled()
local LTAG = "AdvCombatd"
local IDS = 1

function Class.newCombat(dif)
	local data ={
		stage = "combatBegin",
		dif = dif,
		rt = {
			aorder = {},
			chars = {},		
		},
		profile = {
			chars = {},
			effects = {},
			skills = {},
		}
	}
	return data
end

function Class.calArmor(dif, def)
	local v = def/((dif+4)*100+def)
	if v>0.9999 then v=0.9999 end
	return v
end

function Class.calDodge(dif, agi)
	local v = agi/((dif+4)*100+agi)
	if v>0.9999 then v=0.9999 end
	return v
end

local nextId = function(pre)
	local r = pre .. IDS
	IDS = IDS + 1
	return r
end

local chkset = function(obj, n1, n2)
	if obj[n1]==nil then obj[n1] = obj[n2] end
end

function Class.opTeam(tid)
	if tid==1 then return 2 end
	return 1
end

function Class.listIdByTeam(data, teamId)
	local r = {}
	for cid,ch in pairs(data.rt.chars) do
		if ch.team==teamId then table.insert(r, cid) end
	end
	return r
end

function Class.addChar(data, charObj)
	local cid = charObj.id
	if cid==nil then
		cid = nextId("c")
		charObj.id = cid
	end
	if data.rt.chars[cid] then
		error(string.format("'%s' exists"), cid)
	end
	chkset(charObj, "MAXHP", "HP")
	chkset(charObj, "BASE_HP", "MAXHP")
	chkset(charObj, "BASE_ATK", "ATK")
	chkset(charObj, "BASE_SKL", "SKL")
	chkset(charObj, "BASE_DEF", "DEF")
	chkset(charObj, "BASE_AGI", "AGI")
	charObj.ARMOR = Class.calArmor(data.dif, charObj.DEF)
	charObj.DODGE = Class.calArmor(data.dif, charObj.AGI)
	data.rt.chars[cid] = charObj
	
	local chp = class.forName(charObj._p)
	local chpro = chp.getProfile(charObj)
	chpro.id = cid
	data.profile.chars[cid] = chpro
	if not charObj.title then charObj.title = chpro.title end
	local elist = {}
	if charObj.skills then
		for _, sk in ipairs(charObj.skills) do
			if sk.id==nil then
				sk.id = sk._p
			end
			if not data.profile.skills[sk.id] then
				local skp = class.forName(sk._p)
				local skpro = skp.getProfile()
				skpro.id = sk.id
				data.profile.skills[sk.id] = skpro

				if skp.listRelProfile then
					local rel = skp.listRelProfile()
					if rel then
						for _,tmp in ipairs(rel) do
							table.insert(elist, {id=tmp,_p=tmp})
						end
					end
				end
			end
		end
	end
	if charObj.effects then
		for _, ef in ipairs(charObj.effects) do
			if ef.id==nil then
				ef.id = ef._p
			end
			table.insert(elist, ef)
		end
	end

	for _, ef in ipairs(elist) do
		if not data.profile.effects[ef.id] then
			local efp = class.forName(ef._p)
			local efpro = efp.getProfile()
			efpro.id = ef.id
			data.profile.effects[ef.id] = efpro
		end
	end
end

function Class.setProp(data, ch, n, v)
	if n=="HP" then
		local mhp = ch.MAXHP
		if v>mhp then v=mhp end
	end
	if v<0 then
		v = 0
	end
	ch[n] = v
	if n=="DEF" then
		ch.ARMOR = Class.calArmor(data.dif, v)
	elseif n=="AGI"	 then
		ch.DODGE = Class.calDodge(data.dif, v)
	end
	return v
end

function Class.modifyProp(data, ch, n, v)
	local old = ch[n]
	return Class.setProp(data, ch, n, old+v)
end

function Class.hasEffect(data, ch, id)
	if ch.effects then
		for i, old in ipairs(ch.effects) do
			if old.id == id then
				return true
			end
		end
	end
	return false
end

function Class.applyEffect(data, ch, eff)
	if not eff.id then eff.id = eff._p end
	if not ch.effects then ch.effects = {} end
	local cls = class.forName(eff._p)
	if eff.unique then
		for i, old in ipairs(ch.effects) do
			if old._p == eff._p then
				cls.remove(Class, data, eff, ch)
				table.remove(ch.effects, i)
				break
			end
		end
	end
	table.insert(ch.effects, eff)
	cls.apply(Class, data, eff, ch)
end

function Class.event( data, ev )
	if data.events == nil then data.events = {} end
	data.rt.eid = data.rt.eid + 1
	ev.id = data.rt.eid	
	table.insert(data.events, ev)
	-- var_dump(data.events)
end

function Class.process(data)
	for i=1,100 do
		local f = Class[data.stage]
		if f==nil then
			error(string.format("invalid stage[%s]", data.stage))
		end		
		local doNext = f(data)
		if not doNext then
			return
		end
	end
	if LDEBUG then
		LOG:debug(LTAG, "process loop end")
	end
end

function Class.handleUserCommand(data, cmd)
	local ch = Class.activeChar(data)
	if ch.team~=1 then
		Class.event(data, {k="err", msg="::请稍等"})
		return false
	end
	if cmd.act=="skill" then
		return Class.performSkill(data, cmd)
	end
	Class.event(data, {k="err", msg="::无效操作"})
	return false
end

function Class.checkSkill(data, me, skid, target)
	if skid=="wait" then return true end

	local meobj = data.rt.chars[me]
	local sk
	for _,tmp in ipairs(meobj.skills) do
		if tmp.id == skid then
			sk = tmp
			break
		end
	end
	local skpro = data.profile.skills[skid]
	local tobj
	if target~=nil and target~="" then
		tobj = data.rt.chars[target]
	end

	if meobj==nil or sk==nil or skpro==nil then
		return false, "::无效参数"
	end
	if skpro.target=="one" then
		if tobj==nil then
			return false, "::请选择一个敌方目标"
		end
		if tobj.team==meobj.team then
			return false, "::该技能只对敌方目标使用"
		end
	end

	return true, nil, meobj, sk, skpro, tobj
end

function Class.performSkill(data, cmd)
	if cmd.skill=="wait" then
		data.stage = "charEnd"
		return true
	end

	local ok, err, meobj, sk, skpro, tobj = Class.checkSkill(data, cmd.me, cmd.skill, cmd.target)
	if not ok then
		Class.event(data, {k="err", msg=err})
		return false
	end
	if skpro.AP and skpro.AP>0 then
		if skpro.AP>data.rt.APS then
			Class.event(data, {k="err", msg="::AP不足"})
			return false
		end
		data.rt.APS = data.rt.APS - skpro.AP
		Class.event(data,
		{
			k="aps",
			v=data.rt.APS
		})
	end

	local skp = class.forName(sk._p)
	skp.doPerform(sk, Class, data, meobj, tobj)
	return true
end

function Class.copyProp(des, src, kind)
	des.id = src.id
	des.title = src.title
	des.HP = src.HP
	des.MAXHP = src.MAXHP
	des.ATK = src.ATK	
	des.DEF = src.DEF
	des.SKL = src.SKL
	des.AGI = src.AGI
	des.ARMOR = src.ARMOR
	des.DODGE = src.DODGE
	des.team = src.team
	des.pos = src.pos

	-- skills
	des.skills = {}
	for _,sk in ipairs(src.skills) do
		local sko = {}
		sko.id = sk.id
		sko.XCD = sk.XCD
		-- local skp = class.forName(sk._p)
		-- if skp.copyViewData then
		-- 	skp.copyViewData(sko, sk)
		-- end
		table.insert(des.skills, sko)
	end
	-- effects
	des.effects = {}
	if src.effects then
		for _,ef in ipairs(src.effects) do
			local efo = {}
			local efp = class.forName(ef._p)
			efo.id = ef.id
			efp.copyViewData(efo, ef)
			table.insert(des.effects, efo)
		end
	end
end

-- init view
function Class.buildInit(data, ev)
	local view = {}	
	view.turn = data.rt.turn	
	view.APS = data.rt.APS
	view.aorder = {}	
	for i=1,#data.rt.aorder do
		table.insert(view.aorder, data.rt.aorder[i])
	end
	view.chars = {}
	for k,ch in pairs(data.rt.chars) do
		local vch = {}
		Class.copyProp(vch, ch, "view")
		view.chars[k] = vch
	end

	local profile ={}
	table.copy(profile, data.profile, true)

	ev.view = view
	ev.profile = profile
	return ev
end

function Class.activeChar(data)
	local cid = data.rt.aorder[1]
	return data.rt.chars[cid]
end

-- inner flow
local sortA = function(data)
	table.sort(data.rt.aorder, function(e1,e2)
		local c1 = data.rt.chars[e1]
		local c2 = data.rt.chars[e2]
		if c1.acted == c2.acted then
			if c1.AGI==c2.AGI then return c1.team<c2.team end
			return c1.AGI > c2.AGI
		end		
        if c1.acted then return false end
        return true
    end)
end

function Class.prepare(data)
	data.rt.turn = 1
	data.rt.eid = 1
	data.rt.APS = 0
	for k,ch in pairs(data.rt.chars) do
		ch.acted = false
		table.insert(data.rt.aorder, k)
	end
	sortA(data)
	local o = WORLD
	o:createView("adv_combat", {}, "adventure.ui.Combat",data)
end

function Class.combatBegin(data)	
	data.stage = "turnBegin"
	return true
end

function Class.turnBegin( data )
	if LDEBUG then
		LOG:debug(LTAG, "stage - turnBegin - %d", data.rt.turn)
	end	
	for _,ch in pairs(data.rt.chars) do
		ch.acted = false
	end
	data.stage = "charBegin"
	return true
end

function Class.charBegin( data )
	local ch = Class.activeChar(data)
	if LDEBUG then
		LOG:debug(LTAG, "stage - charBegin - %s", ch.id)
	end
	-- check skills
	if ch.skills then
		for i, sk in ipairs(ch.skills) do
			if sk.XCD and sk.XCD>0 then
				sk.XCD = sk.XCD - 1
			end		
		end
	end
	-- check effects
	if ch.effects then
		local rmlist = {}
		for i, eff in ipairs(ch.effects) do
			if eff.LAST~=nil then
				eff.LAST = eff.LAST - 1
				if eff.LAST<=0 then table.insert(rmlist, 1, i) end
			end		
		end
		for _, idx in ipairs(rmlist) do
			eff = ch.effects[idx]
			table.remove(ch.effects, idx)
			local cls = class.forName(eff._p)
			cls.remove(Class, data, eff, ch)			
		end
	end
	local view = {}
	Class.copyProp(view, ch, "view")
	Class.event(data,
	{
		k="refresh",
		ME=ch.id,
		data=view,
	})
	if ch.team==1 then
		if ch.APS and ch.APS>0 then
			data.rt.APS = data.rt.APS + ch.APS
			Class.event(data,
			{
				k="aps",
				v=data.rt.APS
			})			
		end
		data.stage = "charCommand"
		return true
	end

	-- AI action
	local aicls
	if data.AI then
		aicls = class.forName(data.AI)
	else
		if ch.AI then
			aicls = class.forName(ch.AI)
		else
			aicls = class.forName(ch._p)
		end
	end
	aicls.doAI(Class, data, ch)
	if data.stage == "charBegin" then
		data.stage = "charEnd"
	end
	return true
end

function Class.charCommand(data)
	local ch = Class.activeChar(data)
	if LDEBUG then
		LOG:debug(LTAG, "stage - charCommand - %s", ch.id)
	end
	Class.event(data, {k="cmd"})
	return false
end

function Class.charEnd( data )
	local aid = data.rt.aorder[1]
	if LDEBUG then
		LOG:debug(LTAG, "stage - charEnd - %s", aid)
	end	
	local ch = data.rt.chars[aid]
	ch.acted = true
	table.remove(data.rt.aorder, 1)
	table.insert(data.rt.aorder, aid)
	local a = {}
	table.copy(a, data.rt.aorder,false)
	Class.event(data, {k="nextc",a=a})

	aid = data.rt.aorder[1]
	ch = data.rt.chars[aid]	
	if ch.acted then
		data.stage = "turnEnd"
	else
		data.stage = "charBegin"
	end
	return true
end

function Class.turnEnd( data )
	if LDEBUG then
		LOG:debug(LTAG, "stage - turnEnd - %d", data.rt.turn)
	end	
	data.rt.turn = data.rt.turn + 1
	Class.event(data, {k="turn", v=data.rt.turn})
	data.stage = "turnBegin"
	return true
end

function Class.combatEnd( data )
	if LDEBUG then
		LOG:debug(LTAG, "stage - turnEnd - %d", data.rt.turn)
	end
	Class.event(data, {k="end", winner=data.winner})
	return false
end

-- map
--[[
B<4><5><6>
B<1><2><3>
**********
A<1><2><3>
A<4><5><6>
]]
function Class.doAttack(data, sch, tch, dmg)
	local w = WORLD
	local r = {hited=true}
	local d = tch.DODGE*10000
	local rd = math.random(10000)
	if LDEBUG then
		LOG:debug(LTAG, "dodge, %s:%s, %d/%d", sch.id, tch.id, rd, d)
	end
	if rd<d then		
		r.hited = false
		r.dodge = true
		return r
	end
	local a = tch.ARMOR
	local rdmg = math.ceil((1-a)*dmg)
	if LDEBUG then
		LOG:debug(LTAG, "damage, %s:%s, %d/%d, %d", sch.id, tch.id, dmg, a*100, rdmg)
	end
	r.damage = rdmg
	Class.modifyProp(data, tch, "HP", -rdmg)
	return r
end

function Class.doDie(data, ch)
	-- clear effects
	-- call skills
	data.rt.chars[ch.id] = nil
	for i,cid in ipairs(data.rt.aorder) do
		if cid==ch.id then
			table.remove(data.rt.aorder, i)
			break
		end
	end
	sortA(data)
	local a = {}
	table.copy(a, data.rt.aorder,false)
	Class.event(data, 
		{
			k="die",
			MID=ch.id,
			a=a
		}
	)

	-- check end?
	local t1 = false
	local t2 = false
	for k, cch in pairs(data.rt.chars) do
		if cch.team==1 then t1=true end
		if cch.team==2 then t2=true end
	end
	if t1 and t2 then return end
	-- end
	data.stage = "combatEnd"
	if not t1 then
		data.winner = 2
	else
		data.winner = 1
	end
end