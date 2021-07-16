# ffi-bitfield

[![Gem Version](https://badge.fury.io/rb/ffi-bitfield.svg)](https://badge.fury.io/rb/ffi-bitfield)
[![test](https://github.com/kojix2/ffi-bitfield/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/ffi-bitfield/actions/workflows/ci.yml)

Bit field for [Ruby-FFI](https://github.com/ffi/ffi)

:construction: alpha　ー Supports reading bit fields only.

## Installation

```sh
gem install ffi-bitfield
```

## Usage

```ruby
require 'ffi/bit_struct'

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

s = Struct1.new
s[:a] = 63

p s[:u] # 3
p s[:v] # 3
p s[:w] # 1
p s[:x] # 1
p s[:y] # 0
p s[:z] # 0
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

## API Overview

```md
* module FFI
  * class BitStruct < FFI::Struct
    * include BitFieldSupporter

  * class ManagedBitStruct < FFI::ManagedStruct
    * include BitFieldSupporter

  * module BitField
    * module BitFieldSupporter
      * bit_fields
      * bit_field <- alias of bit_fields
```

## Development

```
git clone https://github.com/kojix2/ffi-bitfield
cd ffi-bitfield
bundle install
bundle exec rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/bitstruct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
