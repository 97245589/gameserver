local skynet = require "skynet"
require "server.func.print"
local login = require "server.test.func.clogin"

local clogin = login.clogin
local send_req = login.send_req
local get_res = login.get_res

skynet.start(function()
    local fd = clogin({
        loginhost = "0.0.0.0:10031",
        gamehost = "0.0.0.0:10012",
        acc = "hhh",
        cid = 100
    })
    skynet.fork(function()
        while true do
            local r1, r2, r3, r4 = get_res(fd)
            print(r1, r2, dump(r3), r4)
        end
    end)

    send_req(fd, "req_test", {})
end)
