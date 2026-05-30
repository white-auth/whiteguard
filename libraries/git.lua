--[[

    A Git Library to commit whitelist updates to your GitHub repository (whitelist)

]]

local git = {
    dependencies = {
        fs = require('fs'),
        json = require('json'),
        http = require('coro-http'),
        openssl = require('openssl'),
        digest = require('openssl').digest,
        dotenv = require('libraries/dotenv')
    },
    config = {
        repo = 'white-auth/whitelists',
        file = 'whitelists.json',
        branch = 'main'
    }
}

local function run(func)
    return func()
end

local function sha256(data)
    if type(data) ~= 'string' then
        return 'Data must be a string'
    end

    return git.dependencies.digest.digest('sha256', data, false) -- SON
end

git.dependencies.base64 = {
    encode = function(data)
        return git.dependencies.openssl.base64(data, true)
    end,
    decode = function(data)
        return git.dependencies.openssl.base64(data:gsub('%s+', ''), false)
    end
}

run(function()
    local suc, res = pcall(git.dependencies.fs.readFileSync, '.env')
    if suc and res then
        local cfg = git.dependencies.dotenv.parse(res)

        if cfg.GITHUB_TOKEN then
            git.config.token = cfg.GITHUB_TOKEN
        else
            error('No GITHUB_TOKEN found in .env file. Please add it and restart the bot.')
        end
    else
        error('Failed to read .env file. Please ensure it exists and is readable.')
    end
end)

local HTTP = {
    gitrequest = function(method, url, body)
        local headers = {
            {'Authorization', 'token '..git.config.token},
            {'Content-Type', 'application/json'},
            {'User-Agent', 'whiteguard-auth'}
        }

        local res, payload = git.dependencies.http.request(method, url, headers, body)
        return git.dependencies.json.parse(payload), res
    end,
    commitDatabase = function(self, db, sha)
        local url = string.format('https://api.github.com/repos/%s/contents/%s', git.config.repo, git.config.file)

        local data, res = self.gitrequest('PUT', url, git.dependencies.json.stringify({
            message = 'Update '..git.config.file,
            content = git.dependencies.base64.encode((git.dependencies.json.stringify(db, {indent = true}):gsub('":([^%s])', '": %1'):gsub('":%s*{%s*}', '": {}'))),
            sha = sha
        }))

        if data and res.code == 200 or res.code == 201 then
            return true
        else
            return false, 'Failed to commit whitelist to GitHub.\nResponse: '..(data.message or 'Unknown error')
        end
    end,
    getDatabase = function(self)
        local url = string.format('https://api.github.com/repos/%s/contents/%s?ref=%s', git.config.repo, git.config.file, git.config.branch)
        local data, res = self.gitrequest('GET', url)

        if not data or res.code ~= 200 then
            return nil, nil, 'Failed to fetch whitelist from GitHub.'
        end

        local db = git.dependencies.json.parse(git.dependencies.base64.decode(data.content)) or {}
        db.WhitelistedUsers = db.WhitelistedUsers or {}
        db.BlacklistedUsers = db.BlacklistedUsers or {}

        return db, data.sha, nil
    end
}

function git:whitelist(userId, level, hwid)
    local db, sha, err = HTTP:getDatabase()
    if err then return false, err end

    if db.BlacklistedUsers[userId] then
        return false, 'User is blacklisted and can\'t be whitelisted again (try /unblacklist first?)'
    end

    if db.WhitelistedUsers[userId] and sha256(db.WhitelistedUsers[userId].hwid) == hwid then
        return true, 'bro, you\'re already whitelisted what are you doing?'
    end

    db.WhitelistedUsers[userId] = {
        hwid = sha256(hwid),
        level = level
    }

    return HTTP:commitDatabase(db, sha)
end

function git:unwhitelist(userId)
    local db, sha, err = HTTP:getDatabase()
    if err then return false, err end

    if not db.WhitelistedUsers[userId] then
        return false, 'User is not whitelisted.'
    end

    if db.BlacklistedUsers[userId] then
        return false, 'SONN 🤣 (try /unblacklist?)'
    end

    db.WhitelistedUsers[userId] = nil
    return HTTP:commitDatabase(db, sha)
end

function git:blacklist(userId, hwid, reason)
    local db, sha, err = HTTP:getDatabase()
    if err then return false, err end

    if db.WhitelistedUsers[userId] then
        return false, 'User is whitelisted and can\'t be blacklisted (try /unwhitelist first?)'
    end

    if db.BlacklistedUsers[userId] and db.BlacklistedUsers[userId].hwid == sha256(hwid) and db.BlacklistedUsers[userId].reason == reason then
        return true, 'User is already blacklisted (what bro)'
    end

    db.BlacklistedUsers[userId] = {
        hwid = sha256(hwid),
        reason = reason or 'No reason provided'
    }

    return HTTP:commitDatabase(db, sha)
end

function git:unblacklist(userId)
    local db, sha, err = HTTP:getDatabase()
    if err then return false, err end

    if not db.BlacklistedUsers[userId] then
        return false, 'User is not blacklisted.'
    end

    if db.WhitelistedUsers[userId] then
        return false, 'SONN 🤣 (try /unwhitelist?)'
    end

    db.BlacklistedUsers[userId] = nil
    return HTTP:commitDatabase(db, sha)
end

return git
