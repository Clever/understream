_           = require 'underscore'
assert      = require 'assert'
Understream = require "#{__dirname}/../index"
{Transform} = require 'readable-stream'
_.mixin Understream.exports()

# domain_thrown (0,8) vs domainThrown (0.10)
was_thrown = (domain_err) ->
  return domain_err.domain_thrown if domain_err.domain_thrown?
  domain_err.domainThrown

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

describe '_.duplex', ->
  it 'allows you to run one stream', (done) ->
    Understream.mixin Add, 'add'
    Understream.mixin Mult, 'mult'
    math = _.stream().add(1).duplex()
    inp = [1, 2, 3, 4]
    _([1, 2, 3, 4]).stream().pipe(math).run (err, result) ->
      assert.ifError err
      assert.equal result.length, 4
      assert.deepEqual result, (num+1 for num in inp)
      done()

  it 'allows you to combine multiple streams', (done) ->
    Understream.mixin Add, 'add'
    Understream.mixin Mult, 'mult'
    math = _.stream().add(1).mult(2).mult(2).mult(2).mult(2).duplex()
    inp = [1, 2, 3, 4]
    _([1, 2, 3, 4]).stream().pipe(math).run (err, result) ->
      assert.ifError err
      assert.equal result.length, 4
      assert.deepEqual result, ((num+1) * 16 for num in inp)
      done()

  it "allows user to handle any thrown errors", (done) ->
    return done() if process.versions.node.match /^0\.8/
    cnt = 0
    bad_fn = (input, cb) ->
      if cnt++ is 0 then cb null, input else throw new Error('one and done') # throw
    bad_stream = _.stream().each(bad_fn).duplex()
    _([1,2,3]).stream().pipe(bad_stream).run (err) ->
      assert.equal was_thrown(err), true, "Expected error caught by domain to be thrown"
      assert.equal err.message, 'one and done'
      done()
