Moderation commands
- Implement `ban.lua` fully, including user lookup, logging, permission checks and persistent ban storage.
- Implement `kick.lua` with logging and permission checks.
- Implement `timeout.lua` with timed punishments, logging, permission checks and cleanup.
- Add moderation command validation and error responses.
- Test ban, kick, and timeout flow in the handler.

Whitelist/blacklist commands
- Complete `whitelist.lua` and `unwhitelist.lua` for allowlisting users.
- Complete `blacklist.lua` and `unblacklist.lua` for denylisting users.
- Ensure all whitelist/blacklist commands update persistent storage.
- Add checks so moderation commands respect whitelist/blacklist state.
- Test whitelist/blacklist persistence and command interactions.

GitHub library
- Finish `libraries/git.lua` implementation and export stable API.
- Add error handling for GitHub calls and repository access.
- Document GitHub library usage in `readme.md` if needed.
- Test GitHub library behavior with local repo operations.
