local http_client = require('http.client')
local json = require('json')
local log = require('log')

local client = http_client.new()
local absentKey = 'absentKey'

local function request(method, key, body)
    return client:request(
            method, '0.0.0.0:8080/kv/' .. key, body, { headers = { ["Content-Type"] = "text/plain" } }
    )
end

local function testFailed(msg)
    log.error('Test failed => ' .. msg)
end

local function testGet()
    local resp = request('GET', '1', nil)
    if resp.status ~= 200 then
        testFailed('testGet: resp code 200 ~= ' .. resp.status)
    end
end

local function testGetNotFound()
    local resp = request('GET', absentKey, nil)
    if resp.status ~= 404 then
        testFailed('testGetEmpty: resp code 404 ~= ' .. resp.status)
        return
    end
    if resp.body ~= 'Key ' .. absentKey .. ' not found' then
        testFailed('testGetEmpty: expected null body received ' .. json.encode(resp.body))
    end
end

local function testPut()
    local resp = request('PUT', '1', '{ "value": "val1" }')
    if resp.status ~= 200 then
        testFailed('testPut: resp code 200 ~= ' .. resp.status)
    end
end

local function testPutNotFound()
    local resp = request('PUT', absentKey, '{ "value": "val2" }')
    if resp.status ~= 404 then
        testFailed('testPutNotFound: resp code 404 ~= ' .. resp.status)
    end
end


local function testDelete()
    local resp = request('DELETE', '1', nil)
    if resp.status ~= 200 then
        testFailed('testDelete: resp code 200 ~= ' .. resp.status)
    end
end

local function testDeleteNotFound()
    local resp = request('DELETE', '1', nil)
    if resp.status ~= 404 then
        testFailed('testDelete: resp code 404 ~= ' .. resp.status)
    end
end

local function testPostExistingKey()
    local resp = request('POST', '', '{ "key":"1", "value":"val4" }')
    if resp.status ~= 409 then
        testFailed('testPostExistingKey: 409 ~= ' .. resp.status)
    end
end

local function testPostAbsentKey()
    local resp = request('POST', '', '{ "key":"1", "value":"val3" }')
    if resp.status ~= 200 then
        testFailed('checkNotExistingKeyPost: expected 404 but recieved ' .. resp.status)
        return
    end
end

local test = {
    run = function()
        log.info('Start tests')
        testGetNotFound()
        testPutNotFound()
        testPostAbsentKey()
        testPut()
        testGet()
        testPostExistingKey()
        testDelete()
        testDeleteNotFound()
        log.info('Passed')
    end
}
return test