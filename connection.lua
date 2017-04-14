local M, module = {}, ...

function M.handle(client, request)
    package.loaded[module]=nil

    local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
    if(method == nil)then
        _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
    end
    local _GET = {}
    if (vars ~= nil)then
        for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
            _GET[k] = v
        end
    end

    if method == "GET" and path == "/" then
        local buf = "HTTP/1.1 200 OK\n\n"
        local lux = tsl2561.getlux()
        local raw1, raw2 = tsl2561.getrawchannels()
        buf = buf .. "{ "
        buf = buf .. "lux: " .. lux .. "\n"
        buf = buf .. "raw1: " .. raw1 .. "\n"
        buf = buf .. "raw2: " .. raw2 .. "\n"
        buf = buf .. " ..}\n" 

        client:send(buf)
        return 200, method
    else
        local buf = "HTTP/1.1 400 Bad Request\n\n"
        buf = buf .. "cannot process request: " .. method .. " " .. path .. "\n"

        client:send(buf)
        return 400, method
    end
end

return M
