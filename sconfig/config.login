cluster_port = 10030
gate_port = 10031
server_name = "login"
server_mark = server_name

thread = 3
harbor = 0
start = "server/main"	-- main script
luaservice = "skynet/service/?.lua;?.lua"
lualoader = "skynet/lualib/loader.lua"
lua_path = "skynet/lualib/?.lua;?.lua"
lua_cpath = "skynet/luaclib/?.so;luaclib/?.so"
cpath = "skynet/cservice/?.so"

--logger = "run/" .. server_mark .. ".log"
--daemon = "run/" .. server_mark .. ".pid"
