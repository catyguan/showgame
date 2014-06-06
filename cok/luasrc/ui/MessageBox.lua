-- lua/MessageBox.lua
require("world.PDVM")
require("bma.lang.ext.Table")

local Class = class.define("ui.MessageBox", {"world.UIControl"})

--[[
viewdata {
	message : xxxxx,
	confirm : true|false,
}
context {
	ok = ....,
	cancel = ....,
}
]]
local VIEW_NAME = "mbox"

-- UI
function Class.canClose(ctx)
	if ctx~=nil then return ctx.closed end
	return true
end
function Class.onClose(ctx)
	local o = WORLD
	if ctx~=nil and ctx.stackId ~= nil then
		o:pdresume(ctx.stackId)
	end
end

function Class.doClick(ctx, ok)
	local o = WORLD
	if ctx~=nil then
		ctx.closed = true
	end
	o:closeView(VIEW_NAME)
	
	if ctx==nil then return end

	local pds = nil
	if ok then
		pds = ctx["ok"]
	else
		pds = ctx["cancel"]
	end	
	pdcall(pds)
end

-- PDVM:invoke
function Class.invoke(sid, data)	
	local view = nil
	if data.view ~= nil then
		view = {}
		table.copy(view, data.view, true)
	end

	local ctx = {}
	if data.context~=nil then
		table.copy(ctx, data.context, true)
	end
	ctx.stackId = sid

	local o = WORLD	
	o:createView(VIEW_NAME, view, "ui.MessageBox", ctx)
	return "wait"
end