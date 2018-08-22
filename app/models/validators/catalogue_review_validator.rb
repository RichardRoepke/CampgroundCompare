class CatalogueReviewValidator
  include ActiveModel::Validations

  attr_accessor :username
  attr_accessor :rating
  attr_accessor :body
  attr_accessor :title
  attr_accessor :created
  attr_accessor :arrival
  attr_accessor :departure
  attr_accessor :reviewed

  validates :username, presence: true
  validates :rating, presence: true
  validates :body, presence: true
  validates :created, presence: true

  validates :username, length: { maximum: 255 }
  validates :rating, numericality: { only_integer: true }
  validates :title, length: { maximum: 255 }, allow_blank: true
  validates :reviewed, inclusion: { in: [true, false] }, allow_blank: true

  validate :rating_proper_range
  validate :valid_location
  validate :valid_dates

  def initialize(input)
    @username = input[:username]
    @rating = input[:rating]
    @body = input[:body]
    @title = input[:title]
    @created = input[:createdOn]
    @arrival = input[:arrival]
    @departure = input[:departure]
    if input[:underReview].is_a?(String)
      @reviewed = input[:underReview] == 'true'
    else
      @reviewed = !!input[:underReview]
    end
    @location = IdValidator.new(input[:location])
  end

  def location
    @location.id
  end

  def location=(int)
    @location.id = int
  end

  private

  def valid_location
    return @location.valid?
  end

  def rating_proper_range
    if @rating.present?
     if @rating.to_i <= 0 || @rating.to_i > 5
      errors.add(:rating, "must be between 1 and 5.")
     end
    end
  end

  def valid_dates
    if @created.present?
      errors.add(:created, 'must be a valid date.') unless check_date(@created)
    end

    if @arrival.present?
      errors.add(:arrival, 'must be a valid date.') unless check_date(@arrival)
    end

    if @departure.present?
      errors.add(:departure, 'must be a valid date.') unless check_date(@departure)
    end
  end

  def check_date(date)
    Date.parse(date)
    return true
  rescue # If the date could not be parsed.
    return false
  end
end