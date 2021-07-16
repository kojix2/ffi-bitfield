# frozen_string_literal: true

module BitFiledSupporter
  module BitFieldModule
    def [](name)
      bit_fields = self.class.bit_fields_hash_table
      parent, start, width = bit_fields[name]
      if parent
        (super(parent) >> start) & ((1 << width) - 1)
      else
        super(name)
      end
    end
  end
  private_constant :BitFieldModule

  attr_reader :bit_fields_hash_table

  def bit_fields(*args)
    unless instance_variable_defined?(:@bit_fields_hash_table)
      @bit_fields_hash_table = {}
      prepend BitFieldModule
    end

    parent = args.shift
    labels = []
    widths = []
    args.each_slice(2) do |l, w|
      labels << l
      widths << w
    end
    starts = widths.inject([0]) do |result, w|
      result << (result.last + w)
    end
    labels.zip(starts, widths).each do |l, s, w|
      @bit_fields_hash_table[l] = [parent, s, w]
    end
  end
  alias bit_field bit_fields
end
