require 'json'
require 'base64'
require 'openssl'
require 'digest/sha2'

def decrypt(encrypted)
  bytes = Base64::decode64(encrypted)
  cipher = OpenSSL::Cipher.new('AES-256-CTR')
  cipher.decrypt
  cipher.key = Digest::SHA256.digest 'tThisFarThenTher'
  cipher.iv = bytes.slice!(0,16)
  return cipher.update(bytes) + cipher.final
end

def is_lower?(c)
  c >= 'a' && c <= 'z'
end

def decode_prop(prop_code)
  case prop_code
  when 'a'
    return "closed"
  when 'b'
    return "cat"
  when 'c'
    return "amenitiesCode"
  when 'd'
    return "lat"
  when 'e'
    return "lon"
  when 'f'
    return "rating"
  when 'g'
    return "review_count"
  when 'h'
    return "dailyRate"
  when 'i'
    return "address"
  when 'j'
    return "city"
  when 'k'
    return "region"
  when 'l'
    return "phone_number"
  when 'm'
    return "name"
  when 'n'
    return "reservation_url"
  else
    raise 'invalid property code: %s' % prop_code
  end
end

def update_index(location_id, prop, value)
  puts 'UPDATE: %s %s %s' % [location_id, prop, value]
end

def process_updates(updates_encoded)
  result = []
  decrpyted = decrypt(updates_encoded)
  updates = decrpyted.split('|')
  location_id = 0
  updates.each do |update|
    # if the string starts with a lower case character, then it is a property update
    # if it starts with an upper case character, it is a base36 encoded location id
    if is_lower? update[0] then
      if (location_id == 0) then
          raise "invalid locationid"
      end
      prop_code = update.slice!(0,1)
      prop = decode_prop(prop_code)
      #update_index(location_id, prop, update)
      result.push(location_id)
    else
      location_id = update.to_i(36)
    end
  end

  return result.uniq
end