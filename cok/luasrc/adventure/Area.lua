-- adventure/Area.lua
local Class = class.define("adventure.Region")

local LDEBUG = LOG:debugEnabled()
local LTAG = "AdvArea"

--[[
width:int
height:int
boss:bool
cells: Array<CellData>
]]