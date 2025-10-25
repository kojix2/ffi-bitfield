module FFI
  module BitField
    # InstanceMethods provides methods for reading and writing bit field values.
    # This module is included in BitStruct and ManagedBitStruct classes.
    module InstanceMethods
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
          (value >> start) & max_value_for_width(width)
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
        # Get bit field information
        field_info = member_value_info(member_name)

        # If not a bit field, delegate to regular field setter
        return set_member_value(member_name, value) unless field_info

        # Ensure value is an Integer (only for bit fields)
        raise TypeError, "Value must be an Integer, got #{value.class}" unless value.is_a?(Integer)

        # Extract bit field information
        parent_name, start, width = field_info

        # Calculate max value for this bit width
        max_value = max_value_for_width(width)

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
        mask = create_bitmask(width, start)
        new_value = (parent_value & ~mask) | ((value & max_value_for_width(width)) << start)

        set_member_value(parent_name, new_value)
      end

      private

      # Calculates the maximum value that can be stored in the given bit width.
      # For example: 3 bits can store 0b000 to 0b111, so max is 7
      #
      # @param [Integer] width The number of bits
      # @return [Integer] The maximum value
      # @example
      #   max_value_for_width(3)  # => 7 (0b111)
      #   max_value_for_width(4)  # => 15 (0b1111)
      def max_value_for_width(width)
        (1 << width) - 1
      end

      # Creates a bitmask for extracting or setting bits at a specific position.
      # For example: width=3, start=2 creates 0b11100 (mask for bits 2,3,4)
      #
      # @param [Integer] width The number of bits in the mask
      # @param [Integer] start The starting bit position (0-indexed from right)
      # @return [Integer] The bitmask
      # @example
      #   create_bitmask(3, 2)  # => 28 (0b11100)
      #   create_bitmask(2, 0)  # => 3 (0b11)
      def create_bitmask(width, start)
        max_value_for_width(width) << start
      end

      # Gets information about a bit field member.
      #
      # @param [Symbol] member_name The name of the bit field
      # @return [Array, nil] An array containing [parent_name, start_bit, width] or nil if not a bit field
      def member_value_info(member_name)
        hash_table = self.class.instance_variable_get(:@bit_field_hash_table)
        hash_table&.[](member_name)
      end
    end
  end
end
