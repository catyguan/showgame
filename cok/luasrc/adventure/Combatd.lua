-- adventure/Combatd.lua
require("bma.lang.ext.Table")

local Class = class.define("adventure.Combatd")

local LDEBUG = LOG:debugEnabled()
local LTAG = "AdvCombatd"
local IDS = 1
local ACT_AP = 500

function Class.newCombat()
	local data ={
		stage = "combatBegin",
		rt = {
			aorder = {},
			chars = {},
			spells = {}		
		},
		profile = {
			chars = {},
			effects = {},
			skills = {},
			spells = {}
		}
	}
	return data
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


local HProfiles = function(data, plist)
	for _, tmp in ipairs(plist) do
		if tmp.k=="char" then

		else
			local ef = tmp
			if ef.id==nil then ef.id = ef._p end
			if not data.profile.effects[ef.id] then
				local efp = class.forName(ef._p)
				local efpro = efp.getProfile(ef)
				if efpro.id==nil then efpro.id = ef.id end
				data.profile.effects[ef.id] = efpro
			end
		end
	end
end

function Class.newChar(data, charObj)
	local ch = charObj
	local cls = class.forName(charObj._p)
	ch = cls.newChar(charObj.level)	
	ch._p = charObj._p
	ch.level = charObj.level
	if charObj.prop then
		for k,v in pairs(charObj.prop) do
			ch[k] = v
		end
	end
	Class.addChar(data, ch)
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
	chkset(charObj, "BASE_STR", "STR")
	chkset(charObj, "BASE_SKL", "SKL")
	chkset(charObj, "BASE_DEF", "DEF")
	chkset(charObj, "BASE_SPD", "SPD")
	charObj.ARMOR = 0.0
	if charObj.DODGE==nil then
		charObj.DODGE = 0.1
	end	
	
	local chp = class.forName(charObj._p)
	local chpro = chp.getProfile(charObj)
	if chpro.id==nil then chpro.id = cid end
	if not charObj.title then charObj.title = chpro.title end
		
	data.rt.chars[cid] = charObj
	data.profile.chars[cid] = chpro

	local plist = {}
	if charObj.skills then
		for _, sk in ipairs(charObj.skills) do
			if sk.id==nil then
				sk.id = sk._p
			end
			if not data.profile.skills[sk.id] then
				local skp = class.forName(sk._p)
				local skpro = skp.getProfile(sk)
				if skpro.id==nil then skpro.id = sk.id end
				data.profile.skills[sk.id] = skpro

				if skp.listRelProfile then
					local rel = skp.listRelProfile()
					if rel then
						for _,tmp in ipairs(rel) do
							table.insert(plist, tmp)
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
			table.insert(plist, ef)
		end
	end
	HProfiles(data, plist)	
end

function Class.addSpell(data, sp)
	if not sp.id then sp.id = nextId("s") end

	data.rt.spells[sp.id] = sp
	local spp = class.forName(sp._p)
	local sppro = spp.getProfile(sp)
	if sppro.id==nil then sppro.id = sp.id end
	data.profile.spells[sp.id] = sppro

	local plist = {}
	if spp.listRelProfile then
		local rel = spp.listRelProfile()
		if rel then
			for _,tmp in ipairs(rel) do
				table.insert(plist, tmp)
			end
		end
	end
	HProfiles(data, plist)
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
	elseif n=="AGI"	 then		
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

function Class.applyFlag(data, ch, n)
	local v = ch[n]
	if v==nil then
		v = 1
	else
		v = v + 1
	end
	ch[n] = v
end

function Class.removeFlag(data, ch, n)
	local v = ch[n]
	if v~=nil then
		v = v - 1
		if v<=0 then
			ch[n] = nil
		else
			ch[n] = v
		end
	end
end

