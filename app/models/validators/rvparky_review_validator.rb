class RvparkyReviewValidator
  include ActiveModel::Validations

  attr_accessor :rating
  attr_accessor :text
  attr_accessor :start
  attr_accessor :author_name
  attr_accessor :end
  attr_accessor :date
  attr_accessor :title
  attr_accessor :author
  attr_accessor :comments

  validates :rating, presence: true
  validates :author_name, presence: true
  validates :date, presence: true
  validates :author, presence: true

  validates :rating, numericality: { only_integer: true }
  validates :author, numericality: { only_integer: true }

  validate :rating_proper_range
  validate :valid_location
  validate :valid_id
  validate :valid_dates

  def initialize(input)
    @rating = input[:rating]
    @text = input[:text]
    @start = input[:date_stayed_start]
    @author_name = input[:author_name]
    @end = input[:date_stayed_end]
    @date = input[:date]
    @author = input[:author]
    @title = input[:title]
    @comments = input[:comments] #Will be fleshed out once actual comments are seen.

    @location = IdValidator.new(input[:location])
    @id = IdValidator.new(input[:id])
  end

  def location
    @location.id
  end

  def location=(int)
    @location.id = int
  end

  def id
    @id.id
  end

  def id=(int)
    @id.id = int
  end

  private

  def valid_location
    return @location.valid?
  end

  def valid_id
    return @id.valid?
  end

  def rating_proper_range
    if @rating.present?
     if @rating.to_i <= 0 || @rating.to_i > 5
      errors.add(:rating, "must be between 1 and 5.")
     end
    end
  end

  def valid_dates
    if @date.present?
      errors.add(:date, 'must be a valid date.') unless check_date(@date)
    end

    if @start.present?
      errors.add(:start, 'must be a valid date.') unless check_date(@start)
    end

    if @end.present?
      errors.add(:end, 'must be a valid date.') unless check_date(@end)
    end
  end

  def check_date(date)
    Date.parse(date)
    return true
  rescue # If the date could not be parsed.
    return false
  end
end