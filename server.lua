local sensor = require("sensor")

function init()
    local config = require("config")

    wifi.setmode(wifi.STATION)
    station_cfg={}
    station_cfg.ssid=config.SSID
    station_cfg.pwd=config.PASS
    wifi.sta.config(station_cfg)

    tmr.alarm(1, 5*1000, tmr.ALARM_SINGLE, function()
        print(wifi.sta.getip())

        tmr.alarm(1, 10*60*1000, tmr.ALARM_SINGLE, function()
            print("light sleep serial unstable ...")
            wifi.sleeptype(wifi.LIGHT_SLEEP)
        end)

        init_mqtt()
    end)
end

function init_mqtt()
    m = mqtt.Client("heating", 120)
    m:connect("192.168.100.60", 1883, 0, function(client)
        print("mqtt connected")

        function format(id, state)
            local buf = "{\n"
            buf = buf .. " tsl_id: " .. id .. "\n"
            buf = buf .. " state: " .. state .. "\n"
            buf = buf .. "}\n"
            return buf
        end

        sensor.register_measurement_timer(2, function(current_tsl_id, old_state, new_state)
            client:publish("/heating/leds", format(current_tsl_id, new_state), 0, 1)
        end)
    end,
    function(client, reason)
        print("mqtt failed reason: " .. reason)
    end)

end

init()

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(sck, payload)
        require("connection").handle(sck, payload, sensor.getState())
    end)
    conn:on("sent", function(sck) sck:close() end)
end)

