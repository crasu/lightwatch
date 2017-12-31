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
        require("mqttconnection").init_mqtt()
        require("sntp").sync()
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

