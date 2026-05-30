return {
    parse = function(content)
        local env = {}
        if not content then return env end

        for line in content:gmatch('[^\n]+') do
            local key, val = line:match('^%s*([^=]+)%s*=%s*(.*)%s*$')
            if key and val then
                val = string.match(val, '^[\'"](.*)[\'"]$') or val
                env[key] = val
            end
        end

        return env
    end
}
