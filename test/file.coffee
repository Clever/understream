assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
{Readable} = require 'stream'
fs = require 'fs'

TEST_TXT_CONTENTS = fs.readFileSync "#{__dirname}/test.txt", { encoding: 'utf8' }

describe '_.file', ->
  it 'readable side works', (done) ->
    _.stream().file("#{__dirname}/test.txt", { encoding: 'utf8' }).value (data) ->
      assert.equal data.join(), TEST_TXT_CONTENTS
      done()
    .run assert.ifError

  it 'readable + writable side works', (done) ->
    # might be doing parallel builds on different versions so make a unique tmp file
    tmp = "#{__dirname}/test-copy-#{require('crypto').randomBytes(4).readUInt32LE(0)}.txt"
    _.stream()
    .file("#{__dirname}/test.txt", { encoding: 'utf8' })
    .file(tmp, { encoding: 'utf8' })
    .run (err) ->
      tmp_contents = fs.readFileSync(tmp, { encoding: 'utf8' })
      fs.unlinkSync tmp
      assert.equal TEST_TXT_CONTENTS, tmp_contents, "'#{TEST_TXT_CONTENTS}' != '#{tmp_contents}' for #{tmp}"
      done()
