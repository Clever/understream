[![Build Status](https://secure.travis-ci.org/Clever/understream.png)](http://travis-ci.org/Clever/understream)

# Understream

Understream is a Node utility for manipulating streams in a functional way.
It provides three classes of functionality:

1. Functions to convert data to [Readable](http://nodejs.org/api/stream.html#stream_class_stream_readable) streams and vice versa:
  * [`fromArray`](#fromArray)
  * [`fromString`](#fromArray)
  * [`toArray`](#toArray)

2. Functions that take a Readable stream and transform its data, returning a new readable stream:
  * [`each`](#each)
  * [`map`](#map)
  * [`reduce`](#reduce)
  * [`filter`](#filter)
  * [`where`](#where)
  * [`invoke`](#invoke)
  * [`groupBy`](#groupBy)
  * [`first`](#first)
  * [`rest`](#rest)

3. Functions that allow you to create chains of transformations:
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

#### <a name="fromArray">fromArray</a> `_s.fromArray(array)`

Turns an array into a readable stream of the objects within the array.

```javascript
var readable = _s.fromArray([3, 4, 5, 6]);c
readable.on("data", console.log);
// 3
// 4
// 5
// 6
```

---
#### <a name="fromString">fromString</a> `_s.fromString(string)`

Turns a string into a readable stream of the characters within the string.

```javascript
var readable = _s.fromString("3456");
readable.on("data", console.log);
// 3
// 4
// 5
// 6
```

---
#### <a name="toArray">toArray</a> `_s.toArray(readable, cb)`

Reads a stream into an array of the data emitted by the stream.
Calls `cb(err, arr)` when finished.

```javascript
var readable = _s.fromArray([3, 4, 5, 6]);
_s.toArray(readable, function(err, arr) {
  console.log(arr);
});
// [ 3, 4, 5, 6 ]
```

---
#### <a name="each">each</a> `_s.each(readable, iterator)`

Calls the iterator function on each object in your stream, and emits the same object when your interator function is done.
If the iterator function has one argument (`(element)`), it is assumed to be synchronous.
If it has two arguments, it is assumed to be asynchronous (`(element, cb)`).

```javascript
var readable = _s.fromArray([3, 4, 5, 6]);
_s.each(readable, console.log);
// 3
// 4
// 5
// 6
```

---
#### <a name="map">map</a> `_s.map(readable, iterator)`

Makes a new stream that is the result of calling `iterator` on each piece of data in `readable`.
If the iterator function has one argument (`(element)`), it is assumed to be synchronous.
If it has two arguments, it is assumed to be asynchronous (`(element, cb)`).

```javascript
var readable = _s.fromArray([3.3, 4.1, 5.2, 6.4]));
var mapped = _s.map(readable, Math.floor);
mapped.on("data", console.log);
// 3
// 4
// 5
// 6
```

---
#### <a name="reduce">reduce</a> `_s.reduce(readable, options)`

Boils a stream down to a single value. `options` takes in:
* `base`: value or function that represents/returns the initial state of the reduction.
* `fn`: function that takes in two arguments: the current state of the reduction, and a new piece of incoming data, and returns the updated state of the reduction.
* `key`: optional function to apply to incoming data in order to partition the incoming data into separate reductions.

```javascript
var readable = _s.fromArray([1, 2, 3]);
var reduced = _s.reduce(readable, {
  base: 0,
  fn: function(a, b) { return a + b; }
});
reduced.on('data', console.log);
// 6
```

```javascript
var readable = _s.fromArray([
  {a: 1, b: 2},
  {a: 1, b: 3},
  {a: 1, b: 4},
  {a: 2, b: 1},
  {a: 3, b: 2}
]);
var reduced = _s.reduce(readable, {
  base: function() { return {}; },
  key: function(new_obj) { return new_obj.a; },
  fn: function(obj, new_obj) {
    if (obj.b == null) {
      obj = {
        a: new_obj.a,
        b: []
      };
    }
    obj.b.push(new_obj.b);
    return obj;
  }
});
reduced.on('data', console.log);
// { a: 1, b: [ 2, 3, 4 ] }
// { a: 2, b: [ 1 ] }
// { a: 3, b: [ 2 ] }
```

---
#### <a name="filter">filter</a> `_s.filter(readable, iterator)`

Returns a readable stream that emits all data from `readable` that passes `iterator`.
If it has only one argument, `iterator` is assumed to be synchronous.
If it has two arguments, it is assumed to return its result asynchronously.

```javascript
var readable = _s.fromArray([1, 2, 3, 4]);
var filtered = _s.filter(readable, function(num) { return num % 2 === 0 });
// var filtered = _s.filter(readable, function(num, cb) {
//    setTimeout(function() { cb(null, num % 2 === 0); }, 1000);
// });
filtered.on('data', console.log);
// 2
// 4
```

---
#### <a name="where">where</a> `_s.where(readable, attrs)`

Filters `readable` to emit only objects that contain the attributes in the `attrs` object.

```javascript
var readable = _s.fromArray([
  {a: 1, b: 2},
  {a: 2, b: 2},
  {a: 1, b: 3},
  {a: 1, b: 4}
])
var whered = _s.where(readable, {a:1});
whered.on('data', console.log);
// { a: 1, b: 2 }
// { a: 1, b: 3 }
// { a: 1, b: 4 }
```

---
#### <a name="invoke">invoke</a> `_s.invoke(readable, method)`

Returns a stream that emits the results of invoking `method` on every object in `readable`.

```javascript
var readable = _s.fromArray([
  {m: function() { return 1; }},
  {m: function() { return 2; }}
])
var invoked = _s.invoke(readable, 'm');
invoked.on('data', console.log);
// 1
// 2
```

---
#### <a name="groupBy">groupBy</a> `_s.groupBy(readable, options)`

When `options` is a function, creates a stream that will emit an object representing the groupings of the data in `readable` partitioned by the function.

```javascript
var readable = _s.fromArray([1.3, 2.1, 2.4]);
var grouped = _s.groupBy(readable, Math.floor);
grouped.on('data', console.log);
// { '1': [ 1.3 ], '2': [ 2.1, 2.4 ] }
```

Alternatively, `options` can be an object containing the following keys:
* `fn`: the function to apply to data coming through `readable`.
* `unpack`: emit each grouping as a separate object.

```javascript
var readable = _s.fromArray([1.3, 2.1, 2.4]);
var grouped = _s.groupBy(readable, {fn: Math.floor, unpack: true});
grouped.on('data', console.log);
// { '1': [ 1.3 ] }
// { '2': [ 2.1, 2.4 ] }
```

---
#### <a name="first">first</a> `_s.first(readable[, n])`

Returns a stream that only emits the first `n` objects in `readable`.
`n` equals 1 by default.

```javascript
var readable = _s.fromArray([1, 2, 3, 4, 5]);
var first = _s.first(readable, 3);
first.on('data', console.log);
// 1
// 2
// 3
```

---
#### <a name="rest">rest</a> `_s.rest(readable[, n])`

Returns a stream that skips over the first `n` objects in `readable`.
`n` equals 1 by default.

```javascript
var readable = _s.fromArray([1, 2, 3, 4, 5]);
var rest = _s.rest(readable, 3);
rest.on('data', console.log);
// 4
// 5
```

---
#### <a name="chain">chain</a> `_s.chain(obj)`

Analagous to underscore's `chain`: returns a wrapped object with all the methods of understream.

```javascript
_s.chain(_s.fromArray([3, 4, 5, 6])).each(console.log)
// 3
// 4
// 5
// 6
```

---
#### <a name="value">value</a> `_s.chain(obj)`

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

### Process

### Progress

### Queue

### Reduce

### Spawn

### Split

### Uniq

### Where
--!>