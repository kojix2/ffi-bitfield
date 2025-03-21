# frozen_string_literal: true

module FFI
  module BitField
    # Layout provides methods for defining bit field layouts.
    # This module is extended by BitStruct and ManagedBitStruct classes.
    module Layout
      # Defines bit fields within a parent field.
      #
      # @param [Array] layout_args An array where the first element is the parent field name,
      #   followed by alternating field name and bit width pairs
      # @return [Symbol] parent_name The name of the parent field
      #
      # @example Define bit fields in an 8-bit integer
      #   bit_fields :flags,
      #     :read,    1,  # 1 bit for read permission
      #     :write,   1,  # 1 bit for write permission
      #     :execute, 1,  # 1 bit for execute permission
      #     :unused,  5   # 5 unused bits
      #
      # @note The total bit width should not exceed the size of the parent field.
      #   For example, a :uint8 field can hold at most 8 bits.
      def bit_fields(*layout_args)
        # The reason for using class instance variable here instead of class variable
        # is not because class instance variables are clean,
        # but because sub-class of FFI::Struct cannot be inherited again.
        @bit_field_hash_table = {} unless instance_variable_defined?(:@bit_field_hash_table)

        parent_name = layout_args.shift.to_sym
        member_names = []
        widths = []
        layout_args.each_slice(2) do |name, width|
          member_names << name.to_sym
          widths << width.to_i
        end
        starts = widths.inject([0]) do |result, width|
          result << (result.last + width)
        end
        member_names.zip(starts, widths).each do |name, start, width|
          @bit_field_hash_table[name] = [parent_name, start, width]
        end

        parent_name
      end
      alias bit_field bit_fields
    end
  end
end
