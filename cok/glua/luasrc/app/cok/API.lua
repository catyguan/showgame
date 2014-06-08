require("bma.lang.ext.Json")

local wid = "test"

function service_init(ctx, res)
	local wid = glua_getString(ctx, "id")
	local wm = WORLD_MANAGER
	wm:closeWorld(wid)

	local o = wm:newWorld(wid)
	o:loadWorld()

	if o:getView(-1)==nil then
		o:createView("home", {}, "ui.Home")
	end

	glua_setString(res, "Content", ""..o.id)
	return true
end

function service_viewinfo( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local o = WORLD_MANAGER:getWorld(wid)
	if o~=nil then
		local r = {}
		local vo = o:getView(-1)
		if vo==nil then
			r.name = "home"
		else
			r.name = vo.name
			r.data = vo.data
		end
		glua_setString(res, "Content", table.json(r))
		-- glua_setString(res, "Content", r)
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

function service_action( ctx, res )	
	local wid = glua_getString(ctx, "id")
	local cmd = glua_getString(ctx, "cmd")
	local p = glua_getString(ctx, "p")
	LOG:debug("API", "%s, %s(%s)", wid, cmd, p)
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
		local resp = o:uiAction(cmd, unpack(param))
		o:pdprocess()
		o:finish()
		r.result = resp

		local vo = o:getView(-1)
		if vo==nil then
			r.name = "home"
		else
			r.name = vo.name
			r.data = vo.data
		end
		var_dump(o._prop)
		glua_setString(res, "Content", table.json(r))
	else
		glua_setString(res, "Content", "InvalidWorld")
	end	
	return true
end

local testClass = class.define("test.Class1")
function testClass.add(data, a, b)
	print(a, b, a+b)
end

function service_test( ctx, res )	
	require("world.PDVM")
	local data = {
		_p = "event",
		main = {
	        content = "Are you OK?",
	        options = {
                {
                    content="Yes",
                    action="end",
                },
                {
                	content="No, I'm sick!",
                	action="sub",
                	data = "sick",
            	}
	    	}
		},
		sick = {

		}
	}
	local o = WORLD_MANAGER:getWorld("test")
	o:begin()
	PDCall(data, "activeEvent")
	o:finish()
	glua_setString(res, "Content", "OK")	
	return true
end

