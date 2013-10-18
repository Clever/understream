_     = require 'underscore'
assert = require 'assert'
async = require 'async'
util = require 'util'
_.mixin require("#{__dirname}/../index").exports()

describe 'express', ->
  express = require 'express'
  quest = require 'quest'
  app = express()
  app.set 'port', 6001
  server = app.listen app.settings.port, ->
    console.log "Express server listening on #{app.settings.port}"
  INPUT = [1...4]
  hit_next = false
  beforeEach -> hit_next = false
  app.get '/test/success', (req, res, next) ->
    _(INPUT).stream()
      .map((num) -> num + 10)
      .map(String)
      .pipe(res)
      .run (err) -> next err if err
  app.get '/test/failure', (req, res, next) ->
    sent = false
    _(INPUT).stream()
      .map(String)
      .transform (obj, enc, cb) ->
        delayed_cb = (args...) -> setImmediate cb, args...
        if req.query.immediate? or sent
          delayed_cb new Error "error from '#{req.url}'"
        else
          delayed_cb null, obj
        sent = true
      .pipe(res)
      .run (err) ->
        next err if err
  app.use (err, req, res, next) ->
    hit_next = true
    res.json 500, error: err.message

  it 'pipes to the response', (done) ->
    quest 'http://localhost:6001/test/success', (err, resp, body) ->
      assert.ifError err
      assert.equal resp.statusCode, 200, "received status code #{resp.statusCode} instead of 200 for body #{body}"
      assert.equal body, _(INPUT).map((num) -> String num + 10).join ''
      assert not hit_next
      done()
  it 'returns an error with our global error handler when we fail immediately', (done) ->
    quest 'http://localhost:6001/test/failure?immediate=true', (err, resp, body) ->
      assert.ifError err
      assert.equal resp.statusCode, 500
      assert.deepEqual JSON.parse(body), {error: "error from '/test/failure?immediate=true'"}
      assert hit_next
      done()
  it 'cuts off the body when we fail eventually', (done) ->
    quest 'http://localhost:6001/test/failure', (err, resp, body) ->
      assert.ifError err
      assert.equal resp.statusCode, 200
      assert.equal body, '1'
      assert not hit_next
      done()
