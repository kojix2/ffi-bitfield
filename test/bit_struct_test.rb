# frozen_string_literal: true

require 'test_helper'
require 'ffi/bit_struct'

class BitStructTest < Minitest::Test
  @rv = \
    class Struct1 < FFI::BitStruct
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

      bit_fields :b,
                 :b0, 1,
                 :b1, 1,
                 :b2, 2,
                 :b3, 4
    end

  def test_returned_value
    rv = self.class.instance_variable_get(:@rv)
    assert_equal :b, rv
  end

  256.times do |i|
    define_method("test_a#{i}_get") do
      s = Struct1.new
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
        s = Struct1.new
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
      s = Struct1.new
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
      s = Struct1.new
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
        assert_raises(ArgumentError) do
          s[:b3] = 16
        end
        assert_raises(ArgumentError) do
          s[:b3] = -17
        end
      end
    end
  end
end
