class MarkedPark < ApplicationRecord

  def initialize(input)
    @uuid = input[:uuid]
    @name = input[:name]
    @status = input[:status]
  end
end
