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
      request = Typhoeus::Request.get('http://centralcatalogue.com:3200/api/v1/locations/' + self.uuid.to_s,
                                      headers: { 'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2' },
                                      :ssl_verifyhost => 0) #Server is set as verified but without proper certification.
      if request.response_code == 200
        temp_response = JSON.parse(request.response_body)

        catalogue_input = hash_string_to_sym(temp_response)
      else
        self.status = 'Improper UUID' if request.response_code > 300 && request.response_code < 400
        puts 'Catalogue failed. ' + request.response_code.to_s
        inputs = false
      end
    end

    catalogue = CatalogueLocationValidator.new(catalogue_input) if inputs.present?

    if rvparky_input.blank?
      puts 'Checking RVParky.'
      request = Typhoeus::Request.get('https://www.rvparky.com/_ws2/Location/' + self.slug.to_s.strip,
                                      :ssl_verifyhost => 0) #Server is set as verified but without proper certification.
      if request.response_code == 200
        temp_response = JSON.parse(request.response_body)

        rvparky_input = hash_string_to_sym(temp_response)
      else
        self.status = 'Improper slug' if request.response_code > 300 && request.response_code < 400
        puts 'RVParky failed. ' + request.response_code.to_s
        inputs = false
      end
    end

    rvparky = RvparkyLocationValidator.new(rvparky_input[:location]) if inputs.present?

    if inputs.present?
      self.status = calculate_status(catalogue, rvparky)
    else
      self.status = 'No Connection' unless self.status.present?
    end
  end

  def calculate_status(catalogue, rvparky)
    return 'BOTH ARE FINE' if catalogue.valid? && rvparky.valid?
    return 'CATALOGUE IS FINE' if catalogue.valid?
    return 'RVPARKY IS FINE' if rvparky.valid?
    return 'NOTHING IS FINE'
  end
end
