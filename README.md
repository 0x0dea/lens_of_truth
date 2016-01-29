# ![Lens of Truth](http://i.imgur.com/iscFxKa.png) Lens of Truth

**lens_of_truth**, like [its namesake](http://zeldawiki.org/Lens_of_Truth), lets you find things the developers hid from you.

Operating on the assumption that related data tend to live reasonably close together in memory, `Object#find_nearby` looks up and down the heap from the receiver's address in search of an object which meets some specification.

### "Use cases"

Under the hood, `Enumerator` is implemented in terms of fibers so as to support suspension and resumption. CRuby does the right thing by not exposing this implementation detail directly, but maybe we want a reference to the underlying `Fiber` anyway. We know its [approximate location](https://git.io/vzNsN), so let's see if the **Lens of Truth** can help us home in on it:

```ruby
require 'fiber' # for Fiber#transfer
require 'lens_of_truth'

using LensOfTruth # refinement

enum = Enumerator.new { |y|
  y << y.find_nearby(Fiber) << 42
}
enum.next.transfer
enum.next # => cannot resume transferred Fiber (FiberError)
```

Another extremely practical use for the Lens is to peek into the internals of lazy sequences.

```ruby
[].lazy.map(&:succ).take(10)
# => #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator::Lazy: []>:map>:take(10)>
```

Instances of `Enumerator::Lazy` clearly know their history, but they've hitherto been pretty hush-hush about it. In CRuby at least, they store [their method and arguments](https://git.io/vzN8H) in hidden instance variables (ones with no leading asperand and which are thus inaccessible from Ruby land). No matter: since an object's [instance variable table](https://git.io/vzNlq) is in the vicinity of the object itself, the **Lens of Truth** can help us find our way:

```ruby
require 'lens_of_truth/core_ext' # patch Object directly

seq = [].lazy
seq = seq.map(&:succ)
seq.find_nearby(Proc).call(41) # => 42
seq = seq.take(10)
seq.find_nearby(Array) # => [10]
```

Finding the right `Proc` or `Array` is a little harder (read: non-deterministic) since there are usually a lot of them about, but 60% of the time, it works every time.

### Usage

`Object#find_nearby` uses case equality (`===`) when performing the search, so you can scan around for nearby strings matching some regular expression or a numeric object within a given range. You can instead pass a block to be used as the predicate. There's also an optional keyword argument `limit` which specifies how far to search in either direction before bailing. Examples follow.

```ruby
p Object.find_nearby /^[A-Z]+$/
# => "DESTDIR"
p LensOfTruth.find_nearby 42..1337, limit: 9001
# => nil :(
p find_nearby { |o| o.is_a?(Hash) && o.size == 1 }
# => {:frozen_string_literal=>false} :)
```

### Contributing

Interesting use cases welcome.
