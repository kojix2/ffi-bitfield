# frozen_string_literal: true

require 'test_helper'
require 'ffi/bit_struct'
require 'ffi/managed_bit_struct'

class EdgeCasesTest < Minitest::Test
  # Test with different bit widths
  def test_different_bit_widths
    cls = Class.new(FFI::BitStruct) do
      layout \
        :value, :uint32

      bit_fields :value,
        :a, 3,   # 3 bits
        :b, 5,   # 5 bits
        :c, 8,   # 8 bits
        :d, 16   # 16 bits
    end

    s = cls.new
    
    # Test setting and getting values
    s[:a] = 7    # Max value for 3 bits (2^3 - 1)
    s[:b] = 31   # Max value for 5 bits (2^5 - 1)
    s[:c] = 255  # Max value for 8 bits (2^8 - 1)
    s[:d] = 65535 # Max value for 16 bits (2^16 - 1)
    
    assert_equal 7, s[:a]
    assert_equal 31, s[:b]
    assert_equal 255, s[:c]
    assert_equal 65535, s[:d]
    
    # Test error on overflow
    assert_raises(ArgumentError) { s[:a] = 8 }
    assert_raises(ArgumentError) { s[:b] = 32 }
    assert_raises(ArgumentError) { s[:c] = 256 }
    assert_raises(ArgumentError) { s[:d] = 65536 }
  end
  
  # Test with 32-bit and 64-bit fields
  def test_large_fields
    cls = Class.new(FFI::BitStruct) do
      layout \
        :small, :uint32,
        :large, :uint64
        
      bit_fields :small,
        :s1, 16,
        :s2, 16
        
      bit_fields :large,
        :l1, 32,
        :l2, 32
    end
    
    s = cls.new
    
    # Test 32-bit field
    s[:s1] = 65535
    s[:s2] = 65535
    assert_equal 65535, s[:s1]
    assert_equal 65535, s[:s2]
    assert_equal 0xFFFFFFFF, s[:small]
    
    # Test 64-bit field
    s[:l1] = 0xFFFFFFFF
    s[:l2] = 0xFFFFFFFF
    assert_equal 0xFFFFFFFF, s[:l1]
    assert_equal 0xFFFFFFFF, s[:l2]
    assert_equal 0xFFFFFFFFFFFFFFFF, s[:large]
  end
  
  # Test with negative values (2's complement)
  def test_negative_values
    cls = Class.new(FFI::BitStruct) do
      layout \
        :value, :uint8
        
      bit_fields :value,
        :a, 4,
        :b, 4
    end
    
    s = cls.new
    
    # Setting negative values should use 2's complement
    s[:a] = -1  # In 4 bits, -1 is 1111 (15)
    assert_equal 15, s[:a]
    
    s[:b] = -8  # In 4 bits, -8 is 1000 (8)
    assert_equal 8, s[:b]
    
    # Values outside the range should raise an error
    assert_raises(ArgumentError) { s[:a] = -17 }  # Too small for 4 bits
    assert_raises(ArgumentError) { s[:b] = -17 }  # Too small for 4 bits
  end
  
  # Test example from README
  def test_readme_example
    cls = Class.new(FFI::BitStruct) do
      layout \
        :a, :uint8,
        :b, :uint8

      bit_fields :a,
        :u, 2,
        :v, 2,
        :w, 1,
        :x, 1,
        :y, 1,
        :z, 1
    end
    
    s = cls.new
    
    # Test reading
    s[:a] = 63
    assert_equal 3, s[:u]
    assert_equal 3, s[:v]
    assert_equal 1, s[:w]
    assert_equal 1, s[:x]
    assert_equal 0, s[:y]
    assert_equal 0, s[:z]
    
    # Test writing
    s = cls.new
    s[:u] = 0
    s[:v] = 0
    s[:w] = 0
    s[:x] = 0
    s[:y] = 1
    assert_equal 64, s[:a]
  end
  
  # Test with ManagedBitStruct
  def test_managed_bit_struct
    cls = Class.new(FFI::ManagedBitStruct) do
      layout \
        :value, :uint8
        
      bit_fields :value,
        :a, 4,
        :b, 4
        
      def self.release(ptr)
        # Do nothing for testing
      end
    end
    
    memory_pointer = FFI::MemoryPointer.new(:uint8, 1)
    ptr = FFI::Pointer.new(memory_pointer)
    s = cls.new(ptr)
    
    s[:a] = 15
    s[:b] = 15
    
    assert_equal 15, s[:a]
    assert_equal 15, s[:b]
    assert_equal 0xFF, s[:value]
  end
  
  # Test bit field spanning multiple bytes
  def test_cross_byte_boundary
    cls = Class.new(FFI::BitStruct) do
      layout \
        :value, :uint16
        
      bit_fields :value,
        :low, 12,
        :high, 4
    end
    
    s = cls.new
    
    s[:low] = 0xFFF   # 12 bits all set
    s[:high] = 0xF    # 4 bits all set
    
    assert_equal 0xFFF, s[:low]
    assert_equal 0xF, s[:high]
    assert_equal 0xFFFF, s[:value]
  end
end
