require_relative 'lib/ffi/bit_field/version'

Gem::Specification.new do |spec|
  spec.name          = 'ffi-bitfield'
  spec.version       = FFI::BitField::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'bit fields for Ruby-FFI'
  spec.description   = 'bit fields for Ruby-FFI'
  spec.homepage      = 'https://github.com/kojix2/ffi-bitfield'
  spec.license       = 'MIT'

  spec.files         = Dir['*.{md,txt}', '{lib}/**/*']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'ffi'
end
