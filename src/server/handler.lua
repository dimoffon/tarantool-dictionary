local json = require('json')
local avro = require('avro_schema')
local db = require('db')
log = require('log')

ok, schema = avro.create {
    type = "record",
    name = "dict_schema",
    fields = {
        { name = "key", type = "string" },
        { name = "value", type = "string" }
    }
}

ok, schema_short = avro.create {
    type = "record",
    name = "dict_schema",
    fields = {
        { name = "value", type = "string" }
    }
}

local rps_limit = tonumber(os.getenv('RPS_LIMIT'))
prev_time, current_rps = 0, 0

local resp = function (req, msg, status)
    local resp = req:render({ text = msg })
    resp.status = status
    return resp
end

local validate = function (req, schema)
    return avro.validate(schema, json.decode(req))
end

local rps = function()
    res = false
    local now = os.time()
    if os.difftime(now, prev_time) == 0 then
        current_rps = current_rps + 1
        if current_rps > rps_limit then
            res = true
        end
    else
        current_rps = 1
    end
    log.info('rps ' .. current_rps .. '/' .. rps_limit)
    prev_time = now
    return res
end

local handler = {
    get = function(req)
        if rps() == true then
            return resp(req, json.encode('RPS limit is exceeded'), 429)
        end
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
        if rps() == true then
            return resp(req, json.encode('RPS limit is exceeded'), 429)
        end
        local key = req:stash('key')
        log.info('Received PUT request with key ' .. key)
        local valid, req_json = validate(req:read(), schema_short)
        if valid == false then
            return resp(req, 'Invalid message format', 400)
        else
            local obj = db:get(key)
            if obj == nil then
                return resp(req, 'Key ' .. key .. ' not found', 404)
            else
                db:put(key, req_json.value)
                return resp(req, 'OK', 200)
            end
        end
    end,

    del = function(req)
        if rps() == true then
            return resp(req, json.encode('RPS limit is exceeded'), 429)
        end
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
        if rps() == true then
            return resp(req, json.encode('RPS limit is exceeded'), 429)
        end
        log.info('Received POST request')
        local valid, req_json = validate(req:read(), schema)
        if valid == false or req_json.key == nil then
            return resp(req, 'Invalid message format', 400)
        else
            local obj = db:get(req_json.key)
            if obj ~= nil then
                return resp(req, 'Key ' .. req_json.key .. ' already exists', 409)
            else
                db:put(req_json.key, req_json.value)
                return resp(req, 'OK', 200)
            end
        end
    end
}

return handler