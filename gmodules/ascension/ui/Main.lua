-- ascension/ui/Main.lua
local Class = class.define("ascension.ui.Main", {"ui.UIControl", "ascension.Const"})

local LTAG = "UI.ascension"
local CM = class.forName("ascension.Combatd")

local isSee = function(pid, setId)
	if setId==Class.SET_DESK then return false end
	if setId==Class.SET_HAND and pid==Class.ENEMY then
		return false
	end
	return true	
end

function Class:getViewData(w, sid)
	local cbd = CM.toCombatd(w)
	sid = tonumber(sid)

	local view = {}
	view.sid = cbd:prop("sid")

	local plist = {}
	plist[Class.ME] = cbd:player(Class.ME)
	plist[Class.ENEMY] = cbd:player(Class.ENEMY)

	if sid==0 then
		-- all cards
		view.cards = {}
		for pid,pl in ipairs(plist) do
			for i=1,cbd.SET_MAX do
				local set = pl:getSet(i)
				for _,c in ipairs(set) do
					table.insert(view.cards, c:ToView())					
				end
			end
		end
	end

	view.players = {}
	for pid,pl in ipairs(plist) do
		local vpl = {}
		vpl.HP = pl:prop("HP")
		vpl.MAXHP = pl:prop("MAXHP")
		vpl.sets = {}
		for i=1,cbd.SET_MAX do
			local set = pl:getSet(i)
			local see = isSee(pid, i)
			if see then
				vset = {}
				for _,c in ipairs(set) do
					table.insert(vset, c:prop("id"))				
				end
				if #vset==0 then vset = "empty" end
				vpl.sets[i] = vset
			else
				vpl.sets[i] = #set
			end							
		end
		view.players[pid] = vpl
	end

	-- local hero = dg:hero()
	-- if sid<V(hero:prop("sid"), 0) then
	-- 	view.a = {}
	-- 	view.a.level = dg:prop("level")		
	-- 	view.a.maxlevel = dg:prop("maxlevel")
	-- 	for k,v in pairs(hero._prop) do
	-- 		view.a[k] = v
	-- 	end
	-- end

	local tips = cbd:uiGetTips()
	-- print("tips", tips)
	if tips~=nil then
		view.tips = tips
	end

	if sid>0 then
		local evs = cbd:uiPopEvent(sid)
		if #evs>0 then
			view.events = evs
		end
	end
	
	-- local vmap = {}
	-- dg:walk(function(x, y, c)
	-- 	local csid = c:prop("sid")
	-- 	if not csid then csid = 0 end
	-- 	if sid==0 or sid<csid then			
	-- 		local vc = c:getViewData()
	-- 		vc.x = x
	-- 		vc.y = y
	-- 		table.insert(vmap, vc)
	-- 	end
	-- end)
	-- view.map = vmap
	
	return view
end

function Class:onProcess(w, sid, param)
	local cbd = CM.toCombatd(w)
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