#!/usr/bin/env tarantool
local server_factory = require('http.server')
local handler = require('server.handler')
local log = require('log')

local HTTP_HOST = os.getenv('HTTP_HOST')
local HTTP_PORT = os.getenv('HTTP_PORT')

local server = {
    init = function(self)
        log.info('initialize server ' .. HTTP_HOST .. ':' .. HTTP_PORT)
        server = server_factory.new(nil, HTTP_PORT)
        server:route({ path = '/kv/:key', method = 'GET' }, handler.get)
        server:route({ path = '/kv/:key', method = 'PUT' }, handler.put)
        server:route({ path = '/kv/:key', method = 'DELETE' }, handler.del)
        server:route({ path = '/kv', method = 'POST' }, handler.post)
        server:start()
        log.info('Server is running')
    end
}
return server