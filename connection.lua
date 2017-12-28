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
        for i,v in ipairs(state) do
            buf = buf .. "state" .. i .. " = " .. v
        end
        buf = buf .. "}\n" 

        client:send(buf)
    else
        local buf = "HTTP/1.1 400 Bad Request\n\n"
        buf = buf .. "cannot process request: " .. method .. " " .. path .. "\n"

        client:send(buf)
    end
end

return M
