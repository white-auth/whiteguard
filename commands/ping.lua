return {
    name = 'ping',
    description = 'Checks to see if the bot is active and alive!',
    run = function(interaction)
        interaction:reply({
            content = 'Pong! 🏓'
        }, false)
    end
}
