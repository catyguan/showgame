require("bma.lang.ext.Json")

local wid = "test"

function service_init(ctx, res)
	local wid = glua_getString(ctx, "id")
	local wm = WORLD_MANAGER
	wm:closeWorld(wid)

	local o = wm:newWorld(wid)
	o:loadWorld()

	glua_setString(res, "Content", ""..o.id)
	return true
end

function service_scene( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local o = WORLD_MANAGER:getWorld(wid)
	if o~=nil then
		local r = o:getScene(-1)
		-- glua_setString(res, "Content", table.json(r))
		glua_setString(res, "Content", r)
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

function service_enter( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local n = glua_getString(ctx, "n")
	local o = WORLD_MANAGER:getWorld(wid)
	if o~=nil then
		local ok = o:enterScene(n)
		local r = "true"
		if not ok then r = "false" end
		glua_setString(res, "Content", r)
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

function service_action( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local cmd = glua_getString(ctx, "cmd")
	local p = glua_getString(ctx, "p")
	local param = {}
	if p~=nil and p~="" then
		local data = string.json(p)
		if type(data)=="table" then
			param = data
		end
	end

	local o = WORLD_MANAGER:getWorld(wid)
	if o~=nil then
		local r = o:doAction(cmd, unpack(param))
		glua_setString(res, "Content", lang.Json.encode(r))
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

function service_test( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local o = WORLD_MANAGER:getWorld(wid)
	if o~=nil then
		o:enterScene("adventure")
		glua_setString(res, "Content", "OK")
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

