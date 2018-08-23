require 'test_helper'

class PaymentOptionValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { name: 'Test', abbreviation: 'tt' }
    @validator = PaymentOptionValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.name == @params[:name]
    assert @validator.abbreviation == @params[:abbreviation]
  end

  test 'name must be at most 255 characters' do
    @validator.name = generate_random_string(255)
    assert @validator.valid?

    @validator.name = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'abbreviation must be at most 255 characters' do
    @validator.abbreviation = generate_random_string(255)
    assert @validator.valid?

    @validator.abbreviation = generate_random_string(256)
    assert_not @validator.valid?
  end
end
