_ = require 'underscore'
{Transform} = require 'writable-stream-parallel'
class MyAwesomeTransform extends Transform
  constructor: (options) -> super _(options).extend { objectMode: true }
  _transform: (chunk, enc, cb) =>
    cb null, chunk + 10

module.exports =
  MyAwesomeTransform: MyAwesomeTransform