-- roguelike/combat/Combatd.lua
require("bma.lang.ext.Table")

local Class = class.define("roguelike.combat.Combatd")

local LDEBUG = LOG:debugEnabled()
local LTAG = "Combatd"
local IDS = 1

local ME 	= 1
local FOE 	= 2

--[[
team = {
	auto:true,
	players : [
		{
			id : 1,
			_p : xxxx,
			HP : 15,
			MAXHP : 15,
			BASE_HP : 15,
			AP : 2,
			MAXAP : 2,
			BASE_AP : 15,
			SP : 5,

			cards : {
				id : {
					id : xxxx,
					_p : xxxx,
					kind : xxxx,
					<card runtime properties>
				},
				...
			},
			setDesk : [cardId...],
			setDiscard : [cardId...],
			setHand : [cardId...],	
			setField : [cardId...],

			effects : {
				id : {
					id : xxxx,
					_p : xxxx,
					[uqid : yyyy],
					<effect runtime properties>
				},
				...
			},

			skills : {
				id : {
					id : xxxx,
					_p : xxxx,
					<skill properties>
				}
			}
		},
		{ ... }
	]
}
]]
function Class.newCombat()
	local data ={
		stage = "combatBegin",
		actPlayer = 0,
		players = {{},{}},

		eid = 0,
	}
	return data
end

local nextId = function(pre)
	local r = pre .. IDS
	IDS = IDS + 1
	return r
end

function Class.nextId(pre)
	return nextId(pre)
end

function Class.opposePID(pid)
	if tid==1 then return 2 end
	return 1
end

local chkset = function(obj, n1, n2)
	if obj[n1]==nil then obj[n1] = obj[n2] end
end

function Class.newCard(this, plid, cddata)
	local cls = class.forName(pldata._p)

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

function Class.newPlayer(this, plid, pldata)
	local cls = class.forName(pldata._p)

	local pl = cls.newChar(pldata)
	pl._p = pldata._p	
	if pl.cards then
		local tmp = {}
		for _,cd in ipairs(pl.cards) do
			cd.id = nextId("c")
			tmp[cd.id] = cd
		end
		pl.cards = tmp
	end
	if pl.effects then
		local tmp = {}
		for _,sk in ipairs(pl.effects) do
			sk.id = nextId("e")
			tmp[sk.id] = sk
		end
		pl.effects = tmp
	end
	if pl.skills then
		local tmp = {}
		for _,sk in ipairs(pl.skills) do
			sk.id = nextId("s")
			tmp[sk.id] = sk
		end
		pl.skills = tmp
	end
	pl.setDesk = {}
	pl.setDiscard = {}
	pl.setHand = {}
	pl.setField = {}
	return pl
end

function Class.addPlayer(this, plid, pl)

	chkset(pl, "MAXHP", "HP")
	chkset(pl, "BASE_HP", "MAXHP")
	chkset(pl, "MAXAP", "AP")
	chkset(pl, "BASE_AP", "AP")
		
	pl.id = plid
	this.players[plid] = pl

end

function Class.setProp(this, pl, n, v)
	if n=="HP" then
		local mv = pl.MAXHP
		if v>mv then v=mv end
	end
	if n=="AP" then
		local mv = pl.MAXAP
		if v>mv then v=mv end
	end
	if v<0 then
		v = 0
	end
	pl[n] = v
	return v
end

function Class.modifyProp(this, pl, n, v)
	local old = pl[n]
	return Class.setProp(this, pl, n, old+v)
end

function Class.hasEffect(this, pl, uqid)
	if pl.effects then
		for _, old in pairs(ch.effects) do
			if old.uqid == uqid then
				return true
			end
		end
	end
	return false
end

function Class.applyEffect(this, pl, eff)
	if not eff.id then eff.id = nextId("e") end
	if not pl.effects then pl.effects = {} end

	if eff.unique then
		for _, old in pairs(pl.effects) do
			if old._p == eff._p then
				Class.removeEffect(this, plid, old.id)
				break				
			end
		end
	end
	pl.effects[eff.id] = eff

	local effcls = class.forName(eff._p)
	effcls.apply(effcls, this, pl)
end

function Class.removeEffect(this, pl, id)
	if not pl.effects then return false end
	local eff = pl.effects[id]
	if not eff then return false end

	local effcls = class.forName(eff._p)
	effcls.remove(eff, this, pl)
	pl.effects[id] = nil	
	return true
end

function Class.applyFlag(this, pl, n)
	local v = pl[n]
	if v==nil then
		v = 1
	else
		v = v + 1
	end
	pl[n] = v
end

function Class.removeFlag(this, pl, n)
	local v = pl[n]
	if v~=nil then
		v = v - 1
		if v<=0 then
			pl[n] = nil
		else
			pl[n] = v
		end
	end
end

function Class.event(this, ev)
	if this.events == nil then this.events = {} end
	if this.eventg~=nil and #this.eventg>0 then
		local eg = this.eventg[#this.eventg]
		table.insert(eg.es, ev)
		return
	end
	this.eid = this.eid + 1
	ev.id = this.eid	
	table.insert(this.events, ev)
end

function Class.eventBegin(this, eid)
	if this.eventg == nil then this.eventg = {} end
	table.insert(this.eventg, {id=eid, es={}})
end

function Class.eventCommit(this, eid, ev)
	local eg
	if this.eventg~=nil and #this.eventg>0 then
		eg = this.eventg[#this.eventg]		
	end
	if not eg then
		error("event commit fail, eventg empty")
	end
	if eg.id~=eid then
		error(string.format("event commit fail, id not same, %s - %s", eg.id, eid))
	end
	table.remove(this.eventg, #this.eventg)
	if ev~=nil then
		Class.event(this, ev)
	end
	for _,lev in ipairs(eg.es) do
		Class.event(this, lev)
	end
end

function Class.process(this)
	for i=1,100 do
		local f = Class[this.stage]
		if f==nil then
			error(string.format("invalid stage[%s]", this.stage))
		end		
		local doNext = f(this)
		if not doNext then
			return
		end
	end
	if LDEBUG then
		LOG:debug(LTAG, "process loop end")
	end
end

function Class.handleUserCommand(this, cmd)
	if data.stage=="combatEnd" then
		Class.event(this, {k="err", msg="::已结束"})
		return false
	end
	if cmd.act=="spell" then
		return Class.performSpell(this, cmd)
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

function Class.buildInit(this, ev)
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
	o:createView("combat", {}, "roguelike.combat.ui.Combat", data)
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