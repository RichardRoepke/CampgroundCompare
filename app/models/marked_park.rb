class MarkedPark < ApplicationRecord
    validates :uuid, uniqueness: true

    has_many :difference

    after_initialize do |park|
      park.difference = calculate_differences
      park.status = calculate_status(park.difference)
    end

    def calculate_differences
      return []
    end

    def calculate_status(differences)
      return 'Temp'
    end
end
