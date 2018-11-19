require 'test_helper'

class MarkedParkControllerTest < ActionDispatch::IntegrationTest
  def setup
    @params = { id: 7,
                action: 'foobar',
                Catalogue_phone: '555-555-5555',
                RVParky_phone_number: '555-555-5555',
                Catalogue_address: '94 Testing Street',
                RVParky_address: '94 Testing Street' }
    @controller = MarkedParkController.new()
  end
end