function Class.event( data, ev )
	if data.events == nil then data.events = {} end
	if data.eventg~=nil and #data.eventg>0 then
		local eg = data.eventg[#data.eventg]
		table.insert(eg.es, ev)
		return
	end
	data.rt.eid = data.rt.eid + 1
	ev.id = data.rt.eid	
	table.insert(data.events, ev)
	-- var_dump(data.events)
end

function Class.eventBegin(data, eid)
	if data.eventg == nil then data.eventg = {} end
	table.insert(data.eventg, {id=eid, es={}})
end

function Class.eventCommit(data, eid, ev)
	local eg
	if data.eventg~=nil and #data.eventg>0 then
		eg = data.eventg[#data.eventg]		
	end
	if not eg then
		error("event commit fail, eventg empty")
	end
	if eg.id~=eid then
		error(string.format("event commit fail, id not same, %s - %s", eg.id, eid))
	end
	table.remove(data.eventg, #data.eventg)
	if ev~=nil then
		Class.event(data, ev)
	end
	for _,lev in ipairs(eg.es) do
		Class.event(data, lev)
	end
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
	if data.stage=="combatEnd" then
		Class.event(data, {k="err", msg="::已结束"})
		return false
	end
	if cmd.act=="spell" then
		return Class.performSpell(data, cmd)
	end
	Class.event(data, {k="err", msg="::无效操作"})
	return false
end

function Class.copyCharView(des, src)
	Class.copyProp(des, src, "view")
end

function Class.copyProp(des, src, kind)
	des.id = src.id
	des.level = src.level
	des.title = src.title
	des.HP = src.HP
	des.MAXHP = src.MAXHP
	des.team = src.team
	des.pos = src.pos

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

function Class.copySpellView(des, src)
	des.id = src.id
	des.num = src.num
	des.CD = src.CD
end

-- init view
function Class.buildInit(data, ev)
	local view = {}
	view.turn = data.rt.turn
	view.chars = {}
	for k,ch in pairs(data.rt.chars) do
		local vch = {}
		Class.copyProp(vch, ch, "view")
		view.chars[k] = vch
	end

	view.spells = {}
	for k, sp in pairs(data.rt.spells) do
		local vsp = {}
		Class.copySpellView(vsp, sp)
		view.spells[k] = vsp
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
		if c1.AP==c2.AP then return c1.team<c2.team end
		return c1.AP > c2.AP
    end)
end

function Class.prepare(data)
	data.rt.turn = 0
	data.rt.eid = 1
	local nspa = {}
	for k,ch in pairs(data.rt.chars) do
		local ns = nspa[ch._p]
		if ns then
			ns.c = ns.c + 1
		else
			nspa[ch._p] = {c=1, n=1}
		end
		ch.AP = ch.SPD
		table.insert(data.rt.aorder, k)
	end
	for k,ch in pairs(data.rt.chars) do
		local ns = nspa[ch._p]
		if ns.c>1 then
			if ch.title==data.profile.chars[k].title then
				ch.title = ch.title .. ns.n
				ns.n = ns.n + 1
			end
		end
	end
	sortA(data)
	local o = WORLD
	o:createView("adv_combat", {}, "adventure.ui.Combat", data)
end

function Class.combatBegin(data)	
	data.stage = "pollStage"
	return true
end

function Class.pollStage( data )
	if LDEBUG then
		LOG:debug(LTAG, "stage - pollStage")
	end
	for i=1,10 do
		for _, sp in pairs(data.rt.spells) do
			if sp.CD and sp.CD>0 then
				sp.CDT = sp.CDT + 100
				if sp.CDT > ACT_AP then
					sp.CD = sp.CD - 1
					sp.CDT = sp.CDT - ACT_AP
					local spv = {}
					Class.copySpellView(spv, sp)
					Class.event(data, {k="spell", SID=sp.id, data=spv})					
				end
			end
		end

		local act = false
		for _,ch in pairs(data.rt.chars) do
			ch.AP = ch.AP + ch.SPD		
			if ch.AP>=ACT_AP then act = true end
		end
		if act then			
			data.stage = "actStage"
			return true
		end
	end
	data.stage = "pollStage"
	return true
end

function Class.actStage(data)
	if LDEBUG then
		LOG:debug(LTAG, "stage - actStage")
	end
	sortA(data)
	local ch = Class.activeChar(data)
	if ch.AP>=ACT_AP then
		data.rt.turn = data.rt.turn + 1
		data.stage = "charBegin"
		Class.event(data, {
			k="turn",
			v=data.rt.turn
		})
	else
		data.stage = "pollStage"
	end
	return true
end

function Class.charBegin( data )
	local ch = Class.activeChar(data)
	if LDEBUG then
		LOG:debug(LTAG, "stage - charBegin - %s, %d", ch.id, data.rt.turn)
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
	local fstun = ch.FLAG_STUN
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
		k="char",
		MID=ch.id,
		data=view,
	})

	-- AI action
	local doact = true
	if fstun~=nil and fstun>0 then
		doact = false
	end
	if doact then
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
	end
	if data.stage == "charBegin" then
		data.stage = "charEnd"
	end
	return true
