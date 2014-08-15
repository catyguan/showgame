-- ui/CommonEvent.lua
require("world.PDVM")
require("bma.lang.ext.Table")

local Class = class.define("ui.CommonEvent", {"world.UIControl"})

--[[
viewdata {
	content : xxxxx,
	options : [
		{id=xxx, title=xxxx},
		...
	]
}
context {
	stage : [1,2,3...]
	view : {
		content : xxxx,
		options : [
			{id=xxx, title=xxxxx, close=true|false, op=PDCODE [subview]},
			...
		]
	}
}
]]
local LDEBUG = LOG:debugEnabled()
local LTAG = "uiCommonEvent"
local VIEW_NAME = "commonevent"

function Class.locate(stage, rootView)
	local cv = rootView
	for _,v in ipairs(stage) do
		cv = rootView.options[v]
	end
	return cv
end

function Class.updateView(ctx)
	local st = ctx.stage
	if st==nil then
		st = {}
		ctx.stage = st
	end
	local cv = Class.locate(st, ctx.view)
	local vdata = {
		content = cv.content,
		options = {}
	}
	for i,opt in ipairs(cv.options) do
		vdata.options[i] = {
			id = opt.id,
			title = opt.title
		}
	end

	local o = WORLD	
	o:updateViewData(VIEW_NAME, vdata)
end


-- UI
function Class.onEnter(ctx)
	Class.updateView(ctx)
end

function Class.canClose(ctx)
	return false
end

function Class.doSelect(ctx, id)
	local o = WORLD
	local cv = Class.locate(ctx.stage, ctx.view)	
	if cv==nil then
		error("invalid event current view")
	end
	local sopt = nil
	local sidx = nil
	for idx,opt in ipairs(cv.options) do
		if opt.id==id then
			sopt = opt
			sidx = idx
		end
	end
	if sopt==nil then
		if LDEBUG then
			LOG:debug(LTAG, "select option(%s) invalid", id)
		end
		return
	end
	if LDEBUG then
		LOG:debug(LTAG, "select option %s", id)
	end

	if sopt.close then
		o:endView(VIEW_NAME)
	else
		table.insert(ctx.stage, sidx)
		Class.updateView(ctx)
	end	
	
	local pds = sopt.op
	pdcall(pds)
end