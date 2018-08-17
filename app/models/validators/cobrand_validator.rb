class CobrandValidator
  include ActiveModel::Validations

  attr_accessor :name
  attr_accessor :short
  attr_accessor :code
  attr_accessor :notes
  attr_accessor :description

  validates :name, length: { maximum: 255 }
  validates :short, length: { maximum: 255 }
  validates :code, length: { maximum: 255 }

  validate :valid_id

  def initialize(input)
    @id = IdValidator.new(input[:id])
    @name = input[:name]
    @short = input[:nameShort]
    @code = input[:code]
    @notes = input[:notes]
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