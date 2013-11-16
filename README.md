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
};

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

### <a name="fromArray">fromArray</a> `_s.fromArray(array)`

Turns an array into a readable stream of the objects within the array.

```javascript
var readable = _s.fromArray([3, 4, 5, 6]);
console.log(readable.read());
// 3
console.log(readable.read());
// 4
console.log(readable.read());
// 5
console.log(readable.read());
// 6
```

### <a name="fromString">fromString</a> `_s.fromString(string)`

Turns a string into a readable stream of the characters within the string.

```javascript
var readable = _s.fromString("3456");
readable.on("data", console.log);
// 3
// 4
// 5
// 6
```

### <a name="toArray">toArray</a> `_s.toArray(readable, cb)`

Reads a stream into an array of the data emitted by the stream.
Calls `cb(err, arr)` when finished.

```javascript
var readable = _s.fromArray([3, 4, 5, 6]);
_s.toArray(readable, function(err, arr) {
  console.log(arr);
});
// [ 3, 4, 5, 6 ]
```

### <a name="each">each</a> `_s.each(readable, iterator)`

Calls the iterator function on each object in your stream, and passes the same object through when your interator function is done. If the iterator function has one argument (`(element)`), it is assumed to be synchronous. If it has two arguments, it is assumed to be asynchronous (`(element, cb)`).

```javascript
var readable = _s(_s.fromArray([3, 4, 5, 6])).value();
readable.on("data", console.log);
// 3
// 4
// 5
// 6
```

### <a name="chain">chain</a> `_s.chain(obj)`

Analagous to underscore's `chain`: returns a wrapped object with all the methods of understream.

```javascript
_s.chain(_s.fromArray([3, 4, 5, 6])).each(console.log)
// 3
// 4
// 5
// 6
```

### <a name="value">value</a> `_s.chain(obj)`

Analagous to underscore's `value`: exits a chain and returns the return value of the last method called.

```javascript
var readable = _s.chain(_s.fromArray([3, 4, 5, 6])).value();
// 3
// 4
// 5
// 6
```



<!---
### Run
### Duplex
### Readable
### Defaults
### Pipe

### Batch (transform)
`.batch(size)`

Creates batches out of the objects in your stream. Takes in objects, outputs arrays of those objects.

```javascript
_.stream([3, 4, 5, 6]).batch(3).each(console.log).run()
# [3, 4, 5]
# [6]
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
--!>