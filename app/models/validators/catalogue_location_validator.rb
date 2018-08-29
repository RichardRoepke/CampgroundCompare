class CatalogueLocationValidator
  include ActiveModel::Validations

  # The names of the various attributes match the names of the attributes in
  # the Central Catalogue, so that they don't have to be converted to and back
  # whenever retreiving or updating info.
  attr_accessor :uuid
  attr_accessor :type
  attr_accessor :name
  attr_accessor :bounceCode
  attr_accessor :address
  attr_accessor :city
  attr_accessor :postalCode
  attr_accessor :stateName
  attr_accessor :stateCode
  attr_accessor :countryName
  attr_accessor :countryCode
  attr_accessor :phone
  attr_accessor :email
  attr_accessor :website
  attr_accessor :latitude
  attr_accessor :longitude
  attr_accessor :description
  attr_accessor :descriptionShort
  attr_accessor :directions
  attr_accessor :alternativeName
  attr_accessor :formerName
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
  validates :stateName, presence: true
  validates :stateCode, presence: true
  validates :countryName, presence: true
  validates :countryCode, presence: true

  validates :uuid, length: { maximum: 255 }
  validates :type, inclusion: { in: %w{ Campground GasStation Store RestStop Casino } }
  validates :name, length: { maximum: 255 }
  validates :bounceCode, length: { maximum: 255 }, allow_blank: true
  validates :address, length: { maximum: 255 }
  validates :city, length: { maximum: 255 }
  validates :postalCode, length: { maximum: 255 }, allow_blank: true
  validates :stateName, length: { maximum: 255 }
  validates :stateCode, length: { maximum: 255 }
  validates :countryName, length: { maximum: 255 }
  validates :countryCode, length: { maximum: 255 }
  validates :phone, length: { maximum: 255 }, allow_blank: true
  validates :email, length: { maximum: 255 }, allow_blank: true
  validates :website, length: { maximum: 255 }, allow_blank: true
  validates :latitude, numericality: true, allow_blank: true
  validates :longitude, numericality: true, allow_blank: true
  validates :alternativeName, length: { maximum: 255 }, allow_blank: true
  validates :formerName, length: { maximum: 255 }, allow_blank: true
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
    @bounceCode = input[:bounceCode]
    @address = input[:address]
    @city = input[:city]
    @postalCode = input[:postalCode]
    @stateName = input[:stateName]
    @stateCode = input[:stateCode]
    @countryName = input[:countryName]
    @countryCode = input[:countryCode]
    @phone = input[:phone]
    @email = input[:email]
    @website = input[:website]
    @latitude = input[:latitude]
    @longitude = input[:longitude]
    @description = input[:description]
    @descriptionShort = input[:descriptionShort]
    @directions = input[:directions]
    @alternativeName = input[:alternativeName]
    @formerName = input[:formerName]
    @rating = input[:rating].to_f

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

  def review_count
    return @reviews.size
  end

  private

  def pair_lat_long
    # XNOR Long and Lat. True if both are present or neither are. False otherwise.
    unless (@longitude.present? && @latitude.present?) || (@longitude.blank? && @latitude.blank?)
      errors.add(:lat_long, 'Longitude and Latitude must both be present or both be blank.')
    end
  end

  def valid_amenities
    check_validator_array(@amenities, 'Amenities') if @amenities.present?
  end

  def valid_cobrands
    check_validator_array(@cobrands, 'Cobrands') if @cobrands.present?
  end

  def valid_images
    check_validator_array(@images, 'Images') if @images.present?
  end

  def valid_memberships
    check_validator_array(@memberships, 'Memberships') if @memberships.present?
  end

  def valid_nearbies
    check_validator_array(@nearbies, 'Nearbies') if @nearbies.present?
  end

  def valid_payments
    check_validator_array(@payments, 'Payments') if @payments.present?
  end

  def valid_rates
    check_validator_array(@rates, 'Rates') if @rates.present?
  end

  def valid_reviews
    check_validator_array(@reviews, 'Reviews') if @reviews.present?
  end

  def valid_tags
    check_validator_array(@tags, 'Tags') if @tags.present?
  end

  def check_validator_array(array, title)
    faults = []

    array.each do |validator|
      unless validator.valid?
        validator.errors.each do |tag, error|
          faults.push({ tag: tag, error: error })
        end
      end
    end

    unless faults.blank?
      errors.add(title.to_sym, 'were not all valid.')
      faults.each do |fault|
        errors.add(fault[:tag], fault[:error])
      end
    end
  end
end