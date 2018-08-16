class PaymentOptionValidator
  include ActiveModel::Validations

  attr_accessor :name
  attr_accessor :abbreviation

  validates :name, length: { maximum: 255 }, allow_blank: true
  validates :abbreviation, length: { maximum: 255 }, allow_blank: true

  def initialize(input)
    @name = input[:name]
    @abbreviation = input[:abbreviation]
  end
end
