_     = require 'underscore'
assert = require 'assert'
async = require 'async'
_.mixin require("#{__dirname}/../index").exports()

describe 'express', ->
  express = require 'express'
  quest = require 'quest'
  app = express()
  app.set 'port', 6001
  server = app.listen app.settings.port, ->
    console.log "Express server listening on #{app.settings.port}"
  INP = [1...4]
  app.get '/test/success', (req, res, next) ->
    _(INP).stream()
      .map((num) -> num + 10)
      .map(String)
      .pipe(res)
      .run (err) -> next err if err
  app.get '/test/failure', (req, res, next) ->
    seen = -1
    _(INP).stream()
      .transform (obj, enc, cb) ->
        seen++
        if req.query.immediate? or seen
          cb new Error "error from '#{req.url}'"
        else
          cb null, obj
      .pipe(res)
      .run (err) -> next err if err
  app.use (err, req, res, next) -> res.json 500, error: err.message

  it 'pipes to the response', (done) ->
    quest 'http://localhost:6001/test/success', (err, resp, body) ->
      assert.ifError err
      assert.equal resp.statusCode, 200, "received status code #{resp.statusCode} instead of 200 for body #{body}"
      assert.deepEqual body, _([1...4]).map((num) -> String num + 10).join ''
      done()
  it 'returns an error with our global error handler when we fail eventually', (done) ->
    quest 'http://localhost:6001/test/failure', (err, resp, body) ->
      assert.ifError err
      assert.equal resp.statusCode, 500
      assert.deepEqual JSON.parse(body), {error: "error from '/test/failure'"}
      done()
  it 'returns an error with our global error handler when we fail immediately', (done) ->
    quest 'http://localhost:6001/test/failure?immediate=true', (err, resp, body) ->
      assert.ifError err
      assert.equal resp.statusCode, 500
      assert.deepEqual JSON.parse(body), {error: "error from '/test/failure?immediate=true'"}
      done()
