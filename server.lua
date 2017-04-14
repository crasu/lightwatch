function init()
    local config = require("config")

    wifi.setmode(wifi.STATION)
    wifi.sta.config(config.SSID, config.PASS)

    tmr.alarm(1, 10*60*1000, tmr.ALARM_SINGLE, function()
        print("light sleep serial unstable ...")
        wifi.sleeptype(wifi.LIGHT_SLEEP)
    end)

    tmr.alarm(2, 5*1000, tmr.ALARM_SINGLE, function()
        print(wifi.sta.getip())
    end)

    status = tsl2561.init(4,5)
    if status == tsl2561.TSL2561_OK then
        print("tsl2561 init ok") 
        tsl2561.settiming(tsl2561.INTEGRATIONTIME_402MS, tsl2561.GAIN_16X)
    else
        print("tsl2561 init failed") 
    end
end

init()

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(sck, payload)
        local port, dim = require("connection").handle(sck, payload)
    end)
    conn:on("sent", function(sck) sck:close() end)
end)

