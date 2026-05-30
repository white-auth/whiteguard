# whiteguard

A quick, easy and open-source Discord bot for managing users on a whitelist/blacklist. It uses the Luvit/Lua Discord libraries and stores whitelisted and blacklisted users in a GitHub repository via the GitHub API.

## Quick overview

- `main.lua` — bot entrypoint; starts the Discord client and loads slash command modules via `handler.lua`.
- `handler.lua` — auto-loads any `.lua` files placed in the `commands/` folder.
- `commands/` — slash command modules (e.g. `whitelist.lua`, `unwhitelist.lua`, `blacklist.lua`, `unblacklist.lua`, `ping.lua`).
- `libraries/` — core libraries:
  - `git.lua` — GitHub API integration for reading/writing whitelist data.
  - `dotenv.lua` — environment variable parser for loading `.env` files.
  - `types.lua` — Discord type constants for slash command options.
- `EXAMPLEWL.json` — example whitelist/blacklist data schema.

## Prerequisites

- A Luvit-compatible runtime installed.
- `discordia` and `discordia-interactions`.
- `coro-http` for GitHub API requests.
- `luvit/openssl` for SHA256 hashing and Base64 support.
- `luvit/secure-socket` for HTTPS requests to GitHub.
- A GitHub repository to store whitelist/blacklist data (recommended: `white-auth/whitelists`).
- A GitHub Personal Access Token with `repo` scope to access your whitelist repository.

Install dependencies with `lit` using the commands below:

```bash
lit install SinisterRectus/discordia
lit install Bilal2453/discordia-interactions
lit install creationix/coro-http
```

`creationix/coro-http` will also install its runtime dependencies (`coro-net`, `coro-channel`, `coro-wrapper`, and `http-codec`) automatically.

## Configuration

### 1. Set up environment variables

Create a file named `.env` in the project root with your bot token and GitHub token:

```env
DISCORD_TOKEN=your_bot_token_here
GITHUB_TOKEN=your_github_personal_access_token_here
```

- **DISCORD_TOKEN**: Your Discord bot token (create one at [Discord Developer Portal](https://discord.com/developers/applications)).
- **GITHUB_TOKEN**: A GitHub Personal Access Token with `repo` scope (create one at [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)).

`main.lua` will read `process.env.DISCORD_TOKEN` and will error if the variable is missing. The `libraries/git.lua` module will use `GITHUB_TOKEN` to authenticate with the GitHub API.

### 2. Configure the GitHub repository

Edit `libraries/git.lua` and update the `config` section:

```lua
config = {
    repo = 'owner/repo-name',  -- e.g., 'white-auth/whitelists'
    file = 'whitelists.json',  -- the JSON file in your repo containing whitelist data
    branch = 'main'             -- the branch to commit to
}
```

Create a `whitelists.json` file in your GitHub repository with the following structure:

```json
{
    "WhitelistedUsers": {},
    "BlacklistedUsers": {}
}
```

- **hwid**: The SHA256 hash of the user's Hardware ID (the bot will hash HWIDs before storing them).
- **level**: Whitelisted user's access level (2–3, with higher levels granting more permissions). One being default level.
- **reason**: Reason for whitelisting/blacklisting.

## Adding commands

Create a Lua file under `commands/` that returns a command definition compatible with your slash-command handler. A minimal example that will be auto-loaded by `handler.lua`:

```lua
return {
	name = 'ping',
	description = 'Reply with pong',
	run = function(interaction)
		interaction:reply({content = 'pong'}, true)
	end
}
```

For whitelisting and blacklisting, commands like `whitelist.lua`, `unwhitelist.lua`, `blacklist.lua`, and `unblacklist.lua` use the `libraries/git.lua` module to commit changes to your GitHub repository. Example:

```lua
local discordia = {
    extra = {
        git = require('libraries/git'),
        types = require('libraries/types')
    }
}

return {
    name = 'whitelist',
    description = 'Whitelist a user',
    options = {
        {
            name = 'user',
            description = 'The user to whitelist',
            type = discordia.extra.types.USER,
            required = true
        }
    },
    run = function(interaction)
        local targetUser = interaction.data.options[1].value
        local success = discordia.extra.git:whitelist(targetUser, 1, 'user_hwid_here')
        
        if success then
            interaction:reply({content = 'User whitelisted!'}, true)
        else
            interaction:reply({content = 'Failed to whitelist user.'}, true)
        end
    end
}
```

## Running the bot

Ensure your `.env` is present (see Configuration above) and dependencies installed, then start the bot with Luvit:

```bash
luvit main.lua
```

If everything is configured correctly you should see a login message in the console. `main.lua` will also remove any currently-registered global application commands on startup (this is intentional in the scaffold).

## Troubleshooting

- "Failed to load command": check that the Lua file in `commands/` returns a table (not `nil`) and contains the expected fields.
- "Missing module 'discordia'": install `discordia` for your runtime and ensure `require('discordia')` works.
- "Missing module 'discordia-interactions'": install `discordia-interactions` for your runtime and ensure `require('discordia-interactions')` works.
- "Missing module 'coro-http'": install `coro-http` and its runtime dependencies with `lit install creationix/coro-http`.
- "Missing module 'openssl'" or HTTPS failures: install `luvit/openssl` and `luvit/secure-socket`.
- If slash commands don't register, verify `discordia-slash` is installed and the bot has application command permissions.
- "No GITHUB_TOKEN found in .env file": ensure your `.env` file contains a valid `GITHUB_TOKEN` and the GitHub token has `repo` scope.
- "Failed to fetch whitelist from GitHub": verify that:
  - The `GITHUB_TOKEN` is valid and hasn't expired.
  - Your GitHub repository exists and the whitelist file path is correct.
  - The repository is private or the token has appropriate access permissions.
- "Failed to commit whitelist to GitHub": ensure your token has write access to the repository.

## Next steps & customization ideas

- Implement `ban.lua`, `kick.lua`, and `timeout.lua` for moderation commands.
- Complete `whitelist.lua`, `unwhitelist.lua`, `blacklist.lua`, and `unblacklist.lua` commands using the `libraries/git.lua` module.
- Add role-based permission checks to moderation commands (e.g., owner, moderator, admin).
- Implement timed punishments (ban/kick/timeout with automatic cleanup).
- Add logging for all whitelist/blacklist changes (optional: to a separate Discord channel or log file).
- Set up branch protection rules on your GitHub repository to prevent accidental data loss.
- Add graceful shutdown handling and error recovery.

## Credits
@stav -- Releasing the whole bot source code for free
