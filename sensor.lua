local M, module = {}, ...

function make_tsl_entry(sda, scl, tsl_address)
    local entry = {
        sda = sda,
        scl = scl,
        addr = tsl_address
    }

    return entry
end

local TSL_LIST = {
    make_tsl_entry(4,5, tsl2561.ADDRESS_GND),
    make_tsl_entry(4,5, tsl2561.ADDRESS_FLOAT),
    make_tsl_entry(4,5, tsl2561.ADDRESS_VDD),
}

local STATE = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil
}

local TSL_THRESHOLD = 6
local TSL_SAMPLES = 5

function M.measure_led_state(tsl_id, callback)
    local tsl_entry = TSL_LIST[tsl_id]
    local status = tsl2561.init(tsl_entry.sda, tsl_entry.scl, tsl_entry.addr)
    local measurements = {}

    if status == tsl2561.TSL2561_OK then
        print("tsl2561 init ok")
        tsl2561.settiming(tsl2561.INTEGRATIONTIME_402MS, tsl2561.GAIN_16X)
    else
        print("tsl2561 init failed")
        return measurements
    end

    function measure_task(i)
        raw1, raw2 = tsl2561.getrawchannels()
        table.insert(measurements, raw1 + raw2)

        if i == 0 then
            callback(measurements)
        else
            i = i - 1
            node.task.post(node.task.LOW_PRIORITY, function() measure_task(i) end)
        end
    end

    measure_task(TSL_SAMPLES)
end

function M.determine_state(measurements)
    local above = false
    local below = false
    for i, v in ipairs(measurements) do
        if v > TSL_THRESHOLD then
            above = true
        else
            below = true
        end
    end

    if above and below then
        return "blink"
    else
        if above then
            return "on"
        else
            return "off"
        end
    end
end

function M.create_sample_next(state_change_callback)
    local current_tsl_id = 0

    return function()
        current_tsl_id = current_tsl_id % #TSL_LIST
        current_tsl_id = current_tsl_id + 1

        M.measure_led_state(current_tsl_id, function(ret)
            local new_state = M.determine_state(ret)
            print("New state:")
            print(new_state)
            local old_state = STATE[current_tsl_id]
            print("Old state:")
            print(old_state)
            if new_state ~= old_state then
                print("state change detected")
                state_change_callback(current_tsl_id, old_state, new_state)
            end

            STATE[current_tsl_id] = M.determine_state(ret)
            print("Updated state of tsl id " .. current_tsl_id .. " to " .. STATE[current_tsl_id])
            end)
    end
end

function M.register_measurement_timer(timer_id, change_callback)
    sample_next = M.create_sample_next(change_callback)

    tmr.alarm(timer_id, 10*1000, tmr.ALARM_AUTO, function()
        sample_next()
    end)
end

function M.getState()
    return STATE
end

return M