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
    name = 'blacklist',
    description = 'Blacklists a user for your paste or wtv',
    options = {
        {
            name = 'user',
            description = 'The user to blacklist.',
            type = discordia.extra.types.USER,
            required = true
        },
        {
            name = 'hwid',
            description = 'The HWID (Hardware ID) of the user to blacklist.',
            type = discordia.extra.types.STRING,
            required = true
        },
        {
            name = 'reason',
            description = 'The reason for blacklisting the user.',
            type = discordia.extra.types.STRING,
            required = false
        }
    },
    run = function(interaction)
        local user, globalUser = interaction.member, interaction.user
        local perms, targetUser, hwid, reason = false, nil, nil, nil

        for _, v in pairs(interaction.data.options) do
            if v.name == 'user' then
                targetUser = v.value
            elseif v.name == 'hwid' then
                hwid = v.value
            elseif v.name == 'reason' then
                reason = v.value
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

        if not hwid or #hwid < 30 then
            return interaction:reply({
                content = 'Provided HWID is invalid (imagine)'
            }, true)
        end

        local suc, res = discordia.extra.git:blacklist(targetUser, hwid, reason)
        if res then
            return interaction:reply({
                content = res
            }, true)
        end

        return interaction:reply({
            content = 'Blacklisted <@'..targetUser..'>! They will no longer be able to use your pasted garbage.'
        }, false)
    end
}