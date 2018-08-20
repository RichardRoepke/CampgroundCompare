class ComparerController < ApplicationController
  def index
  end

  def entry
  end

  def temp
    request = Typhoeus::Request.get('https://centralcatalogue.com/api/v1/locations/19844',
                                    headers: {'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2'},
                                    :ssl_verifyhost => 0) #Server is set as verified but without proper certification.

    temp = JSON.parse(request.response_body)
    temper = hash_string_to_sym(temp)
    tempest = LocationValidator.new(temper)
    @response = tempest.inspect
    puts tempest.valid?
  end

  private

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
