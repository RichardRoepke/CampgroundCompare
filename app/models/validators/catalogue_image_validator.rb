class CatalogueImageValidator
  include ActiveModel::Validations

  # Actual file/url validation will be implemented later.
  attr_accessor :alt
  attr_accessor :title
  attr_accessor :caption

  validates :alt, length: { maximum: 255 }, allow_blank: true
  validates :title, length: { maximum: 255 }, allow_blank: true
  validates :caption, length: { maximum: 255 }, allow_blank: true

  validate :valid_id

  def initialize(input)
    @id = IdValidator.new(input[:id])
    @alt = input[:alt]
    @title = input[:title]
    @caption = input[:caption]
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