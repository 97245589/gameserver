local impl = {}

local create_instance = function(info)
    local M = {}

    M.tick = function()
    end

    M.dump = function()
    end

    return M
end

return {
    impl = impl,
    create_instance = create_instance
}
