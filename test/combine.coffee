_           = require 'underscore'
assert      = require 'assert'
Understream = require "#{__dirname}/../index"
{Transform} = require 'readable-stream'
_.mixin Understream.exports()

class Add extends Transform
  constructor: (@num) ->
    super objectMode: true
  _transform: (number, encoding, cb) =>
    cb null, number + @num
class Mult extends Transform
  constructor: (@num) ->
    super objectMode: true
  _transform: (number, encoding, cb) =>
    cb null, number * @num

describe 'Understream.combine', ->
  it 'allows you to combine multiple streams', (done) ->
    Understream.mixin Add, 'add'
    Understream.mixin Mult, 'mult'
    math = _.stream().add(1).mult(2).mult(2).mult(2).mult(2).combine()
    inp = [1, 2, 3, 4]
    _([1, 2, 3, 4]).stream().pipe(math).value (result) ->
      assert.equal result.length, 4
      assert.deepEqual result, ((num+1) * 16 for num in inp)
      done()
    .run assert.ifError
