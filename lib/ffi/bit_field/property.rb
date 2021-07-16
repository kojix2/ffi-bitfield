# frozen_string_literal: true

module FFI
  module BitField
    # Properties provides methods to read and write bit fields.
    module Property
      # @param [Symbol] member_name
      # @return [Integer] value
      def [](member_name)
        bit_fields = self.class.instance_variable_get(:@bit_field_hash_table)
        parent_name, start, width = bit_fields[member_name]
        if parent_name
          value = get_member_value(parent_name)
          (value >> start) & ((1 << width) - 1)
        else
          get_member_value(member_name)
        end
      end
    end
  end
end
