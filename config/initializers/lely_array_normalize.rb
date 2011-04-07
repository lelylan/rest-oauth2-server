module Lelylan
  module Array
    module Normalize

      def normalize_values
        values = normalize(read_attribute(:values))
        write_attribute(:values, values)
      end

      def normalize(values)
        normalized = []
        normalized = values.map {|v| v.to_s} if values?
        return normalized
      end

    end
  end
end
