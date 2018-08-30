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
    @result = @controller.validate_changes(@params)
  end

  test 'validate_changes returns catalogue fields' do
    assert @result[:catalogue] == { phone: @params[:Catalogue_phone],
                                    address: @params[:Catalogue_address] }
  end

  test 'validate_changes returns rvparky fields' do
    assert @result[:rvparky] == { phone_number: @params[:RVParky_phone_number],
                                  address: @params[:RVParky_address] }
  end

  test 'validate_changes returns status of inputs' do
    assert @result[:status] == 'MATCH'

    @params[:Catalogue_address] = '55 Foobar Road'
    @result = @controller.validate_changes(@params)
    assert @result[:status] == 'MISMATCH'
  end
end
