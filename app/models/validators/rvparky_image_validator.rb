class RvparkyImageValidator
  include ActiveModel::Validations

  # Actual file/url validation will be implemented later.
  attr_accessor :url
  attr_accessor :thumb

  validates :url, presence: true
  validates :thumb, presence: true


  def initialize(input)
    @url = input[:url]
    @thumb = input[:thumbUrl]
  end
end