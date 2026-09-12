local impl = {}

local create_instance = function(info)
    print("create map instance", dump(info))
    local map_impl = impl[info.id]

    local M = {
        idx = -1,
        actors = {},
    }
    local actors = {}
    M.actors = actors

    M.add_actor = function()
    end

    M.tick = function()
    end

    M.dump = function()
    end

    M.spawn = function ()
    end

    return M
end

impl[100] = {
    actor_enter = function ()
    end,
    actor_die = function()
    end
}

return {
    impl = impl,
    create_instance = create_instance
}
