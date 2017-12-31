local M, module = {}, ...

function M.handle(client, request, state)
    package.loaded[module]=nil

    local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
    if(method == nil)then
        _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
    end

    if method == "GET" and path == "/" then
        local buf = "HTTP/1.1 200 OK\n\n"
        buf = buf .. "{\n"
        local state_str = {}
        for i,v in ipairs(state) do
            if v then
                state_str[i] = "state" .. i .. ' = "' .. v .. '"'
            end
        end
        buf = buf .. table.concat(state_str, ",\n")
        buf = buf .. "\n}\n"

        client:send(buf)
    else
        local buf = "HTTP/1.1 400 Bad Request\n\n"
        buf = buf .. "cannot process request: " .. method .. " " .. path .. "\n"

        client:send(buf)
    end
end

return M
