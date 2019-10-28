#!/usr/bin/env tarantool
document = require('document')
log = require('log')

local db = {
    init = function()
        log.info('init schema')
        box.once('init', function()
            dictionary = box.schema.create_space('dictionary')
            document.create_index(dictionary, 'primary', { parts = { 'key', 'string' } })
        end)
    end,
    get = function(self, key)
        return document.unflatten(dictionary, dictionary:get(key))
    end,
    put = function(self, key, value)
        log.info('make put ' .. key)
        dictionary:put(document.flatten(dictionary, { key = key, value = value }))
    end,
    del = function(self, key)
        return document.delete(dictionary, { { '$key', '==', key } })
    end
}
return db