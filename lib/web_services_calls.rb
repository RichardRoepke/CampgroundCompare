def get_catalogue_location(uuid)
  return get_web_data(uuid, 'CATALOGUE')
end

def get_rvparky_location(slug)
  return get_web_data(slug, 'RVPARKY')
end

def get_changed_since(date, method, ignore)
  if method == 'CATALOGUE'
    return { catalogue: get_catalogue_since(date, ignore) }
  elsif method == 'RVPARKY'
    return { rvparky: get_rvparky_since(date) }
  else
    return { catalogue: get_catalogue_since(date, ignore),
             rvparky: get_rvparky_since(date) }
  end
end

def update_catalogue_location(uuid, changes)
  return generic_put_catalogue(uuid + '?' + changes).response_code
end

private
def get_catalogue_since(date, ignore_wait = false, page = 1, per_page = 100)
  result = []

  request = generic_get_catalogue('changedSince=' + date + '&page=' + page.to_s + '&per_page=' + per_page.to_s)

  if request.response_code == 200
    temp_response = JSON.parse(request.response_body)
    response = hash_string_to_sym(temp_response)

    if response[:records] > 0
      if response[:totalPages] < 5 || ignore_wait.present?
        response[:data].each do |value|
          info = value
          info[:slug] = 'NULL' if info[:slug].blank?
          result.push(info)
        end

        if response[:totalPages] > page
          next_page_array = get_changed_since(date, ignore_wait, (page + 1))
          # If next_page_array is a string then an error must have occured so
          # don't append it to the current array.
          result = result + next_page_array unless next_page_array.is_a?(String)
        end
      else
        result = 'Operation aborted due to the excessive time required. If you wish to proceed regardless, please select the checkbox when resubmitting the form.'
      end
    end
  else
    result = 'Response failed. Code: ' + request.response_code.to_s
  end

  return result
end

def get_rvparky_since(date)
  #request = Typhoeus::Request.get('https://www.rvparky.com/_ws/LocationIndexUpdates?last_updated=2018-09-01T23:27:35.820010')
  #temp = JSON.parse(request.response_body)
  #foobar = process_updates(temp["updates"])
  return 'Response failed. Code: 0'
end

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

# For checking changes since X date.
def generic_get_rvparky_1(url)
  return Typhoeus::Request.get('https://www.rvparky.com/_ws/' + url, :ssl_verifyhost => 0)
end

# For checking locations.
def generic_get_rvparky_2(url)
  return Typhoeus::Request.get('https://www.rvparky.com/_ws2/' + url, :ssl_verifyhost => 0)
end

def generic_put_rvparky(url)
  return Typhoeus::Request.put('https://www.rvparky.com/_ws/' + url, :ssl_verifyhost => 0)
end

def get_web_data(key, type)
  if type == 'CATALOGUE'
    request = generic_get_catalogue(key)
  elsif type == 'RVPARKY'
    request = generic_get_rvparky_2('Location/' + key)
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
