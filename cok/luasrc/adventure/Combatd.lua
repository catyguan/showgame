-- adventure/Combatd.lua
require("bma.lang.ext.Table")

local Class = class.define("adventure.Combatd")

local LDEBUG = LOG:debugEnabled()
local LTAG = "AdvCombatd"
local IDS = 1

function Class.newCombat()
	local data ={
		stage = "begin",
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

local nextId = function(pre)
	local r = pre .. IDS
	IDS = IDS + 1
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
	data.rt.chars[cid] = charObj
	
	local chp = class.forName(charObj._p)
	local chpro = chp.getProfile(charObj)
	chpro.id = cid
	data.profile.chars[cid] = chpro
	if charObj.skills then
		for _, sk in ipairs(charObj.skills) do
			if sk.id==nil then
				sk.id = sk._p
			end
			if not data.profile.skills[sk.id] then
				local skp = class.forName(sk._p)
				local skpro = skp.getProfile(sk)
				skpro.id = sk.id
				data.profile.skills[sk.id] = skpro
			end
		end
	end
	if charObj.effects then
		for _, ef in ipairs(charObj.effects) do
			if ef.id==nil then
				ef.id = ef._p
			end
			if not data.profile.effects[ef.id] then
				local efp = class.forName(ef._p)
				local efpro = efp.getProfile(ef)
				efpro.id = ef.id
				data.profile.effects[ef.id] = efpro
			end
		end
	end
end

function Class.event( data, ev )
	if data.events == nil then data.events = {} end
	data.rt.eid = data.rt.eid + 1
	ev.id = data.rt.eid	
	table.insert(data.events, ev)
	var_dump(data.events)
end

function Class.process(data)
	for i=1,1000 do
		local f = Class[data.stage]
		if f==nil then
			error(string.format("invalid stage[%s]", data.stage))
		end
		local doNext = f(data)
		if not doNext then
			break
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
	Class.event(data, {k="msg", msg="hello world"})
	-- Class.event(data, {k="p"})
	return false
end

-- init view
function Class.buildInit(data, ev)
	local view = {}	
	view.turn = data.rt.turn	
	view.APS = data.rt.APS
	view.aorder = {}
	local j = data.rt.order
	for i=1,#data.rt.aorder do
		table.insert(view.aorder, data.rt.aorder[j])
		j = j + 1
		if j > #data.rt.aorder then j = 1 end
	end
	table.copy(view.aorder, data.rt.aorder, false)
	view.chars = {}
	for k,ch in pairs(data.rt.chars) do
		local vch = {}
		vch.id = ch.id
		vch.HP = ch.HP
		vch.ATK = ch.ATK
		vch.DEF = ch.DEF
		vch.SKL = ch.SKL
		vch.AGI = ch.AGI
		vch.SHD = ch.SHD
		vch.team = ch.team
		vch.pos = ch.pos
		-- skills
		vch.skills = {}
		for _,sk in ipairs(ch.skills) do
			local sko = {}
			sko.id = sk.id
			table.insert(vch.skills, sko)
		end
		-- effects
		vch.effects = {}
		if ch.effects then
			for _,ef in ipairs(ch.effects) do
				local efo = {}
				local efp = class.forName(ef._p)
				efo.id = ef.id
				efp.copyViewData(efo, ef)
				table.insert(vch.effects, efo)
			end
		end
		view.chars[k] = vch
	end

	local profile ={}
	table.copy(profile, data.profile, true)

	ev.view = view
	ev.profile = profile
	return ev
end

function Class.activeChar(data)
	local cid = data.rt.aorder[data.rt.order]
	return data.rt.chars[cid]
end

-- inner flow
local sortA = function(data)
	local id = ""
	if data.rt.order>0 then
		id = data.rt.aorder[data.rt.order]
	end
	table.sort(data.rt.aorder, function(e1,e2)
		local c1 = data.rt.chars[e1]
		local c2 = data.rt.chars[e2]
        return c1.AGI > c2.AGI
    end)
    if id~="" then
	    for i,ch in ipairs(data.rt.aorder) do
	    	if ch==id then
	    		data.rt.order = i
	    		break
	    	end
	    end
	end
end

function Class.begin(data)
	data.rt.turn = 1
	data.rt.eid = 1
	data.rt.APS = 0
	for k,ch in pairs(data.rt.chars) do
		table.insert(data.rt.aorder, k)
	end
	data.rt.order = 0
	sortA(data)
	data.rt.order = 1

	local o = WORLD
	o:createView("adv_combat", {}, "adventure.ui.Combat",data)
	data.stage = "turnBegin"
	return true
end

function Class.turnBegin( data )
	data.stage = "charBegin"
	return true
end

function Class.charBegin( data )
	local ch = Class.activeChar(data)
	if ch.team==1 then
		Class.event(data, {k="cmd"})
		return false
	end
	data.stage = "charEnd"
	return true
end

function Class.charEnd( data )
	data.stage = "turnEnd"
	return true
end

function Class.turnEnd( data )
	data.stage = "turnBegin"
	return true
end

-- map
--[[
B<4><5><6>
B<1><2><3>
**********
A<1><2><3>
A<4><5><6>
]]