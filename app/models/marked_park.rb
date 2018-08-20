class MarkedPark < ApplicationRecord
    validates :uuid, uniqueness: true
end
