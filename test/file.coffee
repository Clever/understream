assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
{Readable} = require 'readable-stream'
fs = require 'fs'

TEST_TXT_CONTENTS = fs.readFileSync "#{__dirname}/test.txt", { encoding: 'utf8' }

describe '_.file', ->
  it 'readable side works', (done) ->
    _.stream().file("#{__dirname}/test.txt", { encoding: 'utf8' }).value (data) ->
      assert.equal data.join(), TEST_TXT_CONTENTS
      done()
    .run assert.ifError

  it 'readable + writable side works', (done) ->
    _.stream()
    .file("#{__dirname}/test.txt", { encoding: 'utf8' })
    .file("#{__dirname}/test-copy.txt", { encoding: 'utf8' })
    .run (err) ->
      assert.equal TEST_TXT_CONTENTS, fs.readFileSync("#{__dirname}/test-copy.txt", { encoding: 'utf8' })
      done()
