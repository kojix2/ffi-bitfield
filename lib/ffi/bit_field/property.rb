# frozen_string_literal: true

module FFI
  module BitField
    # Properties provides methods to read and write bit fields.
    module Property
      # @param [Symbol] member_name
      # @return [Integer] value
      def [](member_name)
        parent_name, start, width = member_value_info(member_name)
        if parent_name
          value = get_member_value(parent_name)
          value[start, width]
        else
          get_member_value(member_name)
        end
      end

      def []=(member_name, value)
        parent_name, start, width = member_value_info(member_name)
        if parent_name
          raise "Value #{value} is larger than #{(1 << width) - 1}" if value.bit_length > width

          parent_value = get_member_value(parent_name)
          all = ((1 << parent_value.bit_length) - 1)
          mask = all ^ (((1 << width) - 1) << start)
          masked_value = parent_value & mask
          new_value = masked_value | (value << start)
          set_member_value(parent_name, new_value)
        else
          set_member_value(member_name, value)
        end
      end

      private

      def member_value_info(member_name)
        self.class.instance_variable_get(:@bit_field_hash_table)[member_name]
      end
    end
  end
end
