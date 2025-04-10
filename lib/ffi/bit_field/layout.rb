# frozen_string_literal: true

module FFI
  module BitField
    # Layout provides methods for defining bit field layouts.
    # This module is extended by BitStruct and ManagedBitStruct classes.
    module Layout
      # Returns a hash of bit fields grouped by parent field.
      #
      # @return [Hash] A hash where keys are parent field names and values are arrays of bit field names
      #
      # @example Get bit field members in a struct
      #   class Flags < FFI::BitStruct
      #     layout \
      #       :value, :uint8
      #
      #     bit_fields :value,
      #       :read,    1,
      #       :write,   1,
      #       :execute, 1,
      #       :unused,  5
      #   end
      #
      #   Flags.bit_field_members  # => {:value => [:read, :write, :execute, :unused]}
      def bit_field_members
        return {} unless instance_variable_defined?(:@bit_field_hash_table)

        result = {}
        @bit_field_hash_table.each do |field_name, info|
          parent_name = info[0]
          result[parent_name] ||= []
          result[parent_name] << field_name
        end
        result
      end

      # Returns a hash of bit fields with detailed layout information.
      #
      # @return [Hash] A hash where keys are parent field names and values are hashes of bit field details
      #
      # @example Get detailed bit field layout in a struct
      #   class Flags < FFI::BitStruct
      #     layout \
      #       :value, :uint8
      #
      #     bit_fields :value,
      #       :read,    1,
      #       :write,   1,
      #       :execute, 1,
      #       :unused,  5
      #   end
      #
      #   Flags.bit_field_layout
      #   # => {
      #   #      :value => {
      #   #        :read    => { :start => 0, :width => 1 },
      #   #        :write   => { :start => 1, :width => 1 },
      #   #        :execute => { :start => 2, :width => 1 },
      #   #        :unused  => { :start => 3, :width => 5 }
      #   #      }
      #   #    }
      def bit_field_layout
        return {} unless instance_variable_defined?(:@bit_field_hash_table)

        result = {}
        @bit_field_hash_table.each do |field_name, info|
          parent_name, start, width = info
          result[parent_name] ||= {}
          result[parent_name][field_name] = { start: start, width: width }
        end
        result
      end

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
