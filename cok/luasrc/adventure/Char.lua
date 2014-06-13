-- adventure/Char.lua
require("bma.lang.ext.Table")
local Class = class.define("adventure.Char")

function Class.newChar(prop)
	local data = {}
	data.HP = 0
	data.ATK = 0
	data.DEF = 0
	data.APS = 0
	data.SHD = 0
	data.SPD = 0
	data.SKILLS = {}

	data.mod = true
	data.team = 0
	data.pos = 1

	table.copy(data, prop, true)

	return data
end

