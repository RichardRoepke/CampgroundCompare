require 'test_helper'

class MembershipValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { name: 'Tester', type: 'AFFILIATE' }
    @validator = MembershipValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.name == @params[:name]
    assert @validator.type == @params[:type]
  end

  test 'name should be present' do
    @validator.name = nil
    assert_not @validator.valid?
  end

  test 'type should be present' do
    @validator.type = nil
    assert_not @validator.valid?
  end

  test 'type should be one of four values' do
    @validator.type = 'DISCOUNT'
    assert @validator.valid?

    @validator.type = 'RATING'
    assert @validator.valid?

    @validator.type = 'MEMBER ORGANIZATION'
    assert @validator.valid?

    @validator.type = 'AFFILIATE'
    assert @validator.valid?

    @validator.type = generate_random_string(5, 15)
    assert_not @validator.valid?
  end
end