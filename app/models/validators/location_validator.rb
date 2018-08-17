class LocationValidator
  include ActiveModel::Validations

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

  validates :type, presence: true
  validates :name, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :state_code, presence: true
  validates :country, presence: true
  validates :country_code, presence: true

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

  validate :valid_uuid
  validate :valid_amenities
  validate :valid_cobrands
  validate :valid_images
  validate :valid_memberships
  validate :valid_nearbies
  validate :valid_payments
  validate :valid_reviews
  validate :valid_tags

  def initialize(input)
    @uuid = IdValidator.new(input[:uuid])
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
      @images.push ImageValidator.new(image)
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
      @reviews.push ReviewValidator.new(review)
    end if input[:reviews].present?

    @tags = []
    input[:tags].each do |tag|
      @tags.push TagValidator.new(tag)
    end if input[:tags].present?
  end

  def uuid
    @uuid.id
  end

  def uuid=(int)
    @uuid.id = int
  end

  private

  def valid_uuid
    unless @uuid.valid?
      @uuid.errors.each do |type, message|
        errors.add(type, message)
      end
    end
  end

  def valid_amenities
    if @amenities.present?
      errors.add(:amenities, 'wrong amenities.') unless check_validator_array(@amenities)
    end
  end

  def valid_cobrands
    if @cobrands.present?
      errors.add(:cobrands, 'wrong cobrands.') unless check_validator_array(@cobrands)
    end
  end

  def valid_images
    if @images.present?
      errors.add(:images, 'wrong images.') unless check_validator_array(@images)
    end
  end

  def valid_memberships
    if @memberships.present?
      errors.add(:memberships, 'wrong memberships.') unless check_validator_array(@memberships)
    end
  end

  def valid_nearbies
    if @nearbies.present?
      errors.add(:nearbies, 'wrong nearbies.') unless check_validator_array(@nearbies)
    end
  end

  def valid_payments
    if @payments.present?
      errors.add(:payments, 'wrong payments.') unless check_validator_array(@payments)
    end
  end

  def valid_reviews
    if @reviews.present?
      errors.add(:reviews, 'wrong reviews.') unless check_validator_array(@reviews)
    end
  end

  def valid_tags
    if @tags.present?
      errors.add(:tags, 'wrong tags.') unless check_validator_array(@tags)
    end
  end

  def check_validator_array(array)
    array.each do |validator|
      return false unless validator.valid?
    end

    return true # Will only be reached if all of the validators were valid.
  end
end