# ffi-bitstruct

Bit field for [Ruby-FFI](https://github.com/ffi/ffi).

:construction: alpha

## Installation

```sh
gem install ffi-bitstruct
```

## Usage

```ruby
require 'ffi/bitstruct'

class Struct1 < FFI::BitStruct
  layout \
    :a, :uint8,
    :b, :uint8

  bitfields :a,
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

## Development

```
git clone https://github.com/kojix2/ffi-bitstruct
cd ffi-bitstruct
bundle install
bundle exec rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bitstruct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
