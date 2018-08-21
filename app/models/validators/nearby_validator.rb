class NearbyValidator
  include ActiveModel::Validations

  # Aside from name, most of these values are rarely used but it is a good idea
  # to validate them in case things change in the future.
  attr_accessor :name
  attr_accessor :address
  attr_accessor :city
  attr_accessor :state
  attr_accessor :latitude
  attr_accessor :longitude
  attr_accessor :email
  attr_accessor :phone
  attr_accessor :website

  validates :name, presence: true

  validates :name, length: { maximum: 255 }
  validates :address, length: { maximum: 255 }, allow_blank: true
  validates :city, length: { maximum: 255 }, allow_blank: true
  validates :latitude, numericality: true, allow_blank: true
  validates :longitude, numericality: true, allow_blank: true
  validates :email, length: { maximum: 255 }, allow_blank: true
  validates :phone, length: { maximum: 255 }, allow_blank: true
  validates :website, length: { maximum: 255 }, allow_blank: true

  validate :pair_lat_long

  def initialize(input)
    @name = input[:name]
    @address = input[:address]
    @city = input[:city]
    @state = input[:state]
    @latitude = input[:latitude]
    @longitude = input[:longitude]
    @email = input[:email]
    @phone = input[:phone]
    @website = input[:website]
  end

  def pair_lat_long
    # XNOR Long and Lat. True if both are present or neither are. False otherwise.
    unless (@longitude.present? && @latitude.present?) || (@longitude.blank? && @latitude.blank?)
      errors.add(:lat_long, 'Longitude and Latitude must both be present or both be blank.')
    end
  end

end