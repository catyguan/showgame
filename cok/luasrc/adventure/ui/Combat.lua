-- adventure/ui/Combat.lua
local Class = class.define("adventure.ui.Combat", {"world.UIControl"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "UI.adv.Combat"

--[[
view {
	eid = ,
	chars : [ id ... ],
	APS=
}
profile {
	chars : {
		[cid] : {
			id="xxxx",title="xxxx",pic="xxxx"
			HP=,ATK=,DEF=,SHD=,SKL=,
			team=,pos=,
			<char info ....>
		}
	},
	skills : {
		[sid] : {
			<skill info ...>
		}
	},
}
context {
	
}
]]