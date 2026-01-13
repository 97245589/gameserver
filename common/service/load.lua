local string = string
local io = io
local require = require

local load_files = function(depth)
    local SERVICE_NAME = SERVICE_NAME
    local service_dir = SERVICE_NAME:gsub("/[^/]+$", "")
    local str = string.format('find %s -maxdepth %s -mindepth %s -name "*.lua"', service_dir, depth, depth)
    local f = io.popen(str)
    for line in f:lines() do
        local file_name = string.sub(line, 1, -5)
        if file_name ~= SERVICE_NAME then
            local m = string.gsub(file_name, '/', '.')
            require(m)
        end
    end
    f:close()
end

local load = function()
    load_files(1)
    load_files(2)
end

return {
    load = load
}
