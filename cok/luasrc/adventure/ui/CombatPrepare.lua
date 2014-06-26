-- adventure/ui/CombatPrepare.lua
require("bma.lang.ext.Table")
local Class = class.define("adventure.ui.CombatPrepare", {"world.UIControl"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "UI.adv.CombatPrepare"

local M = class.forName("adventure.Manager")

--[[
viewdata {
	opts : {
	
	},
	et : {
		groups : [
			{id=xxx, title=xxxx, pic=xxxxx, ...},
			...
		]
	},
	mt {
		team : [
			{...},
		],
		wagon : [
			{id=xxx, ....}
		],
	}
}
context {
	opts : {
		teamType : 6,9
	},
	et : {
		groups : [
			-- group 1
			{ -- char -- }
		],

	},
	mt : {
		team = [
			{...}
		]
	}
}
]]
function Class.uiEnter(opts, emenyTeam, myGroup, myWagon)
	local w = WORLD
	local mw = myWagon
	if mw==nil then
		mw = M.getWagon()
	end
	local ctx = {
		opts = {},
		et = {},
		mt = {
			team = {},
			wagon = {}
		}
	}

	table.copy(ctx.opts, opts, true)
	table.copy(ctx.et, emenyTeam, true)	
	if myGroup~=nil then
		table.copy(ctx.mt.team, myGroup, true)
	end
	table.copy(ctx.mt.wagon, mw, true)

	local view = Class.buildView(ctx)	
	w:changeView("adv_combatp",view,"adventure.ui.CombatPrepare", ctx)
end

local buildCharView = function(ch, ids)
	local chc = class.forName(ch._p)			
	local vch = chc.newChar(ch.level)
	vch.level = ch.level
	if ch.id then
		vch.id = ch.id
	else
		vch.id = "c" .. ids
		ids = ids + 1
	end	
	if ch.prop~=nil then
		for k,v in pairs(ch.prop) do
			vch[k] = v
		end
	end
	local pro = chc.getProfile()
	if vch.title==nil then
		vch.title = pro.title
	end
	vch.pic = pro.pic
	local vsks = {}
	if vch.skills~=nil then
		for _,sk in ipairs(vch.skills) do
			local skc = class.forName(sk._p)
			local skp = skc.getProfile(sk)
			local vsk = {}
			vsk.title = skp.title
			vsk.desc = skp.desc
			vsk.CD = skp.CD
			table.insert(vsks, vsk)
		end
		vch.skills = vsks
	end
	return vch, ids
end

function Class.buildView(ctx)
	local r = {
		opts = {},
		et = {},
		mt = {}
	}
	local ids = 1
	r.opts.teamType = ctx.opts.teamType
	r.et.groups = {}
	for _,gp in ipairs(ctx.et.groups) do
		local vgp = {}
		vgp.chars = {}
		for _, ch in ipairs(gp.chars) do
			local vch
			vch, ids = buildCharView(ch, ids)
			vch.team = 2
			table.insert(vgp.chars, vch)
		end
		table.insert(r.et.groups, vgp)
	end

	if true then
		local gp = ctx.mt.team
		local vgp = {}
		vgp.chars = {}
		for _, ch in ipairs(gp.chars) do
			local vch
			vch, ids = buildCharView(ch, ids)
			vch.team = 1
			table.insert(vgp.chars, vch)
		end
		r.mt.team = vgp
	end

	if true then
		local gp = ctx.mt.wagon
		local vgp = {}
		vgp.chars = {}
		for i, ch in ipairs(gp.chars) do
			local vch
			vch, ids = buildCharView(ch, ids)
			vch.team = 3
			table.insert(vgp.chars, vch)
		end
		r.mt.wagon = vgp
	end

	return r
end

-- ui action
function Class.onMain()

end


