local fs = require('fs')
local files = fs.readdirSync('./commands')

local commands = {}

for _, file in ipairs(files) do
    if file:match('%.lua$') then
        local cmdname = file:gsub('%.lua$', '')

        local suc, module = pcall(require, './commands/'..cmdname)
        if suc and type(module) == 'table' and next(module) ~= nil and not commands[cmdname] then
            if module.options and type(module.options) == 'table' then
                table.sort(module.options, function(a,b)
                    local ta, tb = a.required and 1 or 0, b.required and 1 or 0
                    return ta > tb
                end)
            end

            commands[cmdname] = module
            print('Loaded command: '..cmdname)
        elseif not commands[cmdname] then
            local err = not suc and module or 'Module requested an error when requiring (returned empty table or nil?)'
            print('Failed to load command: '..cmdname..'\n\nError: '..err)
        end
    end
end

return commands
