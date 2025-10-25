# ffi-bitfield

[![Gem Version](https://badge.fury.io/rb/ffi-bitfield.svg)](https://badge.fury.io/rb/ffi-bitfield)
[![test](https://github.com/kojix2/ffi-bitfield/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/ffi-bitfield/actions/workflows/ci.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fffi-bitfield%2Flines)](https://tokei.kojix2.net/github/kojix2/ffi-bitfield)

Bit field for [Ruby-FFI](https://github.com/ffi/ffi)

## Installation

```sh
gem install ffi-bitfield
```

## Usage

Classes

- class BitStruct < FFI::Struct
- class ManagedBitStruct < FFI::ManagedStruct

Loading

```ruby
require 'ffi/bit_struct'
require 'ffi/managed_bit_struct'
```

Define your struct

```ruby
class Struct1 < FFI::BitStruct
  layout \
    :a, :uint8,
    :b, :uint8

  bit_fields :a,
    :u, 2,
    :v, 2,
    :w, 1,
    :x, 1,
    :y, 1,
    :z, 1
end
```

Reading

```ruby
s = Struct1.new

s[:a] = 63
p s[:u] # 3
p s[:v] # 3
p s[:w] # 1
p s[:x] # 1
p s[:y] # 0
p s[:z] # 0
```

Writing

```ruby
s = Struct1.new

s[:u] = 0
s[:v] = 0
s[:w] = 0
s[:x] = 0
s[:y] = 1
p s[:a] # 64
```

### Typed Bit Fields

You can use the `bit_fields_typed` method to define bit fields with type information. This method accepts a hash where keys are field names and values are arrays containing `[width, type]`. For boolean fields (width of 1 with `:bool` type), it automatically generates a `?` helper method:

```ruby
class AccessFlags < FFI::BitStruct
  layout \
    :flags, :uint8

  bit_fields_typed :flags,
    revoked: [1, :bool],      # Creates revoked and revoked? methods
    expired: [1, :bool],      # Creates expired and expired? methods
    some_string: [4, :string], # Creates some_string method (no ? helper)
    reserved: [2, :int]       # Creates reserved method (no ? helper)
end

flags = AccessFlags.new
flags[:revoked] = 1
flags[:expired] = 0

p flags.revoked?  # => true
p flags.expired?  # => false

flags[:expired] = 1
p flags.expired?  # => true
```

The `?` methods are only generated for fields that are 1 bit wide and have type `:bool`. Other field types can be used for documentation purposes and future functionality.

### Inspecting Bit Fields

You can use the `bit_field_members` method to get a hash of bit fields grouped by parent field:

```ruby
class Flags < FFI::BitStruct
  layout \
    :value, :uint8

  bit_fields :value,
    :read,    1,
    :write,   1,
    :execute, 1,
    :unused,  5
end

p Flags.bit_field_members
# => {:value=>[:read, :write, :execute, :unused]}
```

For more detailed information, you can use the `bit_field_layout` method:

```ruby
p Flags.bit_field_layout
# => {
#      :value => {
#        :read    => { :start => 0, :width => 1 },
#        :write   => { :start => 1, :width => 1 },
#        :execute => { :start => 2, :width => 1 },
#        :unused  => { :start => 3, :width => 5 }
#      }
#    }
```

These methods are useful for custom pretty printing or introspection of your bit struct classes.

### Loading

```ruby
require 'ffi/bit_field'
```

The above is the same as below.

```ruby
require 'ffi/bit_struct'
require 'ffi/managed_bit_struct'
```

## Development

```
git clone https://github.com/kojix2/ffi-bitfield
cd ffi-bitfield
bundle install
bundle exec rake test
```

- [ffi-bitfield - read/write bit fields with Ruby-FFI](https://dev.to/kojix2/ffi-bitfield-g4h)

## Contributing

Your feedback is important.

ffi-bitfield is a library under development, so even small improvements like typofix are welcome! Please feel free to send us your pull requests.
Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/ffi-bitfield.

    Do you need commit rights to my repository?
    Do you want to get admin rights and take over the project?
    If so, please feel free to contact me @kojix2.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
