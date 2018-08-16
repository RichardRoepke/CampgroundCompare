class MembershipValidator
  include ActiveModel::Validations

  # Membership has additional fields but those don't seem to be sent by the API
  # so no point checking or validating them for now.
  attr_accessor :name
  attr_accessor :type

  validates :name, presence: true
  validates :type, presence: true

  validates :type, inclusion: { in: %w{ DISCOUNT RATING MEMBER\ ORGANIZATION AFFILIATE } }

  def initialize(input)
    @name = input[:name]
    @type = input[:type]
  end
end
