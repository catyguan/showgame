-- app/jday/config.lua
-- 调试配置
CONFIG.DEBUG = true
CONFIG.DEV = true
-- 日志配置
CONFIG.Log = {
	type="print",
	logPattern="%date [%category] %level - %message\n",
}
-- 启动自动加载的服务
CONFIG.Services = {
	"bma.host.c2dx.Service",
	"bma.http.client.host.Service",
	"bma.esnp.host.Service",
}
-- 其他模块的配置
CONFIG.LuaHost = {
	LogClosure = false
}
CONFIG.ESNP = {
	Hosts = {
		-- { host="172.19.16.78", port=1080 },
		{ host="127.0.0.1", port=1080 },
	}
}
-- APP
CONFIG.UI = {
	FontName = "Arial",
	FontSize = 32,
	BigTitleFontSize = 64,
	ButtonFontSize = 48,	
}

CONFIG.AppCloud = {
	Servers = {
		{
			url="http://127.0.0.1:8080/jday",
			debug=true,
		},
		{
			url="http://localhost:8080/jday",
			debug=true,
		},
	}
}