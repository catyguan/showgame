-- cmod/event/BaseEvent.lua
require("world.PDVM")

local Class = class.define("cmod.event.BaseEvent")

function Class.doEnter( data )
	if data.onEnter~=nil then
		PDCall(data.onEnter, "invoke")
	end
	return true	
end

function Class.doExit( data )
	if data.onExit~=nil then
		PDCall(data.onExit, "invoke")
	end
end