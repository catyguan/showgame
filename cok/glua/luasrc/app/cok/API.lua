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

function service_status( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local o = WORLD_MANAGER:getWorld(wid)
	if o~=nil then
		local r = o:getStatus()
		glua_setString(res, "Content", table.json(r))
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

function service_test( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local o = WORLD_MANAGER:getWorld(wid)
	if o~=nil then
		o:enterSM(1, "Adventure")
		glua_setString(res, "Content", "OK")
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

