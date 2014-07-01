-- adventure/ui/CombatPrepare.lua
require("bma.lang.ext.Table")
local Class = class.define("adventure.ui.CombatPrepare", {"world.UIControl"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "UI.adv.CombatPrepare"

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
]]
function Class.uiEnter()
	local w = WORLD
	local ctx = w:prop({"adv", "combat"})
	local wagon = w:prop({"adv", "wagon"})
	local view = Class.buildView(ctx, wagon)	
	w:createView("adv_combatp",view, Class.className, {})
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
	vch.team = ch.team
	vch.pos = ch.pos
	vch.fixed = ch.fixed
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

function Class.buildView(ctx, wagon)
	local r = {
		opts = {},
		et = {},
		mt = {}
	}
	local ids = 1
	r.opts.teamMax = V(ctx.opts.teamMax, 5)
	r.opts.backupTeam = ctx.opts.backupTeam
	r.et.groups = {}
	for _,gp in ipairs(ctx.emenyTeam.groups) do
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
		local gp = ctx.team
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
		local vgp = {}
		vgp.chars = {}

		local gp = ctx.wagon
		if gp~= nil then		
			for i, ch in ipairs(gp.chars) do
				local vch
				vch, ids = buildCharView(ch, ids)
				vch.team = 3
				table.insert(vgp.chars, vch)
			end
		end
		local gp = wagon
		if gp~= nil then		
			for i, ch in ipairs(gp.chars) do
				local vch
				vch, ids = buildCharView(ch, ids)
				vch.team = 3
				table.insert(vgp.chars, vch)
			end
		end
		r.mt.wagon = vgp
	end

	return r
end

-- ui action
function Class.doSetup(ctx, p)
	local M = class.forName("adventure.Manager")
	M.setupCombat(p.team)
	M.flowProcess()
end


