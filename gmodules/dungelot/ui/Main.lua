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

	local hero = dg:hero()
	if sid<V(hero:prop("sid"), 0) then
		view.a = {}
		view.a.level = dg:prop("level")		
		view.a.maxlevel = dg:prop("maxlevel")
		for k,v in pairs(hero._prop) do
			view.a[k] = v
		end
	end

	local tips = dg:uiGetTips()
	-- print("tips", tips)
	if tips~=nil then
		view.tips = tips
	end

	if sid>0 then
		local evs = dg:uiPopEvent(sid)
		if #evs>0 then
			view.events = evs
		end
	end
	
	local vmap = {}
	dg:walk(function(x, y, c)
		local csid = c:prop("sid")
		if not csid then csid = 0 end
		if sid==0 or sid<csid then			
			local vc = c:getViewData()
			vc.x = x
			vc.y = y
			table.insert(vmap, vc)
		end
	end)
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
	elseif cmd=="tips" then
		dg:uiEndTips()
	end
	return 0
end