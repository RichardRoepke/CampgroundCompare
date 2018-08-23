class RateValidator
  include ActiveModel::Validations

  attr_accessor :name
  attr_accessor :start
  attr_accessor :end
  attr_accessor :min_rate
  attr_accessor :max_rate
  attr_accessor :persons

  validates :name, presence: true
  validates :start, presence: true
  validates :end, presence: true
  validates :min_rate, presence: true
  validates :max_rate, presence: true
  validates :persons, presence: true

  # Once the valid states/conditions are name are known, validate them here.
  validates :min_rate, numericality: true
  validates :max_rate, numericality: true
  validates :persons, numericality: { only_integer: true }

  validate :valid_dates

  def initialize(input)
    @name = input[:seasonTypeName]
    @start = input[:seasonStart]
    @end = input[:seasonEnd]
    @min_rate = input[:minRate]
    @max_rate = input[:maxRate]
    @persons = input[:personsIncluded]
  end

  private

  def valid_dates
    if @start.present?
      errors.add(:seasonStart, 'must be a valid date.') unless check_date(@start)
    end

    if @end.present?
      errors.add(:seasonEnd, 'must be a valid date.') unless check_date(@end)
    end
  end

  def check_date(date)
    Date.parse(date)
    return true
  rescue # If the date could not be parsed.
    return false
  end
end
