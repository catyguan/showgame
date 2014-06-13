-- adventure/Cell.lua
require("bma.lang.ext.Table")

local Class = class.define("adventure.Cell")

local LDEBUG = LOG:debugEnabled()
local LTAG = "AdvCell"

--[[
id: int
x,y: int
pic: string
kind: stringEnum, empty|entry|exit|door|block|event|unknow
canEnter: bool
visible: bool
roads : Array<int>
event: ?
onEntr: PDCode
onLeave: PDCode
]]