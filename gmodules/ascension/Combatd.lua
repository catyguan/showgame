-- ascension/Combatd.lua
require("bma.lang.Class")
require("service.PDCall")

local Class = class.define("ascension.Combatd", {"bma.lang.StdObject", "ui.UIEvents", "ui.UITips", "ascension.Const"})
local CSET = class.forName("ascension.CardSet")

local LDEBUG = LOG:debugEnabled()
local LTAG = "Ascension"

local PROP = {"ascension"}

--------------------------------
function Class:ctor()
	self:prop("sid", 1)
	self:prop("idSeq", 1)
end

function Class:SID()
	local sid = self:prop("sid")
	sid = sid + 1
	self:prop("sid", sid)
	return sid
end

function Class:nextId(pre)
	local ids = self:prop("idSeq")
	local r = pre .. ids
	self:prop("idSeq", ids+1)
	return r
end

function Class.toCombatd(w)
	return w:prop(PROP)
end

function Class:world()
	local wid = self:prop("wid")
	local wm = WORLD_MANAGER
	return wm:getWorld(wid)
end

function Class:player(pid)
	if pid==Class.ME then
		return self:prop("me")
	else
		return self:prop("enemy")
	end
end

function Class:run(w, data)
	self:prop("data", data)
	
	w:prop(PROP, self)
	self:prop("wid", w.id)

	self:start()

	local vo = class.new("ascension.ui.Main")
	w:createView("ascension_main", vo)
end

--------------------------
function Class.opTeam(tid)
	if tid==1 then return 2 end
	return 1
end

function Class:process()
	for i=1,100 do
		local stage = self:prop("stage")
		local f = self[stage]
		if f==nil then
			error(string.format("invalid stage[%s]", stage))
		end		
		local doNext = f(self)
		if not doNext then
			return
		end
	end
	if LDEBUG then
		LOG:debug(LTAG, "process loop end")
	end
end

function Class:handleUserCommand(cmd)
	local stage = self:prop("stage")
	if stage=="combatEnd" then
		Class:uiEvent({t="err", msg="::已结束"})
		return false
	end
	if cmd.act=="spell" then
		return Class:performSpell(cmd)
	end
	self:uiEvent({t="err", msg="::无效操作"})
	return false
end

---------------------------
function Class.cardClass(p)
	if p:sub(1,1)=="@" then p = "ascension.card."..p:sub(2) end
	return class.forName(p)
end
function Class:newCard(cdata)
	local ccls = Class.cardClass(cdata._p)
	local o = ccls.new(cdata)
	o:prop("id", self:nextId("c"))
	return o
end

-- inner flow
local newMod = function(self, data)
	local mcls = class.forName(data._p)
	local obj = mcls.new(data)	
	local ddata = data.desk
	local desk = {}
	for _,cdata in ipairs(ddata) do
		local num = V(cdata.num, 1)
		for i=1,num do
			local card = self:newCard(cdata)
			table.insert(desk, card)
		end		
	end
	local sets = {}
	sets[Class.SET_DESK] = desk
	sets[Class.SET_DISCARD] = {}
	sets[Class.SET_SIDE] = {}
	sets[Class.SET_PLAY] = {}
	sets[Class.SET_HAND] = {}
	obj:prop("sets", sets)
	return obj
end

function Class:start()
	local data = self:prop("data")
	local mobj = newMod(self, data.me)
	mobj:prop("who", "Me")
	self:prop("me", mobj)
	local eobj = newMod(self, data.enemy)
	eobj:prop("who", "Enemy")
	self:prop("enemy", eobj)

	mobj:onCombatInit(self)	
	eobj:onCombatInit(self)

	local list = {mobj, eobj}
	for _,obj in ipairs(list) do
		local desk = obj:getSet(Class.SET_DESK)		
		CSET.shuffle(desk)
		obj:doDrawHand(self)

		local hand = obj:getSet(Class.SET_HAND)
		local c1 = hand[1]
		local play = obj:getSet(Class.SET_PLAY)
		table.insert(play, c1)		
	end

	self:prop("stage", "turnBeginStage")
	self:prop("turn", 1)
	self:prop("player", Class.ME)
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