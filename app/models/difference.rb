class Difference
  include ActiveModel::Validations

  attr_accessor :catalogue_field
  attr_accessor :catalogue_value
  attr_accessor :rvparky_field
  attr_accessor :rvparky_value
  attr_accessor :kind

  validates :catalogue_field, presence: true
  validates :catalogue_value, presence: true
  validates :rvparky_field, presence: true
  validates :rvparky_value, presence: true
  validates :kind, presence: true

  validates :kind, inclusion: { in: %w{ RVParky\ Blank Catalogue\ Blank Value\ Mismatch } }

  def initialize(input)
    @catalogue_field = input[:catalogue_field]
    @catalogue_value = input[:catalogue_value]
    @rvparky_field = input[:rvparky_field]
    @rvparky_value = input[:rvparky_value]
    @kind = input[:kind]
  end
end