return {
    name = 'pong',
    description = 'Checks to see if the bot is active and alive!',
    run = function(interaction)
        interaction:reply({
            content = 'Ping! 🏓'
        }, false)
    end
}
