class RvparkyLocationValidator
  include ActiveModel::Validations


  # The names of the various attributes match the names of the attributes in
  # RVParky, so that they don't have to be converted to and back whenever
  # retreiving or updating info.
  attr_accessor :website
  attr_accessor :formerlyKnownAs
  attr_accessor :weeklyRateUpdated
  attr_accessor :rating
  attr_accessor :dailyRate_offseason
  attr_accessor :alsoKnownAs
  attr_accessor :dailyRate
  attr_accessor :category
  attr_accessor :city
  attr_accessor :review_count
  attr_accessor :reservation_url
  attr_accessor :longitude
  attr_accessor :latitude
  attr_accessor :sites
  attr_accessor :discounts
  attr_accessor :closed
  attr_accessor :zip_code
  attr_accessor :phone_number
  attr_accessor :open_dates
  attr_accessor :seasonalRates
  attr_accessor :description
  attr_accessor :offSeasonDates
  attr_accessor :address
  attr_accessor :slug
  attr_accessor :inSeasonDates
  attr_accessor :name
  attr_accessor :dailyRateUpdated
  attr_accessor :monthlyRateUpdated
  attr_accessor :region
  attr_accessor :monthlyRate
  attr_accessor :weeklyRate
  attr_accessor :weeklyRate_offseason
  attr_accessor :monthlyRate_offseason

  # Arrays of various attributes, like tags, reviews, etc, etc.
  attr_accessor :amenities
  attr_accessor :attributes # boolean values about whether or not something exists in the location.
  attr_accessor :images
  attr_accessor :reviews

  validates :rating, presence: true
  validates :category, presence: true
  validates :city, presence: true
  validates :sites, presence: true
  validates :slug, presence: true
  validates :name, presence: true
  validates :region, presence: true

  validates :rating, numericality: true
  validates :longitude, numericality: true, allow_blank: true
  validates :latitude, numericality: true, allow_blank: true
  validates :sites, numericality: { only_integer: true }
  validates :review_count, numericality: { only_integer: true }, allow_blank: true

  validate :pair_lat_long
  validate :valid_amenities
  validate :valid_dates
  validate :valid_id
  validate :valid_images
  validate :valid_reviews

  def initialize(input)
    @website = input[:website]
    @formerlyKnownAs = input[:formerlyKnownAs]
    @weeklyRateUpdated = input[:weeklyRateUpdated]
    @rating = input[:rating]
    @dailyRate_offseason = input[:dailyRate_offseason]
    @alsoKnownAs = input[:alsoKnownAs]
    @dailyRate = input[:dailyRate]
    @category = input[:category]
    @city = input[:city]
    @review_count = input[:review_count]
    @reservation_url = input[:reservation_url]
    @longitude = input[:longitude]
    @latitude = input[:latitude]
    @sites = input[:sites]
    @discounts = input[:discounts]
    @closed = input[:closed]
    @zip_code = input[:zip_code]
    @phone_number = input[:phone_number]
    @open_dates = input[:open_dates]
    @seasonalRates = input[:seasonalRates]
    @description = input[:description]
    @offSeasonDates = input[:offSeasonDates]
    @address = input[:address]
    @slug = input[:slug]
    @inSeasonDates = input[:inSeasonDates]
    @name = input[:name]
    @dailyRateUpdated = input[:dailyRateUpdated]
    @monthlyRateUpdated = input[:monthlyRateUpdated]
    @region = input[:region]
    @monthlyRate = input[:monthlyRate]
    @weeklyRate = input[:weeklyRate]
    @weeklyRate_offseason = input[:weeklyRate_offseason]
    @monthlyRate_offseason = input[:monthlyRate_offseason]

    @amenities = input[:amenities]

    @images = []
    input[:pictures].each do |image|
      @images.push RvparkyImageValidator.new(image)
    end if input[:pictures].present?

    @reviews = []
    input[:reviews].each do |review|
      @reviews.push RvparkyReviewValidator.new(review)
    end if input[:reviews].present?

    # RV Parky stores/presents a lot of boolean attributes all over the place.
    # Instead of having a separate variable for each and every one of them, @attribute
    # stores all of the positive/true attributes. If the attribute isn't in
    # @attribute then it's assumed to be false.
    @attributes = []
    input.each do |key, value|
      @attributes.push(key.to_s) if value.is_a?(Integer) && value == 1
    end

    @attributes.uniq! # Ensure that all attributes are unique.

    @id = IdValidator.new(input[:id])

    # RVParky gives phone numbers as (XXX)YYY-ZZZZ whereas Catalogue gives them as
    # (XXX) YYY-ZZZZ, with a space between the area-code and rest of the number.
    # This expression inserts that space, to prevent obviously identical phone numbers
    # from being flagged as a mismatch.
    @phone_number.insert(5, ' ') if @phone_number.match('\A\(\d{3}\)\d{3}-\d{4}\z')
  end

  def id
    @id.id
  end

  def id=(int)
    @id.id = int
  end

  def attribute_present(value)
    return attributes.select { |v| v == value}.size
  end

  private

  def pair_lat_long
    # XNOR Long and Lat. True if both are present or neither are. False otherwise.
    unless (@longitude.present? && @latitude.present?) || (@longitude.blank? && @latitude.blank?)
      errors.add(:lat_long, 'Longitude and Latitude must both be present or both be blank.')
    end
  end

  def valid_amenities
    @amenities.each do |amenity|
      errors.add(:amenity, amenity + ' is not exactly three characters') unless amenity.length == 3
    end if @amenities.present?
  end

  def valid_dates
    if @weeklyRateUpdated.present?
      errors.add(:weeklyRateUpdated, 'must be a valid date.') unless check_date(@weeklyRateUpdated)
    end

    if @dailyRateUpdated.present?
      errors.add(:dailyRateUpdated, 'must be a valid date.') unless check_date(@dailyRateUpdated)
    end

    if @monthlyRateUpdated.present?
      errors.add(:monthlyRateUpdated, 'must be a valid date.') unless check_date(@monthlyRateUpdated)
    end
  end

  def valid_id
    unless @id.valid?
      @id.errors.each do |type, message|
        errors.add(type, message)
      end
    end
  end

  def valid_images
    check_validator_array(@images, 'Images') if @images.present?
  end

  def valid_reviews
    if @reviews.present?
      check_validator_array(@reviews, 'Reviews')

      errors.add(:review_count, 'Number of reviews and the actual number do not match') unless @reviews.size == @review_count
    end
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

  def check_date(date)
    Date.parse(date)
    return true
  rescue # If the date could not be parsed.
    return false
  end
end