require 'test_helper'

class AmenityValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { id: 7, name: 'Tester', group: 'Recreation', token: 'yes', description: 'A test amenity.' }
    @validator = AmenityValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.id = @params[:id]
    assert @validator.name = @params[:name]
    assert @validator.group = @params[:group]
    assert @validator.token = @params[:token]
    assert @validator.description = @params[:description]
  end

  test 'id must be present' do
    @validator.id = nil
    assert_not @validator.valid?
  end

  test 'name must be present' do
    @validator.name = nil
    assert_not @validator.valid?
  end

  test 'group must be present' do
    @validator.group = nil
    assert_not @validator.valid?
  end

  test 'token and description may be absent' do
    @params = { id: 4, name: 'Test', group: 'Facility' }
    @validator = AmenityValidator.new(@params)
    assert @validator.valid?
  end

  test 'id must be a number' do
    @validator.id = generate_random_string(1, 19)
    assert_not @validator.valid?
  end

  test 'id must be a positive number' do
    @validator.id = 3
    assert @validator.valid?

    @validator.id = 0
    assert_not @validator.valid?

    @validator.id = -3
    assert_not @validator.valid?
  end

  test 'name must be at most 255 characters' do
    @validator.name = generate_random_string(255)
    assert @validator.valid?

    @validator.name = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'group must be Facility Recreation or Rental' do
    @validator.group = 'Facility'
    assert @validator.valid?
    @validator.group = 'Recreation'
    assert @validator.valid?
    @validator.group = 'Rental'
    assert @validator.valid?

    @validator.group = generate_random_string(5, 15)
    assert_not @validator.valid?
  end

  test 'token can be nil' do
    @params[:token] = nil
    @validator = AmenityValidator.new(@params)
    assert @validator.valid?
    assert @validator.token == nil
  end

  test 'token must be at most 255 characters if present' do
    @validator.token = generate_random_string(255)
    assert @validator.valid?

    @validator.token = generate_random_string(256)
    assert_not @validator.valid?
  end
end
