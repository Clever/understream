_     = require 'underscore'
assert = require 'assert'
async = require 'async'
sinon = require 'sinon'
util = require 'util'
_.mixin require("#{__dirname}/../index").exports()

describe 'express', ->
  express = require 'express'
  quest = require 'quest'
  INPUT = [1...4]
  PORT = 6001
  error_handler = (err, req, res, next) -> res.json 500, error: err.message

  beforeEach ->
    app = express()
    @server = app.listen PORT, -> console.log "Express server listening on #{PORT}"
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
        .run (err) -> next err if err
    @spy = sinon.spy error_handler
    app.use @spy
  afterEach -> @server.close()

  it 'pipes to the response', (done) ->
    quest 'http://localhost:6001/test/success', (err, resp, body) =>
      assert.ifError err
      assert.equal resp.statusCode, 200, "received status code #{resp.statusCode} instead of 200 for body #{body}"
      assert.equal body, _(INPUT).map((num) -> String num + 10).join ''
      assert.equal @spy.callCount, 0
      done()
  it 'returns an error with our global error handler when we fail immediately', (done) ->
    quest 'http://localhost:6001/test/failure?immediate=true', (err, resp, body) =>
      assert.ifError err
      assert.equal resp.statusCode, 500
      assert.deepEqual JSON.parse(body), {error: "error from '/test/failure?immediate=true'"}
      assert.equal @spy.callCount, 1
      done()
  it 'cuts off the body when we fail eventually', (done) ->
    quest 'http://localhost:6001/test/failure', (err, resp, body) =>
      assert.ifError err
      assert.equal resp.statusCode, 200
      assert.equal body, '1'
      assert.equal @spy.callCount, 0
      done()
