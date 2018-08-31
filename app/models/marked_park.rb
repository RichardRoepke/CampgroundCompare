class MarkedPark < ApplicationRecord
  include CommonFields
  validates :uuid, uniqueness: true

  has_many :differences

  after_find do |park|
    update_status() if self.updated_at < Date.yesterday
  end

  def next
    MarkedPark.where("id > ?", id).first
  end

  def prev
    MarkedPark.where("id < ?", id).last
  end

  def quick_edit?
    ['INFORMATION MISMATCH', 'BOTH LACK INFORMATION', 'RVPARKY LACKS INFORMATION', 'CATALOGUE LACKS INFORMATION'].include? self.status
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
      self.status = 'NO CONNECTION'
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
      return 'DELETE ME' if differ[:total] == 0
      return 'INFORMATION MISMATCH' if differ[:mismatch] > 0
      return 'BOTH LACK INFORMATION' if differ[:rvparky_blank] > 0 && differ[:catalogue_blank] > 0
      return 'RVPARKY LACKS INFORMATION' if differ[:rvparky_blank] > 0
      return 'CATALOGUE LACKS INFORMATION' if differ[:catalogue_blank] > 0
      return '???'
    end

    return 'CATALOGUE IS INVALID' if catalogue.invalid?
    return 'RVPARKY IS INVALID' if rvparky.invalid?
    return 'NOTHING IS FINE'
  end

  def calculate_differences(catalogue, rvparky)
    if self.differences.length < common_fields.length
      populate_differences(catalogue, rvparky)
    else
      revaluate_differences(catalogue, rvparky)
    end

    return tally_differences
  end

  def tally_differences
    result = { catalogue_blank: 0,
               rvparky_blank: 0,
               mismatch: 0,
               total: 0 }

    self.differences.each do |diff|
      unless diff.match?
        result[:total] += 1
        result[:catalogue_blank] += 1 if diff.catalogue_blank?
        result[:rvparky_blank] += 1 if diff.rvparky_blank?
        result[:mismatch] += 1 if diff.mismatch?
      end
    end

    return result
  end

  def revaluate_differences(catalogue, rvparky)
    self.differences.each do |diff|
      diff.catalogue_value = catalogue.public_send(diff.catalogue_field)
      diff.rvparky_value = rvparky.public_send(diff.rvparky_field)
      diff.kind = value_compare_result(diff.catalogue_value, diff.rvparky_value)
      diff.save
    end
  end

  def populate_differences(catalogue, rvparky)
    # common_fields is taken from the CommonFields module.
    common_fields.each do |catalogue_field, rvparky_field|
      catalogue_value = catalogue.public_send(catalogue_field)
      rvparky_value = rvparky.public_send(rvparky_field)

      temp_model = self.differences.find_by(catalogue_field: catalogue_field)

      if temp_model.blank?
        temp_model = Difference.new()
        self.differences.push(temp_model)
      end

      temp_model.update({ catalogue_field: catalogue_field,
                          catalogue_value: catalogue_value,
                          rvparky_field: rvparky_field,
                          rvparky_value: rvparky_value,
                          kind: value_compare_result(catalogue_value, rvparky_value) })
      temp_model.save if temp_model.valid?
    end
  end

  def value_compare_result(catalogue_value, rvparky_value)
    return :match if catalogue_value.to_s == rvparky_value.to_s
    if catalogue_value.present? && rvparky_value.present?
      # Due to rounding differences between the two web services, values which
      # are obviously meant to be identical are not.
      return :match if (catalogue_value.to_f - rvparky_value.to_f).abs < 0.01
    end
    return :match if rvparky_value.blank? && catalogue_value.blank?
    return :rvparky_blank if rvparky_value.blank?
    return :catalogue_blank if catalogue_value.blank?
    return :mismatch
  end
end
