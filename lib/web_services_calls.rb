require 'json'

def get_catalogue_location(uuid)
  return get_web_data(uuid, 'CATALOGUE') unless uuid.blank?
  return 404 # We already know what the result of an invalid UUID would be, so no point checking.
end

def get_rvparky_location(slug, follow=false)
  if slug.is_a?(Integer)
    return get_web_data(slug.to_s, 'RVPARKY_ID', follow)
  else
    return get_web_data(slug, 'RVPARKY_SLUG', follow)
  end
end

def get_changed_since(date, method)
  if method == 'CATALOGUE'
    return { catalogue: get_catalogue_since(date) }
  elsif method == 'RVPARKY'
    return { rvparky: get_rvparky_since(date) }
  else
    return { catalogue: get_catalogue_since(date),
             rvparky: get_rvparky_since(date) }
  end
end

def update_catalogue_location(uuid, changes)
  return generic_put_catalogue(uuid + '?' + changes).response_code
end

def update_rvparky_location(input_hash, park_id)
  body_hash = { location_id: park_id,
                source: 'BookYourSite',
                email: 'rvparkyupdates@bookyoursite.com',
                notify: '',
                updates: ActiveSupport::JSON.encode(input_hash) } # Updates needs to be a JSON string.

  body_hash[:notes] = 'This is a test.' if Rails.env.development?

  return Typhoeus::Request.post(rvparky_url(2) + 'UpdateLocation',
                                body: body_hash.to_json,
                                cookiefile: Rails.root.join('lib', 'assets', 'rvparky_cookies.txt'),
                                :ssl_verifyhost => 0).response_code
end

private
def catalogue_url
  return 'https://centralcatalogue.com/api/v1/locations'
end

def rvparky_url(type=nil)
  return 'https://www.rvparky.com/_ws' + type.to_s + '/' if type.present?
  return 'https://www.rvparky.com/_ws/'
end

def get_catalogue_since(date, page = 1, per_page = 100)
  result = []

  request = generic_get_catalogue('changedSince=' + date + '&page=' + page.to_s + '&per_page=' + per_page.to_s)

  if request.response_code == 200
    temp_response = JSON.parse(request.response_body)
    response = hash_string_to_sym(temp_response)

    if response[:records] > 0
      response[:data].each do |value|
        info = { uuid: value[:uuid],
                 slug: value[:slug],
                 rvparky_id: nil }
        result.push(info)
      end

      if response[:totalPages] > page
        next_page_array = get_catalogue_since(date, (page + 1))
        # If next_page_array is a string then an error must have occured so
        # don't append it to the current array.
        result = result + next_page_array unless next_page_array.is_a?(String)
      end
    end
  else
    result = 'Response failed. Code: ' + request.response_code.to_s
  end

  return result
end


################################################################################
# The call to get a list of changes from RVParky is somewhat complicated.
#
# The service returns a block of 50 individual changes, which might include
# duplicate parks and a 'date'/timestamp of the last change, so to find the
# total list of changes since the requested date, each 'date' has to be
# followed in turn. Only once the end of the chain is reached can we then
# evaluate how many changed parks actually exist.
################################################################################
def get_rvparky_since(date)
  result = []

  request = generic_get_rvparky_1('LocationIndexUpdates?last_updated=' + date.to_s + 'T00:00:00.000000')

  if request.response_code == 200
    response = JSON.parse(request.response_body)
    if response["updates"].present?
      further_ids = get_rvparky_since_recursion(response["date"])

      id_array = process_updates(response["updates"]) + further_ids

      id_array.each do |id|
        info = { uuid: nil,
                 slug: nil,
                 rvparky_id: id.to_i }
        result.push(info)
      end
    else
      result = 'No valid parks found.'
    end
  else
    result = 'Response failed. Code: ' + request.response_code.to_s
  end

  return result
end

def get_rvparky_since_recursion(date, level=0)
  result = []

  request = generic_get_rvparky_1('LocationIndexUpdates?last_updated=' + date.to_s)

  if request.response_code == 200
    response = JSON.parse(request.response_body)

    if response["updates"].present?
      next_level = get_rvparky_since_recursion(response["date"], level + 1)
      result = process_updates(response["updates"]) + next_level
    end
  end

  return result
end

def generic_get_catalogue(url)
  final_url = catalogue_url + '?' + url if url.include?('changedSince')
  final_url = catalogue_url + '/' + url unless url.include?('changedSince')
  return Typhoeus::Request.get(final_url,
                               headers: { 'x-api-key' => '3b8fbfa8-7513-41e3-a771-f404e635fd5e' }, #TODO: Store this in a more secure fashion.
                               :ssl_verifyhost => 0)
end

def generic_put_catalogue(url)
  return Typhoeus::Request.put(catalogue_url + '/' + url,
                               headers: { 'x-api-key' => '3b8fbfa8-7513-41e3-a771-f404e635fd5e' }, #TODO: Store this in a more secure fashion.
                               :ssl_verifyhost => 0)
end

# For checking changes since X date and getting park information.
def generic_get_rvparky_1(url)
  return Typhoeus::Request.get(rvparky_url + url, :ssl_verifyhost => 0)
end

# For updating parks and getting info from slugs.
def generic_get_rvparky_2(url, follow=false)
  return Typhoeus::Request.get(rvparky_url(2) + url, :ssl_verifyhost => 0, followlocation: follow)
end

def generic_put_rvparky(url)
  return Typhoeus::Request.put(rvparky_url + url, :ssl_verifyhost => 0)
end

def get_web_data(key, type, follow=false)
  if type == 'CATALOGUE'
    request = generic_get_catalogue(key)
  elsif type == 'RVPARKY_ID'
    request = generic_get_rvparky('GetLocationDetail?key_id=' + key, follow)
  elsif type == 'RVPARKY_SLUG'
    request = generic_get_rvparky_2('Location/' + key, follow)
  else
    return 404
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
