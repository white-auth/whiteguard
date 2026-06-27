local discordia = {
    extra = {
        git = require('../libraries/git'),
        types = require('libraries/types')
    },
    role_ids = {
        owner = '1414200179720065155',
        wl_access = '1508392510706421770'
    }
}

return {
    name = 'whitelist',
    description = 'Whitelists a user for your paste or wtv',
    options = {
        {
            name = 'hwid',
            description = 'Your HWID (Hardware ID) string.',
            type = discordia.extra.types.STRING,
            required = true
        }
    },
    run = function(interaction)
        local user, globalUser = interaction.member, interaction.user
        local level, perms, hwid = 1, false, nil

        local options = interaction.data.options
        if options then
            for _, option in pairs(options) do
                if option.name == 'hwid' then
                    hwid = option.value
                    break
                end
            end
        end

        if user.roles then
            for _, v in pairs(discordia.role_ids) do
                if user:hasRole(v) then
                    if i == 'owner' then
                        level = 3
                    else
                        level = 2
                    end

                    perms = true
                end
            end
        end

        if not perms then
            return interaction:reply({
                content = 'You do not have permission to use this command.'
            }, true)
        end

        if not hwid or #hwid < 30 then
            return interaction:reply({
                content = 'Provided HWID is invalid (imagine)'
            }, true)
        end

        local suc, res = discordia.extra.git:whitelist(globalUser.id, level, hwid)
        if res then
            return interaction:reply({
                content = res
            }, true)
        end

        return interaction:reply({
            content = 'Whitelisted! Have fun!'
        }, false)
    end
}