class PendingPark < ApplicationRecord
  validates :uuid, :uniqueness => { :allow_blank => true }
  validates :slug, :uniqueness => { :allow_blank => true }
  validates :rvparky_id, :uniqueness => { :allow_blank => true }

  validate :uuid_slug_or_id_present
  validate :ensure_uniqueness

  enum status: [:awaiting_check, :added, :unneeded, :failed]

  def uuid_slug_or_id_present
    if uuid.blank? && slug.blank? && rvparky_id.blank?
      errors.add(:invalid, 'UUID or Id must be present.')
    end
  end

  def ensure_uniqueness
    # Can't check ids without web services calls, unfortunately.
    if slug.present? && MarkedPark.find_by(slug: slug).present?
      errors.add(:invalid, 'Park is already marked in the database.')
    end

    if slug.present? && MarkedPark.find_by(slug: slug).present?
      errors.add(:invalid, 'Park is already marked in the database.')
    end
  end
end
