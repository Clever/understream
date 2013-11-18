[![Build Status](https://secure.travis-ci.org/Clever/understream.png)](http://travis-ci.org/Clever/understream)

# Understream

Understream is a Node utility for manipulating streams in a functional way.
It provides three classes of functionality:

1. Functions to convert data to [Readable](http://nodejs.org/api/stream.html#stream_class_stream_readable) streams and vice versa:
  * [`fromArray`](#fromArray)
  * [`fromString`](#fromArray)
  * [`toArray`](#toArray)
  * [`range`](#range)

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
  * [`flatten`](#flatten)
  * [`uniq`](#uniq)

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
#### <a name="range">range</a> `_s.range(size, stream_opts)` `_s.range(start, stop[, step, stream_opts])`

Generates the integers from 0 to `size-1`, inclusive.
Alternatively generates integers from `start` to `stop` in increments of `step`, with a default `step` of 1.

```javascript
_s.range(5).on('data', console.log);
// 0
// 1
// 2
// 3
// 4
```

---
#### <a name="each">each</a> `_s.each(readable, iterator[,` [`stream_opts`](#stream_opts)`])`

Calls the iterator function on each object in your stream, and emits the same object when your iterator function is done.
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

*aliases*: `forEach`

---
#### <a name="map">map</a> `_s.map(readable, iterator[,` [`stream_opts`](#stream_opts)`])`

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

*aliases*: `collect`

---
#### <a name="reduce">reduce</a> `_s.reduce(readable, options[,` [`stream_opts`](#stream_opts)`])`

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

*aliases*: `inject`, `foldl`

---
#### <a name="filter">filter</a> `_s.filter(readable, iterator[,` [`stream_opts`](#stream_opts)`])`

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

*aliases*: `select`

---
#### <a name="where">where</a> `_s.where(readable, attrs[,` [`stream_opts`](#stream_opts)`])`

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
#### <a name="invoke">invoke</a> `_s.invoke(readable, method[,` [`stream_opts`](#stream_opts)`])`

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
#### <a name="groupBy">groupBy</a> `_s.groupBy(readable, options[,` [`stream_opts`](#stream_opts)`])`

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
#### <a name="first">first</a> `_s.first(readable[, n,` [`stream_opts`](#stream_opts)`])`

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

*aliases*: `head`, `take`

---
#### <a name="rest">rest</a> `_s.rest(readable[, n,` [`stream_opts`](#stream_opts)`])`

Returns a stream that skips over the first `n` objects in `readable`.
`n` equals 1 by default.

```javascript
var readable = _s.fromArray([1, 2, 3, 4, 5]);
var rest = _s.rest(readable, 3);
rest.on('data', console.log);
// 4
// 5
```

*aliases*: `tail`, `drop`

---
#### <a name="flatten">flatten</a> `_s.flatten(readable[, shallow,` [`stream_opts`](#stream_opts)`])`

Returns a stream that unpacks any arrays into their individual elements.
By default `shallow` is false, and all nested arrays are also unpacked.

```javascript
var readable = _s.fromArray([1, 2, [3], [4], [5, [6]]]);
var flatten = _s.flatten(readable);
flatten.on('data', console.log);
// 1
// 2
// 3
// 4
// 5
// 6
```

---
#### <a name="uniq">uniq</a> `_s.uniq(readable[, sorted, hash_fn,` [`stream_opts`](#stream_opts)`])`

Returns a stream that emits the unique elements of `readable`.
Assumes the input is unsorted unless `sorted` is set to true.
Uses builtin comparison unless `hash_fn` is specified.
Alternatively you can specify one argument containing both parameters: `{sorted: ..., hash_fn: ...}`.

```javascript
var readable = _s.fromArray([4, 4, 3, 2, 1])
var uniq = _s.uniq(readable);
uniq.on('data', console.log);
// 4
// 3
// 2
// 1
```

*aliases*: `unique`

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
#### <a name="value">value</a> `_s.chain(obj)...value()`

Analagous to underscore's `value`: exits a chain and returns the return value of the last method called.

```javascript
var readable = _s.chain(_s.fromArray([3, 4, 5, 6])).value();
// 3
// 4
// 5
// 6
```

### <a name="stream_opts"</a> `stream_opts`

By default, node streams take in some parameters that describe the data in the stream and the behavior of the stream's backpressure:

* `objectMode`: Boolean specifying whether the stream will be processing javascript objects (vs. strings/buffer data).
* `highWaterMark`: Number specifying the maximum size of a stream's internal buffer, i.e. the point at which it starts to exert backpressure on upstreams.
If `objectMode` is true, this represents the maximum number of objects to buffer.
If `objectMode` is false, this represents the number of bytes to buffer.

In general it is a [bad idea](#TODO) to pipe two streams together that have mismatched `objectMode`s.
Thus, all of understream's builtin mixins set `objectMode` equal to the `objectMode` of the readable stream passed in.
This assures that backpressure works properly, and it is recommended you do the same in your own mixins.

<!---

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

### Join

### Process

### Progress

### Queue

### Spawn

### Split

--!>
