local M, module = {}, ...

function M.format_message(id, state, time)
    local buf = "{\n"
    buf = buf .. " tsl_id: " .. id .. ",\n"
    buf = buf ..' state: "' .. state .. '",\n'
    buf = buf ..' time: "' .. time .. '",\n'
    buf = buf .. "}\n"
    return buf
end

function get_time()
    local tm = rtctime.epoch2cal(rtctime.get())
    local fmt = "%04d-%02d-%02dT%02d:%02d:%02dZ"
    return string.format(fmt, tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
end

function M.init_mqtt()
    local sensor = require("sensor")

    local m = mqtt.Client("heating", 120)
    m:connect("192.168.100.60", 1883, 0, function(client)
        print("mqtt connected")

        sensor.register_measurement_timer(2, function(current_tsl_id, old_state, new_state)
            print("mqtt message send")
            local time = get_time()
            print(time)
            client:publish("heating/leds/" .. current_tsl_id, M.format_message(current_tsl_id, new_state, time), 0, 1)
        end)
    end,
    function(client, reason)
        print("mqtt failed reason: " .. reason)
    end)
end

return M