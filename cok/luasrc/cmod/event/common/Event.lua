-- cmod/event/common/Event.lua
-- PDVM protocol

local Class = class.define("cmod.event.common.Event", {"cmod.event.BaseEvent"})

--[[
{
    main = { 对话内容
        content = "",
        select = [
                {选项
                    content=
                    action="sub"|"end"|"pdcall"
                    data=...
                }
            ]
        }
    }
    onEnter = {pdcall},
    onExit = {pdcall},
}
]]

local PROP = {"commonevent"}
function Class.activeEvent( data )
	if not Class.doEnter(data) then
		return
	end
	local wo = WORLD
	if not wo:pushScene("cmod.event.common") then
		return
	end
	local v = {
		stage = "main",
		data = data
	}
	wo:prop(PROP, v)
end