# BitStruct

bit field for [Ruby-FFI](https://github.com/ffi/ffi)

:construction: alpha

## Installation

```sh
gem install ffi-bitstruct
```

## Usage

```ruby
    class Sample < ::FFI::BitStruct
      layout \
        :aaa,            :uint32,
        :bbb,            :int32,
        :ccc,            :int32,
        :ddd,            :int32,

      bitfields :aaa, 
        :a,       2,
        :b,       2,
        :c,       3

      bitfields :bbb, 
        :d,       2,
        :e,       2,
        :f,       3
    end
```

## Development


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bitstruct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
