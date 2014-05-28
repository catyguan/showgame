-- app/maze/config.lua
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
	"app.cok.StoreServiceImpl",
}
-- 其他模块的配置
CONFIG.LuaHost = {
	LogClosure = false
}
-- APP
