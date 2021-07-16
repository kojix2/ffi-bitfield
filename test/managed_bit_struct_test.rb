# frozen_string_literal: true

require 'test_helper'
require 'ffi/managed_bit_struct'

class ManagedBitStructTest < Minitest::Test
  @rv = \
    class Struct2 < FFI::ManagedBitStruct
      layout \
        :a, :uint8,
        :b, :uint8

      bit_fields :a,
                 :a0, 1,
                 :a1, 1,
                 :a2, 1,
                 :a3, 1,
                 :a4, 1,
                 :a5, 1,
                 :a6, 1,
                 :a7, 1

      rv = bit_fields :b,
                      :b0, 1,
                      :b1, 1,
                      :b2, 2,
                      :b3, 4

      def self.release(ptr)
        # Do nothing.
        # Memory pointers will be released automatically.
      end

      rv
    end

  def test_returned_value
    rv = self.class.instance_variable_get(:@rv)
    assert_equal :b, rv
  end

  256.times do |i|
    define_method("test_a_#{i}") do
      memory_pointer = FFI::MemoryPointer.new(:uint8, 2)
      ptr = FFI::Pointer.new(memory_pointer)
      s = Struct2.new(ptr)
      s[:a] = i
      v = s[:a0] +
          s[:a1] * 2 +
          s[:a2] * 4 +
          s[:a3] * 8 +
          s[:a4] * 16 +
          s[:a5] * 32 +
          s[:a6] * 64 +
          s[:a7] * 128
      assert_equal i, s[:a]
      assert_equal i, v
    end
  end

  256.times do |i|
    define_method("test_b_#{i}") do
      memory_pointer = FFI::MemoryPointer.new(:uint8, 2)
      ptr = FFI::Pointer.new(memory_pointer)
      s = Struct2.new(ptr)
      s[:b] = i
      v = s[:b0] +
          s[:b1] * 2 +
          s[:b2].to_s(2).reverse.each_char.map.with_index { |v, i| v.to_i * (2**(i + 2)) }.inject(:+) +
          s[:b3].to_s(2).reverse.each_char.map.with_index { |v, i| v.to_i * (2**(i + 4)) }.inject(:+)
      assert_equal i, s[:b]
      assert_equal i, v
    end
  end
end
