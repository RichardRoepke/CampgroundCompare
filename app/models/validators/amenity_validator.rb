class AmenityValidator
  include ActiveModel::Validations

  attr_accessor :id
  attr_accessor :name
  attr_accessor :group
  attr_accessor :token
  attr_accessor :description

  validates :id, presence: true
  validates :name, presence: true
  validates :group, presence: true

  validates :id, numericality: { only_integer: true }
  validates :name, length: { maximum: 255 }
  validates :group, inclusion: { in: %w{ Facility Recreation Rental } }
  validates :token, length: { maximum: 255 }, allow_blank: true

  validate :positive_id

  def initialize(input)
    @id = input[:id]
    @name = input[:name]
    @group = input[:group]
    @token = input[:token]
    @description = input[:description]
  end

  private

  def positive_id
    if @id.blank? || @id.to_i <= 0
      errors.add(:id, "must be positive if present.")
    end
  end
end
