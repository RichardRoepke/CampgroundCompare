require 'web_services_calls'

class MarkedPark < ApplicationRecord
  include CommonFields

  validates :uuid, :uniqueness => { :allow_blank => true }
  validates :slug, :uniqueness => { :allow_blank => true }

  has_many :differences, dependent: :destroy

  after_find do |park|
    update_status if self.updated_at < Date.yesterday
  end

  def self.field_includes(field, substring)
    where(field + " like ?", "%" + substring + "%")
  end

  def next
    MarkedPark.where("id > ?", id).first
  end

  def prev
    MarkedPark.where("id < ?", id).last
  end

  # Calling the services for park data is slow, but duplicating the data in the
  # database makes no sense either. So the *_input fields accept previously
  # retrieved data to reuse it instead of making yet another call to the services.
  def update_status(catalogue_input=nil, rvparky_input=nil)
    unless self.uuid.present? || self.slug.present?
      if catalogue_input.blank?
        catalogue_input = get_catalogue_location(self.uuid)
      end

      catalogue = CatalogueLocationValidator.new(catalogue_input) if catalogue_input.present? && catalogue_input.is_a?(Hash)

      if rvparky_input.blank?
        rvparky_input = get_rvparky_location(self.slug)
      end

      rvparky = RvparkyLocationValidator.new(rvparky_input) if rvparky_input.present? && rvparky_input.is_a?(Hash)

      self.editable = false

      if rvparky.present? && catalogue.present?
        self.status = calculate_status(catalogue, rvparky)
        self.editable = ['INFORMATION MISMATCH',
                         'BOTH LACK INFORMATION',
                         'RVPARKY LACKS INFORMATION',
                         'CATALOGUE LACKS INFORMATION'].include? self.status
      elsif catalogue_input.is_a?(Integer)
        self.status = 'INVALID CATALOGUE RESPONSE: ' + catalogue_input.to_s
      elsif rvparky_input.is_a?(Integer)
        self.status = 'INVALID RVPARKY RESPONSE: ' + rvparky_input.to_s
      else
        self.status = 'INVALID CONNECTIONS'
      end
    else
      self.status = 'SLUG IS MISSING' if self.slug.blank?
      self.status = 'UUID IS MISSING' if self.uuid.blank?
    end

    # To ensure that updated_at is set to the current time if everything else remains the same.
    # Otherwise the status would constantly be checked if the model is a day old or more.
    self.force_update = !self.force_update
    self.save
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

  def get_blank_differences(catalogue, rvparky)
    result = { catalogue: {},
               rvparky: {} }

    self.differences.each do |diff|
      result[:catalogue][diff.catalogue_field.to_sym] = diff.rvparky_value if catalogue.present? && diff.catalogue_blank?
      result[:rvparky][diff.rvparky_field.to_sym] = diff.catalogue_value if rvparky.present? && diff.rvparky_blank?
    end

    return result
  end

  def calculate_differences(catalogue, rvparky)
    # common_fields is taken from the CommonFields module.
    populate_differences(catalogue, rvparky)

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

  def populate_differences(catalogue, rvparky)
    # common_fields is taken from the CommonFields module.
    common_fields.each do |catalogue_field, rvparky_field|
      # Public send is a way to get values using variable keys for hashes.
      catalogue_value = catalogue.public_send(catalogue_field)
      rvparky_value = rvparky.public_send(rvparky_field)

      if value_compare_result(catalogue_value, rvparky_value) == :match
        temp_model = self.differences.find_by(catalogue_field: catalogue_field)
        temp_model.delete unless temp_model.blank?
      else
        temp_model = self.differences.find_by(catalogue_field: catalogue_field)

        temp_model = self.differences.create() if temp_model.blank?

        temp_model.update({ catalogue_field: catalogue_field,
                            catalogue_value: catalogue_value,
                            rvparky_field: rvparky_field,
                            rvparky_value: rvparky_value,
                            kind: value_compare_result(catalogue_value, rvparky_value) })
        temp_model.save if temp_model.valid?
      end
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

  def follow_301(catalogue_input=nil, rvparky_input=nil)
    # Currently works for RVParky slugs only, but Central Catalogue shouldn't
    # return 301 statuses so it shouldn't be a problem.
    result = { message: nil, status: nil }

    location = get_rvparky_location(self.slug, true)
    if location[:slug].present?
      self.slug = location[:slug]
      update_catalogue_location(self.uuid, 'location[slug]=' + location[:slug])
      self.update_status(catalogue_input, rvparky_input)
      self.destroy if self.status == 'DELETE ME'
      self.save if self.valid?

      if self.valid?
        result[:message] = 'Park was successfully updated.'
        result[:status] = 'SUCCESS'
      else
        result[:message] = 'Park could not be updated.'
        result[:status] = 'ALERT'
      end
    else
      result[:message] = '301 could not be followed. Please try again later.'
      result[:status] = 'WARNING'
    end

    return result
  end
end
