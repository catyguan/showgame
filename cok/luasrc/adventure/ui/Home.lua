-- adventure/ui/Home.lua
require("bma.lang.ext.Table")

local Class = class.define("adventure.ui.Home", {"world.UIControl", "ui.Menu"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "UI.adv.home"

local M = class.forName("adventure.Manager")

--[[
viewdata {
	regions : [
		{id=xxx, title=xxxx, pic=xxxxx, ...},
		...
	]
}
context {
	regions : [
		{
			id=xxx, _p=xxxx, data={title=xxxx, pic=xxxx, }},

		}
	]
}
]]
function Class.doSelect(ctx, id)
	local o = WORLD
	local list = ctx.regions
	local sopt = nil
	local sidx = tonumber(id)
	sopt = list[sidx]
	if sopt==nil then
		if LDEBUG then
			LOG:debug(LTAG, "select region(%s) invalid", id)
		end
		return
	end
	if LDEBUG then
		LOG:debug(LTAG, "select region %s", id)
	end

	local cls = class.forName(sopt._p)
	cls.beginRegion(cls, sopt.data)
end

-- entry
function Class.enterHome()
	local rgs = M.queryRegions()
	local ctxrgs = {}
	table.copy(ctxrgs, rgs, true)

	local w = WORLD
	local ctx = {
		regions = ctxrgs,
	}
	local view = {
		regions = {},
	}
	-- build view from regions
	for i,rg in ipairs(rgs) do
		local vrg = {}
		local rgd = rg.data

		vrg.id = i
		vrg.title = rgd.title
		vrg.pic = rgd.pic
		if vrg.pic==nil then
			vrg.pic = "images/".. rgd.terrain..".png"
		end
		vrg.size = rgd.size
		vrg.difficult = rgd.difficult
		vrg.faction = rgd.faction
		table.insert(view.regions, vrg)
	end
	w:changeView("adv_home",view,"adventure.ui.Home", ctx)
end