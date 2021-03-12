# frozen_string_literal: true

require 'test_helper'

class BitstructTest < Minitest::Test
  class Struct1 < FFI::BitStruct
    layout \
      :a, :uint8,
      :b, :uint8

    bitfields :a,
              :a0, 1,
              :a1, 1,
              :a2, 1,
              :a3, 1,
              :a4, 1,
              :a5, 1,
              :a6, 1,
              :a7, 1
  end

  256.times do |i|
    define_method("test_#{i}") do
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
      assert_equal i, v
    end
  end
end
