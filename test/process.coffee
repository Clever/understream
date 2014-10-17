_             = require 'underscore'
assert        = require 'assert'
child_process = require 'child_process'
Understream   = require "#{__dirname}/../index"

describe '_.process', ->
  it 'detects errors from exit code', (done) ->
    process = child_process.spawn "#{__dirname}/bin/fail_with_err"
    new Understream().process(process).run (err) ->
      assert.equal err?.message, 'exited with code 1'
      done()

  it 'detects errors from signal', (done) ->
    process = child_process.spawn "#{__dirname}/bin/hang_forever"
    new Understream().process(process).run (err) ->
      assert.equal err?.message, "killed by signal SIGKILL"
      done()
    process.kill 'SIGKILL'
