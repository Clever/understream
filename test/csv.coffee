assert = require 'assert'
async  = require 'async'
_      = require 'underscore'
_.mixin require("#{__dirname}/../index").exports()
sinon  = require 'sinon'
stream = require 'stream'

describe '_.csv', ->
  error_free = (err) -> assert.ifError err

  # it 'converts a csv to json', (done) ->
  #   # _.stream().file("#{__dirname}/../../clever-agents/test/systems/sftp_friggin_huge/data/schools.csv") # stream().pipe process.stdout
  #   _.stream().file("#{__dirname}/example.csv") # stream().pipe process.stdout
  #   .csv({ columns: true }).value (data) ->
  #     assert.deepEqual data, [{a:1, b:2, c:3}]
  #     done()
  #   .run error_free

  it 'converts a csv to json line by line', (done) ->
    # _.stream().file("#{__dirname}/../../clever-agents/test/systems/sftp_friggin_huge/data/schools.csv") # stream().pipe process.stdout
    _.stream().file("#{__dirname}/example.csv") # stream().pipe process.stdout
    .split(/[\r\n]{1,2}/)
    .csv_line({ columns: true }).value (data) ->
      assert.deepEqual data, [{a:1, b:2, c:3},{a:4, b:5, c:6}]
      done()
    .run error_free

  # TODO: mocha still throws the error...
  # it 'handles errors', (done) ->
  #   _.stream().file("#{__dirname}/example-bad.csv").csv({ from: { quote:'"', escape:'"' }}).value (data) ->
  #     assert false, 'should not get data'
  #   .run (err) ->
  #     console.log 'IN ERROR HANDLER'
  #     assert err.message.match /invalid closing quote/i
  #     done()
