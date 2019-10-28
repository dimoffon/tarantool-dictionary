#!/usr/bin/env tarantool
local server = require('server.server')
local db = require('db')
log = require('log')

box.cfg {
    listen = 3301,
    log_level = 5,
    log = 'log.txt'
}

local app = {
    start = function()
        log.info('Starting application')
        db:init()
        log.info('Start server')
        server:init()
    end
}

app:start()