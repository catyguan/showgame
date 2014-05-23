
function service_add( ctx, res )	
	a = glua_getInt(ctx, "a")
	b = glua_getInt(ctx, "b")
	print("service_add <= ", a, b)
	c = a + b
	print("a + b => ", c)
	glua_setString(res, "Content", "{\"c\":"..c.."}")
	return true
end

function service_test( ctx, res )
	require("arena.Map")
	local p1 = arena.MapPos.new("A",1,1)
	local p2 = arena.MapPos.new("B",2,2)

	glua_setString(res, "Content", string.format("%s --- %s = %d",p1:key(),p2:key(),p1:distance(p2)))
	return true
end

function service_new(ctx, res)
	local a = AM:newArena()
	glua_setString(res, "Content", ""..a.id)
	return true
end

function service_begin( ctx, res )	
	local aid = glua_getInt(ctx, "aid")
	local a = AM:getArena(aid)
	if a~=nil then
		local jobj = class.new("arena.judges.SimpleJudge")		
		a:addObject(jobj)
		a:doBegin()
		glua_setString(res, "Content", "OK")
	else
		glua_setString(res, "Content", "InvalidArena")
	end	
	return true
end

function service_run( ctx, res )	
	local aid = glua_getInt(ctx, "aid")
	local a = AM:getArena(aid)
	if a~=nil then
		if a:isBegin() then		
			for i=1,10 do
				a:process(5*1000)
				if a:isEnd() then
					break
				end
			end
			a:doEnd()
			glua_setString(res, "Content", "OK")
		else
			glua_setString(res, "Content", "NotBegin")
		end
	else
		glua_setString(res, "Content", "InvalidArena")
	end	
	return true
end

function service_close( ctx, res )	
	local aid = glua_getInt(ctx, "aid")
	AM:closeArena(aid)
	glua_setString(res, "Content", "OK")
	return true
end


-- plans
local loadProp = function(n)
	local ddir = "../data"
	local file = io.open(ddir.."/"..n..".json", "r")
	local str = file:read("*all")
	file:close()
	require("bma.lang.ext.Json")
	return str:json()
end

local addo = function(a, p)
	local prop = loadProp(p)
	return a:addObjectProp(prop)
end

function service_plan( ctx, res )
	local aid = glua_getInt(ctx, "aid")
	local p = glua_getString(ctx, "p")
	local a = AM:getArena(aid)
	if a==nil then		
		glua_setString(res, "Content", "InvalidArena")
		return true
	end	
	if a:isBegin() then
		glua_setString(res, "Content", "ArenaBegin")
		return true
	end

	a:doSetup()
	addo(a, "char1")
	addo(a, "char2")	
	a:endSetup()

	glua_setString(res, "Content", "OK")
	
	return true
end