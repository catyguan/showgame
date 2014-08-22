require("bma.lang.ext.Json")

local wid = "test"

local loader = function(name)
	local ddir = "../data"
	local fn = ddir.."/"..name..".json"
	local file = io.open(fn, "r")
	if file==nil then
		return {}
	end
	local str = file:read("*all")
	file:close()
	return str:json()
end

function new_world(wid)
	local wm = WORLD_MANAGER
	wm:closeWorld(wid)

	local o = wm:newWorld(wid)
	o:loadWorld()

	if o:getView(-1)==nil then
		local vo = class.new("roguelike.ui.Home")
		o:createView("home", vo)
	end
	return o
end

function service_init(ctx, res)
	local wid = glua_getString(ctx, "id")
	local o = new_world(wid)
	glua_setString(res, "Content", "new world "..o.id)
	return true
end

function service_save(ctx, res)
	local wid = glua_getString(ctx, "id")
	local wm = WORLD_MANAGER
	local o = wm:getWorld(wid)
	if o~=nil then
		o:saveWorld()
	end
	glua_setString(res, "Content", "save done")
	return true
end

function service_viewinfo( ctx, res )
	-- if true then
	-- 	local r = loader("combat_uitest")
	-- 	glua_setString(res, "Content", table.json(r.view))
	-- 	return true
	-- end

	local wid = glua_getString(ctx, "id")
	local o = WORLD_MANAGER:getWorld(wid)
	if o~=nil then
		local r = {}
		local vo = o:getView(-1)
		if vo==nil then
			r.name = "home"
		else
			r.name = vo:name()
			r.data = vo:getViewData(o, 0)
		end
		glua_setString(res, "Content", table.json(r))
		-- glua_setString(res, "Content", r)
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

function service_process( ctx, res )
	-- if true then
	-- 	local r = loader("combat_uitest")
	-- 	glua_setString(res, "Content", table.json(r.process))
	-- 	return true
	-- end

	local wid = glua_getString(ctx, "id")
	local sid = glua_getString(ctx, "sid")
	local p = glua_getString(ctx, "p")
	LOG:debug("API", "process(%s, %s, %s)", wid, sid, p)
	local param
	if p~=nil and p~="" then
		local data = string.json(p)
		if type(data)=="table" then
			param = data
		end
	end

	local o = WORLD_MANAGER:getWorld(wid)
	if o~=nil then
		local r = {}
		o:begin()
		local resp = o:uiProcess(sid, param)
		o:finish()
		r.result = resp

		local vo = o:getView(-1)
		if vo==nil then
			r.name = "home"
		else
			r.name = vo:name()
			r.data = vo:getViewData(o, sid)
		end
		-- var_dump(o._prop)
		glua_setString(res, "Content", table.json(r))
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

function service_action( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local cmd = glua_getString(ctx, "cmd")
	local p = glua_getString(ctx, "p")
	LOG:debug("API", "action(%s, %s, %s)", wid, cmd, p)
	local param = {}
	if p~=nil and p~="" then
		local data = string.json(p)
		if type(data)=="table" then
			param = data
		end
	end

	local o = WORLD_MANAGER:getWorld(wid)
	if o~=nil then
		local r = {}
		o:begin()
		local resp = o:uiAction(cmd, param)
		o:finish()
		r.result = resp

		glua_setString(res, "Content", table.json(r))
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

function service_testNewDungelot( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local o = WORLD_MANAGER:getWorld(wid)
	if o==nil then
		o = new_world(wid)
	end

	local dm = class.forName("dungelot.Manager")
	local dg = dm.newDungeon()	
	dg:run(o, "test")
	glua_setString(res, "Content", "OK")	
	return true
end

function service_testNewCombat( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local o = WORLD_MANAGER:getWorld(wid)
	if o==nil then
		o = new_world(wid)
	end

	local cbd = class.forName("roguelike.combat.Combatd")
	local cb = cbd.newCombat()
	o:prop("combat", cb)

	cbd.prepare(cb)
	-- cbd.

	-- o:createView("home", {}, "ui.Home")		
	glua_setString(res, "Content", "OK")	
	return true
end

