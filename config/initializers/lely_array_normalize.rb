module Lelylan
  module Array
    module Normalize

      def stringify_values
        values = read_attribute(:values)
        values.map! {|v| v.to_s} if values
        values ||= []
        write_attribute(:values, values)
      end

    end
  end
end
