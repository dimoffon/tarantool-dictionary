# Dictionary storage
Dictionary of key-value pairs with REST API accessed via HTTP. 
JSON message format with schema validation using Apache Avro (https://github.com/tarantool/avro-schema). 
Tarantool as database and http application server (https://github.com/tarantool/http), listening on port 8080.
Tarantool Document module (https://github.com/tarantool/document) is used for values transformation in dictionary.

### Requirements
Docker and/or docker-compose are required to run the application.

### Configurable parameter
Parameter available in docker-compose.yml
- `RPS_LIMIT`  defines the request-per-second limit (default value is 10). Applied for all supported operations.

### How to run
##### Running with docker-compose
~~~~ 
docker-compose build
docker-compose up
~~~~ 
##### Running with docker
~~~~ 
docker container stop dict
docker image build -t dict:1.0 .
docker container run --rm -d --name dict -e RPS_LIMIT=10 dict:1.0
~~~~ 

### Message format
Message format is a simple JSON message with two parameters `key` and `value`. Values of `value` parameter can be presented as arbitray JSON message. Example:
~~~~ 
{ "key" : "key1", "value" : "value1" }
~~~~ 

### Constraints
- `POST` responds with 409 code if key already exists
- `POST`, `PUT` respond with 400 code if request message body is invalid
- `PUT`, `GET`, `DELETE` respond 404 code if key from the request is absent in dictionary
- respond with 429 code if rps exceeded `RPS_LIMIT`

### Request samples:
##### POST
~~~~
POST /kv HTTP/1.1
Host: tarantool-dictionary.herokuapp.com
Content-Type: application/json
Cache-Control: no-cache
Postman-Token: bdfcafbb-aeb6-ff5a-5d7a-bea427c053e9

{"key" : "1", "value" : "value1"}
~~~~
##### GET 
~~~~
GET /kv/1 HTTP/1.1
Host: tarantool-dictionary.herokuapp.com
Content-Type: application/json
Cache-Control: no-cache
Postman-Token: c0efd0c5-cf10-62c7-af6a-7b9857bbe69d
~~~~
##### PUT
~~~~
PUT /kv/1 HTTP/1.1
Host: tarantool-dictionary.herokuapp.com
Content-Type: application/json
Cache-Control: no-cache
Postman-Token: 277ffc98-ed72-25d8-c536-bf8dacea2109

{"value" : "value11"}
~~~~
##### DELETE
~~~~
DELETE /kv/1 HTTP/1.1
Host: tarantool-dictionary.herokuapp.com
Content-Type: text/plain
Cache-Control: no-cache
Postman-Token: f7841e1f-7973-0283-5930-1b604cc1e78e
~~~~
