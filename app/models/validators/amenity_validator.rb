class AmenityValidator
  include ActiveModel::Validations

  attr_accessor :name
  attr_accessor :group
  attr_accessor :token
  attr_accessor :description

  validates :name, presence: true
  validates :group, presence: true

  validates :name, length: { maximum: 255 }
  validates :group, inclusion: { in: %w{ Facility Recreation Rental } }
  validates :token, length: { maximum: 255 }, allow_blank: true

  validate :valid_id

  def initialize(input)
    @id = IdValidator.new(input[:id])
    @name = input[:name]
    @group = input[:group]
    @token = input[:token]
    @description = input[:description]
  end

  def id
    @id.id
  end

  def id=(int)
    @id.id = int
  end

  private

  def valid_id
    unless @id.valid?
      @id.errors.each do |type, message|
        errors.add(type, message)
      end
    end
  end
end
