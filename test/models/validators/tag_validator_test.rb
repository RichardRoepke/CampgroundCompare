require 'test_helper'

class TagValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { id: 7,
                name: 'Tester',
                description: 'A test tag.' }
    @validator = TagValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.id == @params[:id]
    assert @validator.name == @params[:name]
    assert @validator.description == @params[:description]
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
end
