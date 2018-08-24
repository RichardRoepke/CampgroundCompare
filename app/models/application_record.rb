class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Make sure to convert null to nil somehow.
  def hash_string_to_sym(input_hash)
    result_hash = {}

    input_hash.each do |sym, value|
      if value.is_a?(Hash)
        result_hash[sym.to_sym] = hash_string_to_sym(value)
      elsif value.is_a?(Array)
        result_hash[sym.to_sym] = array_string_to_sym(value)
      else
        result_hash[sym.to_sym] = value
      end
    end

    return result_hash
  end

  def array_string_to_sym(input_hash)
    result_hash = []

    input_hash.each do |value|
      if value.is_a?(Hash)
        result_hash.push hash_string_to_sym(value)
      elsif value.is_a?(Array)
        result_hash.push array_string_to_sym(value)
      else
        result_hash.push value
      end
    end

    return result_hash
  end
end