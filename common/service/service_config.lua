return {
    service_num = {
        default = 2,
        game_player_service = 2,
        login_child = 2
    },

    cluster_node = {
        center1 = "0.0.0.0:10200"
    },

    -- 单位 s
    tm = {
        heartbeat_tm = 3,
        heartbeat_tmout = 5
    },

    login_service_key = "12345678"
}
