--[[

  whiteaid -- A free/open-source discord bot that makes whitelisting users for your discord bot easy.
  by @stav :)

]]

local discordia = require('discordia')
require('discordia-interactions')

local dependencies = {
    dotenv = require('./libraries/dotenv'),
    commands = require('./bundler'),
    fs = require('fs')
}
local time = os.clock()

local function run(func)
    return func()
end

local token = nil
run(function()
    local suc, res = pcall(dependencies.fs.readFileSync, '.env')
    if suc and res then
        local cfg = dependencies.dotenv.parse(res)

        if cfg.DISCORD_TOKEN then
            token = cfg.DISCORD_TOKEN
        else
            error('No DISCORD_TOKEN found in .env file. Please add it and restart the bot.')
        end
    else
        error('Failed to read .env file. Please ensure it exists and is readable.')
    end
end)

local client = discordia.Client()
client:on('ready', function()
    local appId, payloads = client.user.id, {}
    for i, v in pairs(dependencies.commands) do
        local payload = {
            name = v.name or i,
            description = v.description or 'No description',
            type = 1
        }
        
        if v.options then
            payload.options = v.options
        end
        
        table.insert(payloads, payload)
    end

    run(function()
        local suc, res = client._api:request('PUT', string.format('/applications/%s/commands', appId), payloads)

        print(suc, res)
        if not suc then
            print('Failed to send request to Discord.\nError: '..tostring(res))
        else
            print(res)
            print('Registered all '..#payloads..' commands globally.\nNote: If commands do not show, force restart your application by pressing (CTRL+R / CMD+R) whilst focused on the Discord application.\n')
        end

        client:setActivity({
            name = 'Custom Status',
            state = 'kool.aid solos!',
            type = 4
        })
    end)

    print('Successfully logged in as: '..client.user.username..'\ntook '..(os.clock() - time)..'\n\nMade with love by Stav :)')
end)

client:on('interactionCreate', function(interaction)
    if interaction.type == discordia.enums.interactionType.applicationCommand then
        local target_command = dependencies.commands[interaction.data.name]
        if target_command.run then
            target_command.run(interaction)
        else
            interaction:reply({
                content = 'An error occurred while running this command. (No run function)'
            }, true) 
        end
    end
end)

client:run('Bot '..token)
