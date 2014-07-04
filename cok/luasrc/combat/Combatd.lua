-- combat/Combatd.lua
require("bma.lang.ext.Table")

local Class = class.define("combat.Combatd")

local LDEBUG = LOG:debugEnabled()
local LTAG = "Combatd"
local IDS = 1

--[[
team = {
	auto:true,
	aorder:[id,id,...],
	troops:[ch,ch,...]
	chars:{id:ch....}
}
]]
function Class.newCombat()
	local data ={
		stage = "combatBegin",
		actTeam = 0,
		actChar = 0,
		team = {
			{},{}
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

function Class.listByTeam(data, teamId, returnObj)
	local r = {}
	local chs = data.team[teamId].chars
	for cid, ch in pairs(chs) do
		local v = ch
		if not returnObj then v = ch.id end
		table.insert(r, v)
	end
	return r
end

local NC = function(charObj)
	local cls = class.forName(charObj._p)

	local ch = cls.newChar(charObj.star, charObj.level)
	ch._p = charObj._p
	ch.star = chaObj.star
	ch.level = charObj.level
	ch.pos = charObj.pos
	ch.hero = charObj.hero
	if charObj.id then
		ch.id = charObj.id
	else
		ch.id = nextId("c")
	end
	return ch
end

function Class.newTeam(data, teamId, pteam)
	local team = data.team[teamId]
	team.auto = pteam.auto
	team.aorder = {}

	team.troops = {}
	if pteam.troops then
		for _,charObj in ipairs(pteam.troops) do
			local ch = NC(charObj)
			table.insert(team.troops, ch)	
		end
	end

	if pteam.chars then
		for _,charObj in ipairs(pteam.chars) do
			Class.newChar(data, teamId, charObj)			
		end
	end
end

function Class.newChar(data, teamId, charObj)
	local ch = NC(charObj)
	Class.addChar(data, teamId, ch)
end

function Class.addChar(data, teamId, charObj)
	local cid = charObj.id
	local team = data.team[teamId]
	if team.chars[cid] then
		error(string.format("'%s' exists"), cid)
	end
	chkset(charObj, "MAXHP", "HP")
	chkset(charObj, "BASE_HP", "MAXHP")
	chkset(charObj, "BASE_ATK", "ATK")
	chkset(charObj, "BASE_DEF", "DEF")
	
	team.chars[cid] = charObj

	if charObj.skills then
		for _, sk in ipairs(charObj.skills) do
			if sk.id==nil then
				sk.id = nextId("s")
			end
		end
	end
	if charObj.effects then
		for _, ef in ipairs(charObj.effects) do
			if ef.id==nil then
				ef.id = nextId("e")
			end
		end
	end

	table.insert(team.aorder, cid)
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
	-- elseif n=="AGI"	 then
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

function Class.applyEffect(data, tch,ch, eff)
	if not eff.id then eff.id = eff._p end
	if not ch.effects then ch.effects = {} end
	if eff.unique then
		for i, old in ipairs(ch.effects) do
			if old._p == eff._p then
				tch.remove(Class,data, eff, ch)
				table.remove(ch.effects, i)
				break
			end
		end
	end
	table.insert(ch.effects, eff)
	tch.apply(Class, data, eff, ch)
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
	data.eid = data.eid + 1
	ev.id = data.eid	
	table.insert(data.events, ev)
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
	desc.star = src.star
	des.level = src.level
	des.title = src.title
	des.HP = src.HP
	des.MAXHP = src.MAXHP
	des.ATK = src.ATK
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

-- init view
local HProfile
HProfile = function(proset, obj)
	if not proset[obj.id] then
		local cls = class.forName(obj._p)
		if cls.getProfile then
			local pro = cls.getProfile(obj)
			pro.id = obj.id
			proset[pro.id] = pro
		end
		if skp.listRelProfile then
			local rel = skp.listRelProfile()
			if rel then
				for _,nobj in ipairs(rel) do
					HProfile(proset, nobj)
				end
			end
		end
	end
end
local HCHAR = function(view, proset, ch)
	local vch = {}
	Class.copyCharView(vch, ch)
	view.chars[k] = vch
	HProfile(proset, ch)

	if ch.skills then
		for _,sk in ipairs(ch.skills) do
			HProfile(proset, sk)
		end
	end

	if ch.effects then
		for _,ef in ipairs(ch.effects) do
			HProfile(proset, ef)
		end
	end
end
function Class.buildInit(data, ev)
	local proset = {}
	local view = {}
	view.turn = data.turn
	view.chars = {}

	for _,ch in ipairs(data.team[1].chars) do
		HCHAR(view, proset, ch)
	end
	for _,ch in ipairs(data.team[2].chars) do
		HCHAR(view, proset, ch)
	end

	ev.view = view
	ev.profile = proset
	return ev
end

-- inner flow
function Class.prepare(data)
	data.turn = 0
	data.eid = 1
	local o = WORLD
	o:createView("adv_combat", {}, "adventure.ui.Combat", data)
end

function Class.combatBegin(data)	
	data.stage = "turnBeginStage"
	return true
end

function Class.turnBeginStage(data)
	data.turn = data.turn + 1
	if LDEBUG then
		LOG:debug(LTAG, "stage - turnBegin - %d", data.turn)
	end	
	Class.event(data, {
		k="turn",
		v=data.turn
	})

	data.actTeam = 0
	data.actChar = 0	
	data.stage = "teamBeginStage"
	return true
end

function Class.teamBeginStage(data)
	if data.actTeam==0 then
		data.actTeam = 2
	else
		data.actTeam = Class.opTeam(data.actTeam)
	end
	if LDEBUG then
		LOG:debug(LTAG, "stage - teamBegin - %d", data.actTeam)
	end
	Class.event(data, {
		k="active", team=data.actTeam
	})

	local team = data.team[data.actTeam]
	if not team.auto then
		Class.event(data, {
			k="cmd"
		})
		return false		
	end
	data.stage = "aiPlayStage"
	return true
end

function Class.aiPlayStage( data )
	if LDEBUG then
		LOG:debug(LTAG, "stage - aiPlayStage - %d", data.actTeam)
	end
	-- if 
	return true
end

function Class.actStage(data)
	if LDEBUG then
		LOG:debug(LTAG, "stage - actStage")
	end
	sortA(data)
	local ch = Class.activeChar(data)
	if ch.AP>=ACT_AP then
		data.turn = data.turn + 1
		data.stage = "charBegin"
		Class.event(data, {
			k="turn",
			v=data.turn
		})
	else
		data.stage = "pollStage"
	end
	return true
end

function Class.charBegin( data )
	local ch = Class.activeChar(data)
	if LDEBUG then
		LOG:debug(LTAG, "stage - charBegin - %s, %d", ch.id, data.turn)
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
	Class.copyCharView(view, ch)
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
		aicls.doAI(Class, data, aicls, ch)
	end
	if data.stage == "charBegin" then
		data.stage = "charEnd"
	end
	return true
end

function Class.charEnd( data )
	local aid = data.aorder[1]
	if LDEBUG then
		LOG:debug(LTAG, "stage - charEnd - %s, %d", aid, data.turn)
	end	
	local ch = data.chars[aid]
	ch.AP = ch.AP - ACT_AP
	Class.event(data, {k="nextc"})

	data.stage = "actStage"
	return false
end

function Class.combatEnd( data )
	if LDEBUG then
		LOG:debug(LTAG, "stage - combatEnd - %d", data.turn)
	end
	Class.event(data, {k="end", winner=data.winner})
	return false
end

function Class.getCombatResult(data)
	local r = {
		team1 = {},
		team2 = {},
		spells = {}
	}
	for k,sp in pairs(data.spells) do
		local o = {}
		o._p = sp._p
		o.num = sp.num
		table.insert(r.spells, o)
	end
	for k, cch in pairs(data.chars) do
		if cch.team==1 then
			table.insert(r.team1, cch)
		else
			table.insert(r.team2, cch)
		end
	end
	if #r.team1>0 and #r.team2>0 then return end
	if #r.team1==0 then
		r.winner = 2
	else
		r.winner = 1
	end
	return r
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
	local sp = data.spells[spid]
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

function Class.doAttack(data, schc,sch, tchc,tch, dmg)
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

function Class.doDie(data, chc,ch)
	-- clear effects
	-- call skills
	data.chars[ch.id] = nil
	for i,cid in ipairs(data.aorder) do
		if cid==ch.id then
			table.remove(data.aorder, i)
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
	for k, cch in pairs(data.chars) do
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