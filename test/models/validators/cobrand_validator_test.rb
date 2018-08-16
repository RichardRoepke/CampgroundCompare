require 'test_helper'

class CobrandValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { id: 7, name: 'Tester', short: 'Test', code: 'yes', notes: 'None.', description: 'A test amenity.' }
    @validator = CobrandValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.id == @params[:id]
    assert @validator.name == @params[:name]
    assert @validator.short == @params[:short]
    assert @validator.code == @params[:code]
    assert @validator.notes == @params[:notes]
    assert @validator.description == @params[:description]
  end

  test 'name must be at most 255 characters' do
    @validator.name = generate_random_string(255)
    assert @validator.valid?

    @validator.name = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'short must be at most 255 characters' do
    @validator.short = generate_random_string(255)
    assert @validator.valid?

    @validator.short = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'code must be at most 255 characters' do
    @validator.code = generate_random_string(255)
    assert @validator.valid?

    @validator.code = generate_random_string(256)
    assert_not @validator.valid?
  end
end
