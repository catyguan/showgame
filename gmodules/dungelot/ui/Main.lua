-- dungelot/ui/Main.lua
local Class = class.define("dungelot.ui.Main", {"ui.UIControl"})

local LTAG = "UI.dungelot"

local PROP = {"dungelot"}
local dgf = function(w)
	return w:prop(PROP)
end

function Class:getViewData(w, sid)
	local dg = dgf(w)
	local w = dg:prop("w")
	local h = dg:prop("h")
	local map = dg:prop("map")
	sid = tonumber(sid)

	local view = {}
	view.sid = dg:prop("sid")
	
	view.w = w
	view.h = h
	local vmap = {}
	for x,xl in ipairs(map) do
		for y,c in ipairs(xl) do
			local csid = c:prop("sid")
			if not csid then csid = 0 end
			if sid==0 or sid<csid then			
				local vc = c:getViewData()
				vc.x = x
				vc.y = y
				table.insert(vmap, vc)
			end
		end
	end
	view.map = vmap
	
	return view
end

function Class:onProcess(w, sid, param)
	local dg = dgf(w)
	if not param then param = {} end
	local cmd = param.cmd	
	local x = param.x
	local y = param.y
	sid = tonumber(sid)

	if cmd=="click" then
		dg:doClick(x, y)
	end
	return 0
end