-- ui/Home.lua
local Class = class.define("ui.Home", {"world.UIControl"})

local LTAG = "UI.home"

function Class.onClose()
	LOG:warn(LTAG, "can't close 'home' view")
	return false
end

function Class.doTest()
	return {1,2,3}
end