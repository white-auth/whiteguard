# whiteguard

A quick, easy and open-source Discord bot for managing users on a whitelist/blacklist. It uses the Luvit/Lua Discord libraries and a simple JSON file for storing whitelisted and blacklisted users.

## Quick overview

- `main.lua` — bot entrypoint; starts the Discord client and loads slash command modules via `handler.lua`.
- `handler.lua` — auto-loads any `.lua` files placed in the `commands/` folder.
- `commands/` — put command modules here (e.g. `whitelist.lua`, `unwhitelist.lua`).
- `EXAMPLEWL.json` — example whitelist/blacklist data schema.

## Prerequisites

- Luvit (or another runtime that supports `require('discordia')`).
- `discordia` and `discordia-interactions` libraries installed for your runtime.

Install dependencies with your preferred package manager (for example, using `lit`):

```bash
lit install SinisterRectus/discordia
lit install Bilal2453/discordia-interactions
```

Adjust the above to match the package manager you use.

## Configuration

1. Provide your bot token. The project now loads environment variables from a `.env` file using `dotenv`.

Create a file named `.env` in the project root with a line like:

```env
DISCORD_TOKEN=your_bot_token_here
```

`main.lua` will read `process.env.DISCORD_TOKEN` and will error if the variable is missing. If you prefer, you can still hardcode the token in `main.lua` by replacing the `client:run('Bot '..token)` call, but using a `.env` or other secret management is recommended.

2. Create your runtime whitelist file. Copy `EXAMPLEWL.json` to a file your command code expects (for example `whitelist.json`) and edit the JSON to include real Discord user IDs.

HWID must include an actual HWID (obv) that was given from your executor. Make sure it IS encrypted through the SHA256 library, as the bot will encrypt and decrypt the HWID's you give it.
```json
{
	"WhitelistedUsers": {
		"123456789012345678": { "hwid": "real", "level": 1 }
	},
	"BlacklistedUsers": {
		"123456789012345678": { "hwid": "real", "reason": "Blacklisted :0" }
	}
}
```

## Adding commands

Create a Lua file under `commands/` that returns a command definition compatible with your slash-command handler. A minimal example that will be auto-loaded by `handler.lua`:

```lua
return {
	name = 'ping',
	description = 'Reply with pong',
	run = function(ctx)
		ctx:reply('pong')
	end
}
```

For whitelisting behaviour, create commands named `whitelist.lua` and `unwhitelist.lua` that update your JSON store. The project currently ships with empty placeholders in `commands/`.

## Running the bot

Ensure your `.env` is present (see Configuration above) and dependencies installed, then start the bot with Luvit:

```bash
luvit main.lua
```

If everything is configured correctly you should see a login message in the console. `main.lua` will also remove any currently-registered global application commands on startup (this is intentional in the scaffold).

## Troubleshooting

- "Failed to load command": check that the Lua file in `commands/` returns a table (not `nil`) and contains the expected fields.
- "Missing module 'discordia'": install `discordia` for your runtime and ensure `require('discordia')` works.
If not installed, install the dependencies required by running this command: 
```bash
lit install SinisterRectus/discordia
```
- "Missing module 'discordia-interactions'": install `discordia-interactions` for your runtime and ensure `require('discordia-interactions')` works.
If not installed, install the dependencies required by running this command: 
```bash
lit install Bilal2453/discordia-interactions
```
- If slash commands don't register, verify `discordia-slash` is installed and the bot has application command permissions.

## Credits
@sstvskids - Coding this whole project :)
