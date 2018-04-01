local sensor = require("sensor")

function init()
    local config = require("config")

    wifi.setmode(wifi.STATION)
    station_cfg={}
    station_cfg.ssid=config.SSID
    station_cfg.pwd=config.PASS
    wifi.sta.config(station_cfg)

    tmr.create():alarm(5*1000, tmr.ALARM_SINGLE, function()
        print(wifi.sta.getip())
        sntp.sync(nil, nil, nil, 1)
        require("mqttconnection").init_mqtt()
    end)
end

init()
