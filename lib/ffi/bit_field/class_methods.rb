module FFI
  module BitField
    # ClassMethods provides methods for defining bit field layouts.
    # This module is extended by BitStruct and ManagedBitStruct classes.
    module ClassMethods
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

      # Returns a hash of bit fields with their bit offsets, grouped by parent field.
      #
      # @return [Hash] A hash where keys are parent field names and values are arrays of [bit_field_name, bit_offset] pairs
      #
      # @example Get bit field offsets in a struct
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
      #   Flags.bit_field_offsets
      #   # => {
      #   #      :value => [[:read, 0], [:write, 1], [:execute, 2], [:unused, 3]]
      #   #    }
      def bit_field_offsets
        return {} unless instance_variable_defined?(:@bit_field_hash_table)

        result = {}

        # Get byte offsets of parent fields
        field_offsets = offsets.to_h

        # Process each bit field
        @bit_field_hash_table.each do |field_name, info|
          parent_name, start, _width = info

          # Get byte offset of parent field
          parent_offset = field_offsets[parent_name]
          next unless parent_offset

          # Convert byte offset to bit offset and add bit field's start position
          bit_offset = parent_offset * 8 + start

          # Add to result
          result[parent_name] ||= []
          result[parent_name] << [field_name, bit_offset]
        end

        # Return result
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

        # Prevent redefining bit fields on the same parent field
        if @bit_field_hash_table.any? { |_n, info| info[0] == parent_name }
          raise ArgumentError, "bit_fields for :#{parent_name} already defined"
        end

        # Validate total width against parent size
        validate_total_width(parent_name, widths)
        starts = widths.each_with_index.map { |_width, index| widths[0...index].sum }
        member_names.zip(starts, widths).each do |name, start, width|
          @bit_field_hash_table[name] = [parent_name, start, width]
        end

        parent_name
      end
      alias bit_field bit_fields

      # Defines typed bit fields within a parent field using hash syntax.
      #
      # @param [Symbol] parent_name The name of the parent field
      # @param [Hash] field_definitions A hash where keys are field names and values are arrays [width, type]
      # @return [Symbol] parent_name The name of the parent field
      #
      # @example Define typed bit fields with automatic boolean helpers
      #   bit_fields_typed :flags,
      #     revoked: [1, :bool],      # Creates revoked and revoked? methods
      #     expired: [1, :bool],      # Creates expired and expired? methods
      #     some_string: [4, :string] # Creates some_string method
      #
      # @note For fields with width 1 and type :bool, a "?" helper method is automatically created
      # @note The total bit width should not exceed the size of the parent field.
      def bit_fields_typed(parent_name, field_definitions)
        @bit_field_hash_table = {} unless instance_variable_defined?(:@bit_field_hash_table)
        @bit_field_type_table = {} unless instance_variable_defined?(:@bit_field_type_table)

        parent_name = parent_name.to_sym
        member_names = []
        widths = []
        types = []

        field_definitions.each do |name, definition|
          width, type = definition
          member_names << name.to_sym
          widths << width.to_i
          types << type.to_sym
        end

        # Prevent redefining bit fields on the same parent field
        if @bit_field_hash_table.any? { |_n, info| info[0] == parent_name }
          raise ArgumentError, "bit_fields for :#{parent_name} already defined"
        end

        # Validate total width against parent size
        validate_total_width(parent_name, widths)

        starts = widths.each_with_index.map { |_width, index| widths[0...index].sum }

        member_names.zip(starts, widths, types).each do |name, start, width, type|
          @bit_field_hash_table[name] = [parent_name, start, width]
          @bit_field_type_table[name] = type

          # Generate "?" method for boolean fields with width 1
          next unless width == 1 && type == :bool

          define_method(:"#{name}?") do
            self[name] == 1
          end
        end

        parent_name
      end
      private

      # Return parent field size in bits (nil if unknown)
      def parent_size_bits(parent_name)
        field = layout[parent_name] # nil if not found
        return nil unless field&.respond_to?(:type)
        field.type.size * 8
      end

      # Raise if total width exceeds parent size
      def validate_total_width(parent_name, widths)
        size = parent_size_bits(parent_name)
        return unless size
        total = widths.sum
        raise ArgumentError, "Bit width #{total} exceeds :#{parent_name} size (#{size} bits)" if total > size
      end
    end
  end
end
