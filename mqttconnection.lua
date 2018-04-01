local M, module = {}, ...

function M.format_message(id, state, time)
    local buf = '{\n'
    buf = buf .. ' "tsl_id": ' .. id .. ',\n'
    buf = buf ..' "state": "' .. state .. '",\n'
    buf = buf ..' "time": "' .. time .. '"\n'
    buf = buf .. '}\n'
    return buf
end

function get_time()
    local tm = rtctime.epoch2cal(rtctime.get())
    local fmt = "%04d-%02d-%02dT%02d:%02d:%02dZ"
    return string.format(fmt, tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
end

function handle_mqtt_error(client, reason)
    print("could not connect reason " .. tostring(reason))
    if M.measurement_timer then
        M.measurement_timer:unregister()
    end
    tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, mqtt_connect)
end

function handle_state_change(current_tsl_id, old_state, new_state)
    local time = get_time()
    local ret = M.mqtt_client:publish("heating/leds/" .. current_tsl_id, M.format_message(current_tsl_id, new_state, time), 0, 0)
    if ret then
        print("mqtt message send.")
    else
        print("mqtt publish failed.")
        handle_mqtt_error(nil, nil)
    end

    return ret
end

function mqtt_connect()
    local mqtt_ip = "192.168.100.60"
    local mqtt_port = 1883

    local sensor = require("sensor")
    print("connecting ...")
    M.mqtt_client:connect(mqtt_ip, mqtt_port, 0, function(mqtt_client)
        print("mqtt connected")
        M.measurement_timer = sensor.register_state_change_handler(handle_state_change)
    end, handle_mqtt_error)
end

function M.init_mqtt()
    M.mqtt_client = mqtt.Client("heating", 120)
	mqtt_connect()
end

return M
