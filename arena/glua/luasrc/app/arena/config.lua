-- app/jday/config.lua
-- 调试配置
CONFIG.DEBUG = true
CONFIG.DEV = true
-- 日志配置
CONFIG.Log = {
	type="print",
	logPattern="[%category] %level - %message\n",
}
-- 启动自动加载的服务
CONFIG.Services = {
	-- "bma.host.c2dx.Service",
}
-- 其他模块的配置
CONFIG.LuaHost = {
	LogClosure = false
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