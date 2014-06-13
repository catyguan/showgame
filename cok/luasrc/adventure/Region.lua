-- adventure/Region.lua
require("bma.lang.ext.Table")

local Class = class.define("adventure.Region")

local LDEBUG = LOG:debugEnabled()
local LTAG = "AdvRegion"

--[[
title:string
pic:string
desc:string
difficult:int
size:int
terrain: stringEnum
faction: string[]
onEntr:PDCode
onLeave:PDCode
]]

function Class.hasFaction(data, fac)
	if data.faction~=nil then
		for _, vfac in ipairs(data.faction) do
			if vfac==fac then return true end
		end
	end
	return false
end

function Class.beginRegion(cls, data)
	local pds = data.onEnter	
	if pds~=nil then
		pdcall(pds)
	end

	local area = cls.firstArea()
	cls.enterArea(cls, data, area)
end

function Class.firstArea(cls, data, area)
	return {}
end

function Class.enterArea(cls, data, area)
	local ui = class.forName("adventure.ui.Area")
	ui.enterArea(data, area)
end

function Class.endRegion(cls, data)
	local pds = data.onLeave
	if pds~=nil then
		pdcall(pds)
	end
end