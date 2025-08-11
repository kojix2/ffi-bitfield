# frozen_string_literal: true

require 'test_helper'
require 'ffi/bit_struct'
require 'ffi/managed_bit_struct'

class MixedFieldsTest < Minitest::Test
  # Test the bug report reproduction case
  def test_bug_report_reproduction_case
    test_struct_class = Class.new(FFI::BitStruct) do
      layout \
        :regular_float, :float,
        :regular_int,   :int,
        :bitfield_data, :uint32

      bit_fields :bitfield_data,
                 :flag1, 1,
                 :flag2, 1,
                 :remaining, 30
    end

    struct = test_struct_class.new

    # This should work (was failing before the fix)
    struct[:regular_float] = 3.14
    assert_in_delta 3.14, struct[:regular_float], 0.01

    # This should work and does work
    struct[:flag1] = 1
    assert_equal 1, struct[:flag1]

    # This should work (was failing before the fix for non-Integer types)
    struct[:regular_int] = 42
    assert_equal 42, struct[:regular_int]

    # Test bitfield operations still work correctly
    struct[:flag2] = 0
    struct[:remaining] = 12_345
    assert_equal 0, struct[:flag2]
    assert_equal 12_345, struct[:remaining]
  end

  # Test that type errors only occur for bitfields, not regular fields
  def test_type_error_only_for_bitfields
    test_struct_class = Class.new(FFI::BitStruct) do
      layout \
        :regular_float, :float,
        :regular_double, :double,
        :regular_int, :int,
        :bitfield_data, :uint32

      bit_fields :bitfield_data,
                 :flag, 1,
                 :value, 8
    end

    struct = test_struct_class.new

    # Regular fields should accept appropriate types
    struct[:regular_float] = 3.14
    struct[:regular_double] = 2.718281828
    struct[:regular_int] = -42

    # Verify the values
    assert_in_delta 3.14, struct[:regular_float], 0.01
    assert_in_delta 2.718281828, struct[:regular_double], 0.000000001
    assert_equal(-42, struct[:regular_int])

    # Bitfields should only accept Integers
    struct[:flag] = 1
    struct[:value] = 255

    # Bitfields should reject non-Integers
    assert_raises(TypeError) { struct[:flag] = 3.14 }
    assert_raises(TypeError) { struct[:flag] = 'string' }
    assert_raises(TypeError) { struct[:value] = 3.14 }
    assert_raises(TypeError) { struct[:value] = 'string' }
  end

  # Test with ManagedBitStruct
  def test_managed_bit_struct_mixed_fields
    test_struct_class = Class.new(FFI::ManagedBitStruct) do
      layout \
        :regular_float, :float,
        :bitfield_data, :uint32

      bit_fields :bitfield_data,
                 :flag1, 1,
                 :flag2, 1,
                 :remaining, 30

      def self.release(ptr)
        # Do nothing for testing
      end
    end

    memory_pointer = FFI::MemoryPointer.new(:float, 2) # float + uint32
    ptr = FFI::Pointer.new(memory_pointer)
    struct = test_struct_class.new(ptr)

    # Regular field should accept float
    struct[:regular_float] = 2.5
    assert_in_delta 2.5, struct[:regular_float], 0.001

    # Bitfields should work normally
    struct[:flag1] = 1
    struct[:flag2] = 0
    struct[:remaining] = 999_999

    assert_equal 1, struct[:flag1]
    assert_equal 0, struct[:flag2]
    assert_equal 999_999, struct[:remaining]

    # Bitfields should still reject non-Integers
    assert_raises(TypeError) { struct[:flag1] = 2.5 }
  end

  # Test with various FFI field types
  def test_various_ffi_field_types
    test_struct_class = Class.new(FFI::BitStruct) do
      layout \
        :uint8_field, :uint8,
        :uint16_field, :uint16,
        :uint32_field, :uint32,
        :uint64_field, :uint64,
        :int8_field, :int8,
        :int16_field, :int16,
        :int32_field, :int32,
        :int64_field, :int64,
        :float_field, :float,
        :double_field, :double,
        :bitfield_data, :uint32

      bit_fields :bitfield_data,
                 :bit_flag, 1
    end

    struct = test_struct_class.new

    # All regular FFI fields should accept appropriate values
    struct[:uint8_field] = 255
    struct[:uint16_field] = 65_535
    struct[:uint32_field] = 4_294_967_295
    struct[:uint64_field] = 18_446_744_073_709_551_615
    struct[:int8_field] = -128
    struct[:int16_field] = -32_768
    struct[:int32_field] = -2_147_483_648
    struct[:int64_field] = -9_223_372_036_854_775_808
    struct[:float_field] = 3.14159
    struct[:double_field] = 2.718281828459045

    # Verify values
    assert_equal 255, struct[:uint8_field]
    assert_equal 65_535, struct[:uint16_field]
    assert_equal 4_294_967_295, struct[:uint32_field]
    assert_equal 18_446_744_073_709_551_615, struct[:uint64_field]
    assert_equal(-128, struct[:int8_field])
    assert_equal(-32_768, struct[:int16_field])
    assert_equal(-2_147_483_648, struct[:int32_field])
    assert_equal(-9_223_372_036_854_775_808, struct[:int64_field])
    assert_in_delta 3.14159, struct[:float_field], 0.0001
    assert_in_delta 2.718281828459045, struct[:double_field], 0.000000000000001

    # Bitfield should still work and enforce Integer type
    struct[:bit_flag] = 1
    assert_equal 1, struct[:bit_flag]
    assert_raises(TypeError) { struct[:bit_flag] = 3.14 }
  end

  # Test that existing bitfield functionality is not broken
  def test_bitfield_functionality_preserved
    test_struct_class = Class.new(FFI::BitStruct) do
      layout \
        :regular_field, :int,
        :bitfield_data, :uint32

      bit_fields :bitfield_data,
                 :flag1, 1,
                 :flag2, 1,
                 :value, 8,
                 :remaining, 22
    end

    struct = test_struct_class.new

    # Test bitfield operations
    struct[:flag1] = 1
    struct[:flag2] = 0
    struct[:value] = 255
    struct[:remaining] = 1_048_575 # 2^20 - 1

    assert_equal 1, struct[:flag1]
    assert_equal 0, struct[:flag2]
    assert_equal 255, struct[:value]
    assert_equal 1_048_575, struct[:remaining]

    # Test negative values (bit-flipping)
    struct[:value] = -1 # Should become 255 (all bits set in 8-bit field)
    assert_equal 255, struct[:value]

    # Test range checking
    assert_raises(ArgumentError) { struct[:flag1] = 2 } # Too large for 1 bit
    assert_raises(ArgumentError) { struct[:value] = 256 } # Too large for 8 bits
    assert_raises(ArgumentError) { struct[:value] = -257 } # Too small for 8 bits

    # Test that regular field still works
    struct[:regular_field] = -12_345
    assert_equal(-12_345, struct[:regular_field])
  end
end
