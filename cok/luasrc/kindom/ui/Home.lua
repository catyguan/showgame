-- kindom/ui/Home.lua
require("bma.lang.ext.Table")

local Class = class.define("kindom.ui.Home", {"world.UIControl", "ui.Menu"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "UI.kindom.home"

local M = class.forName("kindom.Manager")
local F = class.forName("world.Faction")

--[[
viewdata {
	info : {
		title : xxxx,
		tribe : {
			id : xxx,
			title : xxx,
		},
		faction : {
			id : xxxx,
			title : xxxxx,
		},
		resources : [
			id: {v=xxx, m=xxx}
			...
		],
	},
	
	buildings=[
		{
			"id":"xxx",
			"title":"xxxx",
			"pic":"xxxx",
			"kind":"xxxx",
			....
		},
		...
	]
}
context {
}
]]
function Class.doSelectTown(ctx, p)
	local tid = p.id
	Class.enterTown(tid)
end

function Class.buildInfo(vinfo)
	if not vinfo.resources then vinfo.resources ={} end
	if not vinfo.tribe then vinfo.tribe = {} end
	if not vinfo.faction then vinfo.faction = {} end

	local info = M.getInfo()
	vinfo.title = info.title
	local faction = F.getFaction(info.faction)
	vinfo.tribe.id = faction.TRIBE.id
	vinfo.tribe.title = faction.TRIBE.name
	vinfo.faction.id = faction.PROFILE.id
	vinfo.faction.title = faction.PROFILE.name

	local resl = M.getResources()
	for k,res in pairs(resl) do
		local vres = {}
		vres.v = res.v
		vres.m = res.m
		vinfo.resources[k] = vres
	end

end

-- entry
function Class.enterTown(tid)
	local w = WORLD

	local view = {
		info = {},		
		towns = {},
		buildings={}
	}
	local ctx = {}

	local vinfo = view.info
	Class.buildInfo(vinfo)

	local towns = M.getTowns()
	local vtowns = view.towns
	local town
	for k,to in pairs(towns) do
		if not tid and to.capital then
			tid = to.id
		end
		if tid==to.id then town = to end
		local vto = {}
		vto.id = to.id
		vto.title = to.title
		table.insert(vtowns, vto)
	end

	vblist = view.buildings
	local blist = M.getBuildings()
	if blist then
		for _,b in ipairs(blist) do
			local bc = class.forName(b._p)
			local bp = bc.PROFILE
			local vb = {}
			vb.id = b.id
			vb.level = b.level
			vb.title = bp.name
			vb.pic = bp.pic
			if bc.buildView then
				bc.buildView(b, vb, false);
			end
			table.insert(vblist, vb)
		end
	end

	w:changeView("kindom_home",view,"kindom.ui.Home", ctx)
end