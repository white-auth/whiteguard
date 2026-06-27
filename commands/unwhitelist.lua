local discordia = {
    extra = {
        git = require('../libraries/git'),
        types = require('libraries/types')
    },
    role_ids = {
        owner = '1414200179720065155'
    }
}

return {
    name = 'unwhitelist',
    description = 'Unwhitelists a user for your paste or wtv',
    options = {
        {
            name = 'user',
            description = 'The user to unwhitelist.',
            type = discordia.extra.types.USER,
            required = true
        }
    },
    run = function(interaction)
        local user, globalUser = interaction.member, interaction.user
        local perms, targetUser = false, nil

        for _, v in pairs(interaction.data.options) do
            if v.name == 'user' then
                targetUser = v.value
                break
            end
        end

        if user.roles then
            for _, v in pairs(discordia.role_ids) do
                if user:hasRole(v) then
                    perms = true
                    break
                end
            end
        end

        if not perms then
            return interaction:reply({
                content = 'You do not have permission to use this command.'
            }, true)
        end

        local suc, res = discordia.extra.git:unwhitelist(targetUser)
        if res then
            return interaction:reply({
                content = res
            }, true)
        end

        return interaction:reply({
            content = 'Unwhitelisted <@'..targetUser..'>! They will no longer be whitelisted.'
        }, false)
    end
}