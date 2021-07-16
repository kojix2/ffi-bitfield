# frozen_string_literal: true

module FFI
  module BitField
    # Layout provides the `bit_fields` method for registering field members.
    module Layout
      # @param [Array] layout
      # @return [Symbol] parent_name
      def bit_fields(*args)
        # The reason for using class instance variable here instead of class variable
        # is not because class instance variables are clean,
        # but because sub-class of FFI::Struct cannot be inherited again.
        @bit_field_hash_table = {} unless instance_variable_defined?(:@bit_field_hash_table)

        parent_name = args.shift.to_sym
        member_names = []
        widths = []
        args.each_slice(2) do |name, width|
          member_names << name.to_sym
          widths << width.to_i
        end
        starts = widths.inject([0]) do |result, width|
          result << (result.last + width)
        end
        member_names.zip(starts, widths).each do |name, start, width|
          @bit_field_hash_table[name] = [parent_name, start, width]
        end
      end
      alias bit_field bit_fields
    end
  end
end
