local json = require('json')
local avro = require('avro_schema')
local db = require('db')
log = require('log')

ok, schema = avro.create {
    type = "record",
    name = "dict_schema",
    fields = {
        { name = "key", type = "string*" },
        { name = "value", type = "string" }
    }
}

local resp = function (req, msg, status)
    local resp = req:render({ text = msg })
    resp.status = status
    return resp
end

local validate = function (req)
    return avro.validate(schema, json.decode(req))
end

local handler = {
    get = function(req)
        local key = req:stash('key')
        log.info('Received GET request with key ' .. key)
        local record = db:get(key)
        if record == nil then
            return resp(req, 'Key ' .. key .. ' not found', 404)
        else
            return resp(req, json.encode(record), 200)
        end
    end,

    put = function(req)
        local key = req:stash('key')
        log.info('Received PUT request with key ' .. key)
        local valid, req_json = validate(req:read())
        if valid == false then
            return resp(req, 'Invalid message format', 400)
        else
            db:put(key, req_json.value)
            return resp(req, 'OK', 200)
        end
    end,

    del = function(req)
        local key = req:stash('key')
        log.info('Received DEL request with key ' .. key)
        local record = db:get(key)
        if record == nil then
            return resp(req, 'Key ' .. key .. ' not found', 404)
        else
            db:del(key)
            return resp(req, 'OK', 200)
        end
    end,

    post = function(req)
        log.info('Received POST request')
        local valid, req_json = validate(req:read())
        if valid == false or req_json.key == nil then
            return resp(req, 'Invalid message format', 400)
        else
            local obj = db:get(req_json.key)
            if obj == nil then
                return resp(req, 'Key ' .. req_json.key .. ' not found', 404)
            else
                db:put(req_json.key, req_json.value)
                return resp(req, 'OK', 200)
            end
        end
    end
}

return handler