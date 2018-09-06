def get_catalogue_location(uuid)
  return get_web_data(uuid, 'CATALOGUE')
end

def get_rvparky_location(slug)
  return get_web_data(slug, 'RVPARKY')
end

private
def generic_get_catalogue(url)
  final_url = 'http://centralcatalogue.com:3200/api/v1/locations?' + url if url.include?('changedSince')
  final_url = 'http://centralcatalogue.com:3200/api/v1/locations/' + url unless url.include?('changedSince')
  return Typhoeus::Request.get(final_url,
                               headers: { 'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2' },
                               :ssl_verifyhost => 0)
end

def generic_put_catalogue(url)
  return Typhoeus::Request.put('http://centralcatalogue.com:3200/api/v1/locations/' + url,
                               headers: { 'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2' },
                               :ssl_verifyhost => 0)
end

def generic_get_rvparky(url)
  return Typhoeus::Request.get('https://www.rvparky.com/_ws/' + url, :ssl_verifyhost => 0)
end

def generic_put_rvparky(url)
  return Typhoeus::Request.put('https://www.rvparky.com/_ws/' + url, :ssl_verifyhost => 0)
end

def get_web_data(key, type)
  if type == 'CATALOGUE'
    request = generic_get_catalogue(key)
  elsif type == 'RVPARKY'
    request = generic_get_rvparky('Location/' + key)
  else
    return 0
  end

  if request.response_code == 200
    temp_response = JSON.parse(request.response_body)
    output = hash_string_to_sym(temp_response)

    output = output[:location] if output[:location].present?
  else
    output = request.response_code
  end

  return output
end

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
