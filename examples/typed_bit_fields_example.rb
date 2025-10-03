# frozen_string_literal: true

require_relative '../lib/ffi/bit_struct'

# Example demonstrating the new bit_fields_typed method

class AccessFlags < FFI::BitStruct
  layout \
    :flags, :uint8

  # New typed syntax with automatic boolean helpers
  bit_fields_typed :flags,
    revoked: [1, :bool],      # Creates revoked and revoked? methods
    expired: [1, :bool],      # Creates expired and expired? methods
    some_string: [4, :string], # Just a regular field (4 bits wide)
    reserved: [2, :int]       # Just a regular field (2 bits wide)
end

# Create instance
flags = AccessFlags.new

# Set boolean flags
flags[:revoked] = 1
flags[:expired] = 0
flags[:some_string] = 15

# Use the automatically generated "?" methods
puts "Is revoked? #{flags.revoked?}"  # => true
puts "Is expired? #{flags.expired?}"  # => false

# Change values
flags[:expired] = 1
puts "Is expired now? #{flags.expired?}"  # => true

# Access the underlying value
puts "Raw flags value: #{flags[:flags]}"  # Shows the combined bit value

# Note: Non-boolean or multi-bit fields don't get "?" methods
# flags.some_string?  # This method doesn't exist
puts "some_string value: #{flags[:some_string]}"  # => 15
