class MarkedPark < ApplicationRecord
  validates :uuid, uniqueness: true

  after_find do |park|
    update_status() #if self.updated_at < Date.yesterday
  end

  def calculate_differences
    return []
  end

  def update_status(catalogue_input=nil, rvparky_input=nil)
    inputs = true

    if catalogue_input.blank?
      puts 'CHECKING FOR CATALOGUE'
      catalogue_input = get_catalogue_data(self.uuid)
    end

    catalogue = CatalogueLocationValidator.new(catalogue_input) if catalogue_input.present?

    if rvparky_input.blank?
      puts 'Checking RVParky.'
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
    return get_web_data('http://centralcatalogue.com:3200/api/v1/locations/' + rv_uuid.to_s,
                        true)
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
    return 'BOTH ARE FINE' if catalogue.valid? && rvparky.valid?
    return 'CATALOGUE IS FINE' if catalogue.valid?
    return 'RVPARKY IS FINE' if rvparky.valid?
    return 'NOTHING IS FINE'
  end
end
