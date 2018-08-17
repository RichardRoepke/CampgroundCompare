class IdValidator
  include ActiveModel::Validations

  attr_accessor :id

  validates :id, presence: true
  validates :id, numericality: { only_integer: true }

  validate :positive_id

  def initialize(id)
    @id = id
  end

  private

  def positive_id
    if @id.present?
     if @id.to_i <= 0
      errors.add(:id, "must be positive if present.")
     end
     # If @id is not present then it'll be alerted already so no reason to do so
     # again. If @id wasn't present, then this would result in an error.
    end
  end
end