class MarkedPark < ApplicationRecord
  validates :uuid, uniqueness: true

  after_find do |park|
    update_status() if self.updated_at < Date.yesterday
  end

  def update_status(catalogue_input=nil, rvparky_input=nil)
    inputs = true

    if catalogue_input.blank?
      catalogue_input = get_catalogue_data(self.uuid)
    end

    catalogue = CatalogueLocationValidator.new(catalogue_input) if catalogue_input.present?

    if rvparky_input.blank?
      rvparky_input = get_rvparky_data(self.slug)
    end

    rvparky = RvparkyLocationValidator.new(rvparky_input) if rvparky_input.present?

    if rvparky.present? && catalogue.present?
      self.status = calculate_status(catalogue, rvparky)
    elsif rvparky.present?
      self.status = 'UUID IS INVALID'
    elsif catalogue.present?
      self.status = 'SLUG IS INVALID'
    else
      self.status = 'NO CONNECTION' unless self.status.present?
    end
  end

  def get_catalogue_data(rv_uuid)
    return get_web_data('http://centralcatalogue.com:3200/api/v1/locations/' + rv_uuid.to_s, true)
  end

  def get_rvparky_data(rv_slug)
    temp = get_web_data('https://www.rvparky.com/_ws2/Location/' + rv_slug.to_s)
    return temp[:location] if temp.present?
    return nil
  end

  def get_web_data(url, api_key=false)
    output = nil

    if api_key.present?
      request = Typhoeus::Request.get(url,
                                      headers: { 'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2' },
                                      :ssl_verifyhost => 0) #Server is set as verified but without proper certification.
    else
      request = Typhoeus::Request.get(url, :ssl_verifyhost => 0) #Server is set as verified but without proper certification.
    end

    if request.response_code == 200
      temp_response = JSON.parse(request.response_body)
      output = hash_string_to_sym(temp_response)
    end

    return output
  end

  def calculate_status(catalogue, rvparky)
    if catalogue.valid? && rvparky.valid?
      differ = calculate_differences(catalogue, rvparky)
      return 'DELETE ME' if differ[:differences].blank?
      return 'INFORMATION MISMATCH' if differ[:mismatch] > 0
      return 'BLANK FIELDS'
    end
    return 'CATALOGUE IS FINE' if catalogue.valid?
    return 'RVPARKY IS FINE' if rvparky.valid?
    return 'NOTHING IS FINE'
  end

  def calculate_differences(catalogue, rvparky)
    fields = [['website', 'website'],
              ['former_name', 'former'],
              ['rating', 'rating'],
              ['alt_name', 'known_as'],
              ['city', 'city'],
              ['longitude', 'longitude'],
              ['latitude', 'latitude'],
              ['postal', 'postal_code'],
              ['phone', 'phone'],
              ['description', 'description'],
              ['address', 'address'],
              ['name', 'name'],
              ['review_count', 'review_count']]

    result = { catalogue_blank: 0,
               rvparky_blank: 0,
               mismatch: 0,
               differences: false }

    fields.each do |catalogue_field, rvparky_field|
      catalogue_value = catalogue.public_send(catalogue_field)
      rvparky_value = rvparky.public_send(rvparky_field)

      unless catalogue_value.to_s.downcase == rvparky_value.to_s.downcase
        # Different digits after the decimal point for Catalogue and RVParky locations
        # means that floats which are obviously meant to be idenitical are not.
        # For example, 4.83 vs 4.83333333. This statement should resolve this situation.
        unless catalogue_value.is_a?(Float) && rvparky_value.is_a?(Float) && (catalogue_value - rvparky_value).abs < 0.01
          result[:catalogue_blank] += 1 if catalogue_value.blank?
          result[:rvparky_blank] += 1 if rvparky_value.blank?
          result[:mismatch] += 1 if catalogue_value.present? && rvparky_value.present?
          #result[:differences].push({ ('C' + catalogue_field).to_sym => catalogue_value, ('R' + rvparky_field).to_sym => rvparky_value })
          result[:differences] = true
        end
      end
    end

    return result
  end
end
