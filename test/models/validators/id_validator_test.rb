require 'test_helper'

class IdValidatorTest < ActiveSupport::TestCase
  def setup
    @validator = IdValidator.new(7)
  end

  test 'validator should be setup properly' do
    assert @validator.valid?
    assert @validator.id = 7
  end

  test 'id must be present' do
    @validator.id = nil
    assert_not @validator.valid?
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
end