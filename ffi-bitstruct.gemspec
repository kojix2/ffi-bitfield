# frozen_string_literal: true

require_relative 'lib/ffi/bit_struct/version'

Gem::Specification.new do |spec|
  spec.name          = 'ffi-bitstruct'
  spec.version       = FFI::BitStruct::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'bit fields for Ruby-FFI'
  spec.description   = 'bit fields for Ruby-FFI'
  spec.homepage      = 'https://github.com/kojix2/ffi-bitstruct'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.4'

  spec.files = Dir['*.{md,txt}', '{lib}/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'ffi'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'irb'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
end
