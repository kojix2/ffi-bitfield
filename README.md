# ffi-bitstruct

bit field for [Ruby-FFI](https://github.com/ffi/ffi)

:construction: alpha

## Installation

```sh
gem install ffi-bitstruct
```

## Usage

```ruby
require 'ffi/bitstruct'

class Sample < ::FFI::BitStruct
  layout \
    :a,   :uint32,
    :b,   :int32,

  bitfields :a, 
    :ax,       2,
    :ay,       2,
    :az,       3

  bitfields :b, 
    :bx,       2,
    :by,       2,
    :bz,       3
end
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
