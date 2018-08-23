class CatalogueLocationValidator
  include ActiveModel::Validations

  attr_accessor :uuid
  attr_accessor :type
  attr_accessor :name
  attr_accessor :bounce
  attr_accessor :address
  attr_accessor :city
  attr_accessor :postal
  attr_accessor :state
  attr_accessor :state_code
  attr_accessor :country
  attr_accessor :country_code
  attr_accessor :phone
  attr_accessor :email
  attr_accessor :website
  attr_accessor :latitude
  attr_accessor :longitude
  attr_accessor :description
  attr_accessor :description_short
  attr_accessor :directions
  attr_accessor :alt_name
  attr_accessor :former_name
  attr_accessor :rating

  # Arrays of various attributes, like tags, reviews, etc, etc.
  attr_accessor :amenities
  attr_accessor :cobrands
  attr_accessor :images
  attr_accessor :memberships
  attr_accessor :nearbies
  attr_accessor :payments
  attr_accessor :rates
  attr_accessor :reviews
  attr_accessor :tags

  validates :uuid, presence: true
  validates :type, presence: true
  validates :name, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :state_code, presence: true
  validates :country, presence: true
  validates :country_code, presence: true

  validates :uuid, length: { maximum: 255 }
  validates :type, inclusion: { in: %w{ Campground GasStation Store RestStop Casino } }
  validates :name, length: { maximum: 255 }
  validates :bounce, length: { maximum: 255 }, allow_blank: true
  validates :address, length: { maximum: 255 }
  validates :city, length: { maximum: 255 }
  validates :postal, length: { maximum: 255 }, allow_blank: true
  validates :state, length: { maximum: 255 }
  validates :state_code, length: { maximum: 255 }
  validates :country, length: { maximum: 255 }
  validates :country_code, length: { maximum: 255 }
  validates :phone, length: { maximum: 255 }, allow_blank: true
  validates :email, length: { maximum: 255 }, allow_blank: true
  validates :website, length: { maximum: 255 }, allow_blank: true
  validates :latitude, numericality: true, allow_blank: true
  validates :longitude, numericality: true, allow_blank: true
  validates :alt_name, length: { maximum: 255 }, allow_blank: true
  validates :former_name, length: { maximum: 255 }, allow_blank: true
  validates :rating, numericality: true, allow_blank: true

  validate :pair_lat_long
  validate :valid_amenities
  validate :valid_cobrands
  validate :valid_images
  validate :valid_memberships
  validate :valid_nearbies
  validate :valid_payments
  validate :valid_rates
  validate :valid_reviews
  validate :valid_tags

  def initialize(input)
    @uuid = input[:uuid]
    @type = input[:type]
    @name = input[:name]
    @bounce = input[:bounceCode]
    @address = input[:address]
    @city = input[:city]
    @postal = input[:postalCode]
    @state = input[:stateName]
    @state_code = input[:stateCode]
    @country = input[:countryName]
    @country_code = input[:countryCode]
    @phone = input[:phone]
    @email = input[:email]
    @website = input[:website]
    @latitude = input[:latitude]
    @longitude = input[:longitude]
    @description = input[:description]
    @description_short = input[:descriptionShort]
    @directions = input[:directions]
    @alt_name = input[:alternativeName]
    @former_name = input[:formerName]
    @rating = input[:rating]

    @amenities = []
    input[:amenities].each do |amenity|
      @amenities.push AmenityValidator.new(amenity)
    end if input[:amenities].present?

    @cobrands = []
    input[:cobrands].each do |cobrand|
      @cobrands.push CobrandValidator.new(cobrand)
    end if input[:cobrands].present?

    @images = []
    input[:images].each do |image|
      @images.push CatalogueImageValidator.new(image)
    end if input[:images].present?

    @memberships = []
    input[:memberships].each do |membership|
      @memberships.push MembershipValidator.new(membership)
    end if input[:memberships].present?

    @nearbies = []
    input[:nearbies].each do |nearby|
      @nearbies.push NearbyValidator.new(nearby)
    end if input[:nearbies].present?

    @payments = []
    input[:paymentOptions].each do |payment|
      @payments.push PaymentOptionValidator.new(payment)
    end if input[:paymentOptions].present?

    @rates = []
    input[:rates].each do |rate|
      @rates.push RateValidator.new(rate)
    end if input[:rates].present?

    @reviews = []
    input[:reviews].each do |review|
      @reviews.push CatalogueReviewValidator.new(review)
    end if input[:reviews].present?

    @tags = []
    input[:tags].each do |tag|
      @tags.push TagValidator.new(tag)
    end if input[:tags].present?
  end

  private

  def pair_lat_long
    # XNOR Long and Lat. True if both are present or neither are. False otherwise.
    unless (@longitude.present? && @latitude.present?) || (@longitude.blank? && @latitude.blank?)
      errors.add(:lat_long, 'Longitude and Latitude must both be present or both be blank.')
    end
  end

  def valid_amenities
    check_validator_array(@amenities)
  end

  def valid_cobrands
    check_validator_array(@cobrands)
  end

  def valid_images
    check_validator_array(@images)
  end

  def valid_memberships
    check_validator_array(@memberships)
  end

  def valid_nearbies
    check_validator_array(@nearbies)
  end

  def valid_payments
    check_validator_array(@payments)
  end

  def valid_rates
    check_validator_array(@rates)
  end

  def valid_reviews
    check_validator_array(@reviews)
  end

  def valid_tags
    check_validator_array(@tags)
  end

  def check_validator_array(array)
    array.each do |validator|
      unless validator.valid?
        validator.errors.each do |tag, error|
          errors.add(tag, error)
        end
        return false
      end
    end

    return true # Will only be reached if all of the validators were valid.
  end
end