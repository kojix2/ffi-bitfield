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

  def test_bit_field_members
    expected = {
      a: %i[a0 a1 a2 a3 a4 a5 a6 a7],
      b: %i[b0 b1 b2 b3]
    }
    assert_equal expected, Struct2.bit_field_members
  end

  def test_bit_field_layout
    expected = {
      a: {
        a0: { start: 0, width: 1 },
        a1: { start: 1, width: 1 },
        a2: { start: 2, width: 1 },
        a3: { start: 3, width: 1 },
        a4: { start: 4, width: 1 },
        a5: { start: 5, width: 1 },
        a6: { start: 6, width: 1 },
        a7: { start: 7, width: 1 }
      },
      b: {
        b0: { start: 0, width: 1 },
        b1: { start: 1, width: 1 },
        b2: { start: 2, width: 2 },
        b3: { start: 4, width: 4 }
      }
    }
    assert_equal expected, Struct2.bit_field_layout
  end

  256.times do |i|
    define_method("test_a#{i}_get") do
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

  8.times do |i|
    define_method("test_a#{i}_write") do
      256.times do |j|
        memory_pointer = FFI::MemoryPointer.new(:uint8, 2)
        ptr = FFI::Pointer.new(memory_pointer)
        s = Struct2.new(ptr)
        s[:a] = j
        v = s["a#{i}".to_sym]
        s["a#{i}".to_sym] = 1
        assert_equal 1, s["a#{i}".to_sym]
        s["a#{i}".to_sym] = 0
        assert_equal 0, s["a#{i}".to_sym]
        s["a#{i}".to_sym] = v
        assert_equal j, s[:a]
        assert_raises(ArgumentError) do
          s["a#{i}".to_sym] = 2
        end
      end
    end
  end

  256.times do |i|
    define_method("test_b#{i}_get") do
      memory_pointer = FFI::MemoryPointer.new(:uint8, 2)
      ptr = FFI::Pointer.new(memory_pointer)
      s = Struct2.new(ptr)
      s[:b] = i
      val = s[:b0] +
            s[:b1] * 2 +
            s[:b2].to_s(2).reverse.each_char.map.with_index { |v, j| v.to_i * (2**(j + 2)) }.inject(:+) +
            s[:b3].to_s(2).reverse.each_char.map.with_index { |v, j| v.to_i * (2**(j + 4)) }.inject(:+)
      assert_equal i, s[:b]
      assert_equal i, val
    end
  end

  define_method('test_b3_write') do
    256.times do |j|
      memory_pointer = FFI::MemoryPointer.new(:uint8, 2)
      ptr = FFI::Pointer.new(memory_pointer)
      s = Struct2.new(ptr)
      s[:b] = j
      v = s[:b3]
      16.times do |k|
        s[:b3] = k
        assert_equal k, s[:b3]
        if k == v
          assert j == s[:b]
        else
          assert j != s[:b]
        end
        s[:b3] = -(k + 1)
        assert_equal (15 - k), s[:b3]
        assert_raises do
          s[:b3] = 16
        end
        assert_raises do
          s[:b3] = -17
        end
      end
    end
  end
end
