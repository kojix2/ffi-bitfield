require 'test_helper'
require 'ffi/bit_struct'

class TypedBitFieldsTest < Minitest::Test
  class TypedStruct < FFI::BitStruct
    layout \
      :flags, :uint8

    bit_fields_typed :flags,
                     revoked: [1, :bool],
                     expired: [1, :bool],
                     some_string: [4, :string],
                     unused: [2, :int]
  end

  def test_boolean_field_getter
    struct = TypedStruct.new
    struct[:revoked] = 1
    assert_equal 1, struct[:revoked]
  end

  def test_boolean_field_setter
    struct = TypedStruct.new
    struct[:expired] = 0
    assert_equal 0, struct[:expired]
  end

  def test_revoked_question_method_exists
    struct = TypedStruct.new
    assert_respond_to struct, :revoked?
  end

  def test_expired_question_method_exists
    struct = TypedStruct.new
    assert_respond_to struct, :expired?
  end

  def test_revoked_question_method_returns_true
    struct = TypedStruct.new
    struct[:revoked] = 1
    assert struct.revoked?
  end

  def test_revoked_question_method_returns_false
    struct = TypedStruct.new
    struct[:revoked] = 0
    refute struct.revoked?
  end

  def test_expired_question_method_returns_true
    struct = TypedStruct.new
    struct[:expired] = 1
    assert struct.expired?
  end

  def test_expired_question_method_returns_false
    struct = TypedStruct.new
    struct[:expired] = 0
    refute struct.expired?
  end

  def test_non_boolean_field_no_question_method
    struct = TypedStruct.new
    refute_respond_to struct, :some_string?
  end

  def test_wider_non_boolean_field_no_question_method
    struct = TypedStruct.new
    refute_respond_to struct, :unused?
  end

  def test_some_string_field_getter
    struct = TypedStruct.new
    struct[:some_string] = 7
    assert_equal 7, struct[:some_string]
  end

  def test_bit_field_hash_table_populated
    expected = {
      revoked: [:flags, 0, 1],
      expired: [:flags, 1, 1],
      some_string: [:flags, 2, 4],
      unused: [:flags, 6, 2]
    }
    assert_equal expected, TypedStruct.instance_variable_get(:@bit_field_hash_table)
  end

  def test_bit_field_type_table_populated
    expected = {
      revoked: :bool,
      expired: :bool,
      some_string: :string,
      unused: :int
    }
    assert_equal expected, TypedStruct.instance_variable_get(:@bit_field_type_table)
  end

  def test_multiple_boolean_fields_independent
    struct = TypedStruct.new
    struct[:revoked] = 1
    struct[:expired] = 0

    assert struct.revoked?
    refute struct.expired?

    struct[:expired] = 1
    assert struct.expired?
    assert struct.revoked?
  end

  def test_bit_field_members
    expected = {
      flags: %i[revoked expired some_string unused]
    }
    assert_equal expected, TypedStruct.bit_field_members
  end

  def test_bit_field_layout
    expected = {
      flags: {
        revoked: { start: 0, width: 1 },
        expired: { start: 1, width: 1 },
        some_string: { start: 2, width: 4 },
        unused: { start: 6, width: 2 }
      }
    }
    assert_equal expected, TypedStruct.bit_field_layout
  end

  def test_bit_fields_typed_total_width_exceeds_parent_emits_warning
    assert_output(nil, /Total bit width.*exceeds|exceed/) do
      Class.new(FFI::BitStruct) do
        layout :value, :uint16 # 16 bits available
        bit_fields_typed :value,
                         a: [8, :int],
                         b: [8, :int],
                         c: [4, :int] # 20 bits > 16
      end
    end
  end
end
