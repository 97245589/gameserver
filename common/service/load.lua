local SERVICE_NAME = SERVICE_NAME
local string = string
local io = io

local load_files = function(depth)
    local service_dir = SERVICE_NAME:gsub("/[^/]+$", "")
    local str = string.format('find %s -maxdepth %s -mindepth %s -name "*.lua"', service_dir, depth, depth)
    local f = io.popen(str)
    for line in f:lines() do
        
    end
    f:close()
end

local load = function()
    load_files(1)
end

return {
    load = load
}
