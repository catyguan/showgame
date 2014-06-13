-- ui/Menu.lua
local Class = class.define("ui.Menu")

local LTAG = "UI.Menu"

function Class.doMenuAdv(ctx)
	local m = class.forName("adventure.ui.Home")
	m.enterHome()	
	return 0
end

function Class.doMenuHome(ctx)
	local w = WORLD
	w:changeView("home", {}, "ui.Home", {})
	return 0
end