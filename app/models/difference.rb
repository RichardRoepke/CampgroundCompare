class Difference < ApplicationRecord
  validates :catalogue_field, presence: true
  validates :rvparky_field, presence: true
  validates :kind, presence: true

  enum kind: [:rvparky_blank, :catalogue_blank, :mismatch, :match]

  belongs_to :marked_park
end
