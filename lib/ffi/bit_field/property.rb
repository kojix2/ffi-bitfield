# frozen_string_literal: true

module FFI
  module BitField
    # Property provides methods for reading and writing bit field values.
    # This module is included in BitStruct and ManagedBitStruct classes.
    module Property
      # Returns a hash of bit fields grouped by parent field.
      # Instance method version of the class method with the same name.
      #
      # @return [Hash] A hash where keys are parent field names and values are arrays of bit field names
      #
      # @example Get bit field members in a struct instance
      #   flags = Flags.new
      #   flags.bit_field_members  # => {:value => [:read, :write, :execute, :unused]}
      def bit_field_members
        self.class.bit_field_members
      end

      # Returns a hash of bit fields with their bit offsets, grouped by parent field.
      #
      # @return [Hash] A hash where keys are parent field names and values are arrays of [bit_field_name, bit_offset] pairs
      #
      # @example Get bit field offsets in a struct instance
      #   flags = Flags.new
      #   flags.bit_field_offsets
      #   # => {
      #   #      :value => [[:read, 0], [:write, 1], [:execute, 2], [:unused, 3]]
      #   #    }
      def bit_field_offsets
        self.class.bit_field_offsets
      end

      # Reads a value from a bit field or regular field.
      #
      # @param [Symbol] member_name The name of the field to read
      # @return [Integer] The value of the field
      #
      # @example Reading a bit field
      #   struct[:flag1]  # => 1
      def [](member_name)
        parent_name, start, width = member_value_info(member_name)
        if parent_name
          value = get_member_value(parent_name)
          (value >> start) & ((1 << width) - 1)
        else
          get_member_value(member_name)
        end
      end

      # Writes a value to a bit field or regular field.
      #
      # @param [Symbol] member_name The name of the field to write
      # @param [Integer] value The value to write
      # @return [Integer] The written value
      # @raise [ArgumentError] If the value is too large for the bit field
      # @raise [ArgumentError] If the value is too small (negative) for the bit field
      # @raise [ArgumentError] If the member name is not a valid bit field
      # @raise [TypeError] If the value is not an Integer
      #
      # @example Writing to a bit field
      #   struct[:flag1] = 1
      # @example Writing a negative value (bit-flipped)
      #   struct[:field] = -1  # Sets all bits to 1
      def []=(member_name, value)
        # Ensure value is an Integer
        raise TypeError, "Value must be an Integer, got #{value.class}" unless value.is_a?(Integer)

        # Get bit field information
        field_info = member_value_info(member_name)

        # If not a bit field, delegate to regular field setter
        return set_member_value(member_name, value) unless field_info

        # Extract bit field information
        parent_name, start, width = field_info

        # Calculate max value for this bit width
        max_value = (1 << width) - 1

        # Handle negative values by bit-flipping
        if value.negative?
          # For negative values, we interpret them as bit-flipped positive values
          # For example, with 4 bits, -1 becomes 1111 (15), -2 becomes 1110 (14), etc.

          # Check if the negative value is within range
          # For bit-flipping, valid range is -(2^n) to -1
          min_value = -(1 << width)
          if value < min_value
            raise ArgumentError, "Value #{value} is too small for bit_length: #{width}, minimum is #{min_value}"
          end

          # Convert negative value to bit-flipped positive value
          # -1 -> 15, -2 -> 14, etc.
          value = max_value + value + 1

          # Sanity check after conversion
          if value.negative? || value > max_value
            raise ArgumentError, "Internal error: converted value #{value} is out of range for bit_length: #{width}"
          end
        elsif value > max_value
          # For positive values, check if they fit in the bit width
          raise ArgumentError, "Value #{value} is too large for bit_length: #{width}, maximum is #{max_value}"
        end

        # Update the parent field with the new bit field value
        parent_value = get_member_value(parent_name)
        mask = ((1 << width) - 1) << start
        new_value = (parent_value & ~mask) | ((value & ((1 << width) - 1)) << start)

        set_member_value(parent_name, new_value)
      end

      private

      # Gets information about a bit field member.
      #
      # @param [Symbol] member_name The name of the bit field
      # @return [Array, nil] An array containing [parent_name, start_bit, width] or nil if not a bit field
      def member_value_info(member_name)
        self.class.instance_variable_get(:@bit_field_hash_table)[member_name]
      end
    end
  end
end
