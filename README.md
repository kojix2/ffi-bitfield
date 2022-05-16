# ffi-bitfield

[![Gem Version](https://badge.fury.io/rb/ffi-bitfield.svg)](https://badge.fury.io/rb/ffi-bitfield)
[![test](https://github.com/kojix2/ffi-bitfield/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/ffi-bitfield/actions/workflows/ci.yml)

Bit field for [Ruby-FFI](https://github.com/ffi/ffi)

## Installation

```sh
gem install ffi-bitfield
```

## Usage

Classes

* class BitStruct < FFI::Struct
* class ManagedBitStruct < FFI::ManagedStruct

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

* [ffi-bitfield - read/write bit fields with Ruby-FFI](https://dev.to/kojix2/ffi-bitfield-g4h)

## Contributing

Your feedback is important.

ffi-bitfield is a library under development, so even small improvements like typofix are welcome! Please feel free to send us your pull requests.
Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/ffi-bitfield.

    Do you need commit rights to my repository?
    Do you want to get admin rights and take over the project?
    If so, please feel free to contact me @kojix2.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
