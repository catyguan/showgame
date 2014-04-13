-- app/mgr_test/scenes/TestHttpClient.lua
local Class = class.define("app.mgr_test.scenes.TestHttpClient", {"bma.mgr.SceneBase"})

include("bma.http.client.HttpRequest")
include("bma.http.client.HttpResponse")

function Class:create()
	
	local this = self
	
	local block = director:createObject("CCLayerColor", {
		color = {255,0,0},
		contentSize = {600, 400},
		layout = { align="middle", valign="center" },
		onEvent = {
			tap = function()
				this:onClick()
			end
		}
	});
	
	local layer = director:createObject("CCELayerTouch", {})	
	layer:addChild(block)
	director:layout(layer, false)
	
	layer:enableTouch(block, "tap")	

	return layer	
end

function Class:onClick()
	local hqb = bma.http.client.HttpRequest.new()
	-- hqb.url = "http://www.lua.org/manual/5.1/manual.html"
	hqb.url = "http://cn.bing.com/?FORM=Z9FD1"
	hqb.debug = true
	hqb.postMode = true
	hqb:setUserAgent("mytest")
	hqb:setReferrer("http://cn.bing.com/")
	hqb:setCookie("test", "test")
	hqb:setHeader("myheader", "test123")
	hqb:setParam("q", "CURLOPT_POSTFIELDSIZE")
	hqb:setParam("sp", 1)
	
	local s = class.instance("bma.http.client.Service")
	local req = hqb:create()
	s:process(req, function(rep)
		print("httpclient end")
		local r = bma.http.client.HttpResponse.new(rep)
		print(r:toString(100))
	end)
end