local require, print, string = require, print, string
local table, pairs = table, pairs
local skynet = require "skynet"

local mode = ...

if mode == "child" then
    local os, io = os, io
    local file_contents = {}
    local bi_dir = "run/"

    skynet.start(function()
        skynet.dispatch("lua", function(_, _, file_name, content)
            -- print("bi service recv", file_name, #content)
            if not file_contents[file_name] then
                file_contents[file_name] = {}
            end
            local arr = file_contents[file_name]
            table.insert(arr, content)
        end)
    end)

    local flush_one_bi = function(file_name, str)
        file_contents[file_name] = nil
        local date = os.date("%Y%m%d")
        file_name = bi_dir .. date .. file_name
        -- print(file_name, str)
        local f = io.open(file_name, "a+")
        f:write(str)
        f:close()
    end

    local flush_bi = function()
        local t1 = skynet.now()
        for name, arr in pairs(file_contents) do
            flush_one_bi(name, table.concat(arr, "\n") .. "\n")
        end
        print(skynet.now() - t1)
    end

    local TICK = 100
    skynet.fork(function()
        while true do
            flush_bi()
            skynet.sleep(TICK)
        end
    end)
else
    local addr = skynet.uniqueservice("common/common/bi", "child")

    local mgr = {}

    mgr.bi = function(file_name, ...)
        local arr = table.pack(...)
        local content = table.concat(arr, string.char(1))
        skynet.send(addr, "lua", file_name, content)
    end

    return mgr
end
