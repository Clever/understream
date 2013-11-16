[![Build Status](https://secure.travis-ci.org/Clever/understream.png)](http://travis-ci.org/Clever/understream)

# Understream

Understream is a Node utility for manipulating streams in a functional way.
It provides three classes of functionality:

1. Functions to convert data to [Readable](http://nodejs.org/api/stream.html#stream_class_stream_readable) streams and vice versa:
  * [`fromArray`](#fromArray)
  * [`fromString`](#fromArray)
  * [`toArray`](#toArray)

2. Functions that take a Readable stream and transform its data:

  * [`each`](#each)

3. Functions that allow you to create chains of transformations

  * [`chain`](#chain)
  * [`value`](#value)

The library has underscore-like usage:

```javascript
var _s = require('understream');
input = _.fromArray([3, 4, 5, 6]);
_s.chain(input).map(function(num) {return num+10}).each(console.log);
// 13
// 14
// 15
// 16
```

It also makes it very easy to mix in your own streams:

```javascript
var Transform = require('stream').Transform
var util = require('util');
var _s = require('understream');

util.inherits(Math, Transform);

function Math(stream_opts) {
    Transform.call(this, stream_opts);
}

Math.prototype._transform = function (num, enc, cb) {
    cb(null, num+10);
};

_s.mixin({
    add10: function(readable, stream_opts) {
      return readable.pipe(new Math(stream_opts));
    }
});

input = _s.fromArray([3, 4, 5, 6]);
_s(input).chain().add10({objectMode:true}).each(console.log);
// 13
// 14
// 15
// 16
```

## Methods

### Run
### Duplex
### Readable
### Defaults
### Pipe

## Default mixins

### Batch (transform)
`.batch(size)`

Creates batches out of the objects in your stream. Takes in objects, outputs arrays of those objects.

```javascript
_.stream([3, 4, 5, 6]).batch(3).each(console.log).run()
# [3, 4, 5]
# [6]
```

### <a name="each">Each</a>
`_s.each(readable, iterator)`

Calls the iterator function on each object in your stream, and passes the same object through when your interator function is done. If the iterator function has one argument (`(element)`), it is assumed to be synchronous. If it has two arguments, it is assumed to be asynchronous (`(element, cb)`).

```javascript
_s(_.fromArray([3, 4, 5, 6])).each(console.log)
# 3
# 4
# 5
# 6
```

### File (transform)
`.file(filepath)`

Streams the content out of a file.

```javascript
_.stream().file(path_to_file).split('\n').each(console.log).run()
# line1
# line2
# line3
# ...
```

### Filter
`.each(iterator)`

Calls the iterator for each object in your stream, passing through only the values that pass a truth test (iterator).

```javascript
_.stream([3, 4, 5, 6]).filter(function (n) { return n > 4 }).each(console.log).run()
# 5
# 6
```

### First
`.first([n])`

Passes through only the first `n` objects. If called with no arguments, assumes `n` is `1`.

Passes through only the first object in the stream. Passing `n` will pass through the first `n` objects.

```javascript
_.stream([3, 4, 5, 6]).first(2).each(console.log).run()
# 3
# 4
```

### GroupBy

### Invoke

### Join

### Map

### Process

### Progress

### Queue

### Reduce

### Spawn

### Split

### Uniq

### Where