end

function Class.charEnd( data )
	local aid = data.rt.aorder[1]
	if LDEBUG then
		LOG:debug(LTAG, "stage - charEnd - %s, %d", aid, data.rt.turn)
	end	
	local ch = data.rt.chars[aid]
	ch.AP = ch.AP - ACT_AP
	Class.event(data, {k="nextc"})

	data.stage = "actStage"
	return false
end

function Class.combatEnd( data )
	if LDEBUG then
		LOG:debug(LTAG, "stage - combatEnd - %d", data.rt.turn)
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
function Class.performSpell(data, cmd)
	local spid = cmd.spellId
	local sp = data.rt.spells[spid]
	if sp==nil then
		error(string.format("invalid spell '%s'", spid))
	end
	
	local spp = class.forName(sp._p)
	if spp.doPerform(Class, data, sp) then
		local vsp = {}
		Class.copySpellView(vsp, sp)
		Class.event(data, {k="spell", SID=sp.id, data=vsp})
	end
	return true
end

local DMGS = {	
	{"pdmg",  "PARMOR"},
	{"edmgp", "EPARMOR"},
	{"edmgf", "EFARMOR"},
	{"edmgw", "EWARMOR"},
	{"edmge", "EEARMOR"}
}

function Class.doAttack(data, sch, tch, dmg)
	if type(dmg)~="table" then
		dmg = {pdmg=dmg}
	end
	local w = WORLD
	local r = {hited=true}
	local d = tch.DODGE*10000
	local rd = math.random(10000)
	if LDEBUG then
		LOG:debug(LTAG, "dodgecheck, %s:%s, %d/%d", sch.id, tch.id, rd, d)
	end
	if rd<d then
		if LDEBUG then
			LOG:debug(LTAG, "dodge, %s:%s", sch.id, tch.id)
		end
		r.hited = false
		r.dodge = true
		return r
	end
	local a = tch.ARMOR
	local rdmg = 0
	for i, dmgtype in ipairs(DMGS) do
		local dv = dmg[dmgtype[1]]
		if dv~=nil then
			if a>0 then
				dv = (1-a)*dv
			end
			local ar = tch[dmgtype[2]]
			if ar~=nil then
				dv = (1-ar)*dv
			end
			if i==1 then
				dv =  dv - tch.DEF
				if dv<1 then dv = 1 end
			end
			if dv>0 then
				r[dmgtype[1]] = dv
			end
			rdmg = rdmg + dv
		end
	end
	rdmg = math.floor(rdmg)
	if LDEBUG then
		LOG:debug(LTAG, "damage, %s:%s, %d/%d, %d", sch.id, tch.id, dmg.pdmg, a*100, rdmg)
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
	Class.event(data, 
		{
			k="die",
			MID=ch.id
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