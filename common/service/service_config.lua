return {
    service_num = {
        default = 2,
        game_player_service = 2,
        game_watchdog_child = 2,
        login_child = 2
    },

    cluster_node = {
        center1 = "0.0.0.0:10200"
    },

    map = {
        map_len = 100,
        map_wid = 100
    },

    -- 单位 s
    tm = {
        heartbeat_tm = 3,
        heartbeat_tmout = 5
    },

    db = {
        host = "127.0.0.1",
        port = 14001
    }
};
