-- adventure/ui/Area.lua
local Class = class.define("adventure.ui.Area", {"world.UIControl"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "UI.adv.Area"

local M = class.forName("adventure.Manager")

function Class.updateView()
	-- body
end

-- entry
function Class.enterArea(region, area)
	local w = WORLD
	local ctx = {
		pos = 1,
		data = {},
		region = {}	
	}
	table.copy(ctx.data, area, true)
	table.copy(ctx.region, region, true)

	local view = {}
	if w:changeView("adv_area",view,"adventure.ui.Area", ctx) then
		Class.updateView()
	end
end