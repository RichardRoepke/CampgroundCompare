require 'test_helper'

class NearbyValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { name: 'Tester',
                address: '4 Test Street',
                city: 'Test City',
                state: 'Kansas',
                latitude: '1',
                longitude: '2',
                email: 'test@test.org',
                phone: '555-555-5555',
                website: 'test@test.com' }
    @validator = NearbyValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.name == @params[:name]
    assert @validator.address == @params[:address]
    assert @validator.city == @params[:city]
    assert @validator.state == @params[:state]
    assert @validator.latitude == @params[:latitude]
    assert @validator.longitude == @params[:longitude]
    assert @validator.email == @params[:email]
    assert @validator.phone == @params[:phone]
    assert @validator.website == @params[:website]
  end

  test 'name must be present' do
    @validator.name = nil
    assert_not @validator.valid?
  end

  test 'name must be at most 255 characters' do
    @validator.name = generate_random_string(255)
    assert @validator.valid?

    @validator.name = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'address must be at most 255 characters' do
    @validator.address = generate_random_string(255)
    assert @validator.valid?

    @validator.address = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'city must be at most 255 characters' do
    @validator.city = generate_random_string(255)
    assert @validator.valid?

    @validator.city = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'longitude must be a number' do
    @validator.longitude = 'number'
    assert_not @validator.valid?

    @validator.longitude = { number: 7 }
    assert_not @validator.valid?

    @validator.longitude = [4]
    assert_not @validator.valid?

    @validator.longitude = 2
    assert @validator.valid?
  end

  test 'latitude must be a number' do
    @validator.latitude = 'number'
    assert_not @validator.valid?

    @validator.latitude = { number: 7 }
    assert_not @validator.valid?

    @validator.latitude = [4]
    assert_not @validator.valid?

    @validator.latitude = 2
    assert @validator.valid?
  end

  test 'email must be at most 255 characters' do
    @validator.email = generate_random_string(255)
    assert @validator.valid?

    @validator.email = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'phone must be at most 255 characters' do
    @validator.phone = generate_random_string(255)
    assert @validator.valid?

    @validator.phone = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'website must be at most 255 characters' do
    @validator.website = generate_random_string(255)
    assert @validator.valid?

    @validator.website = generate_random_string(256)
    assert_not @validator.valid?
  end
end