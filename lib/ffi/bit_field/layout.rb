# frozen_string_literal: true

module FFI
  module BitField
    module Layout
      def bit_fields(*args)
        # The reason for using class instance variable here instead of
        # class variable is that sub-class of FFI::Struct cannot be inherited again,
        # not because class instance variables are clean.
        @bit_field_hash_table = {} unless instance_variable_defined?(:@bit_field_hash_table)

        parent_name = args.shift
        member_names = []
        widths = []
        args.each_slice(2) do |name, width|
          member_names << name
          widths << width
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
