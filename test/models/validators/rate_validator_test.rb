require 'test_helper'

class RateValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { seasonTypeName: 'Off Season',
                seasonStart: '1111-11-11',
                seasonEnd: '1111-11-11',
                minRate: 4.4,
                maxRate: 7.7,
                personsIncluded: 3 }
    @validator = RateValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.name == @params[:seasonTypeName]
    assert @validator.start == @params[:seasonStart]
    assert @validator.end == @params[:seasonEnd]
    assert @validator.min_rate == @params[:minRate]
    assert @validator.max_rate == @params[:maxRate]
    assert @validator.persons == @params[:personsIncluded]
  end

  test 'name must be present' do
    @validator.name = nil
    assert_not @validator.valid?
  end

  test 'start must be present' do
    @validator.start = nil
    assert_not @validator.valid?
  end

  test 'end must be present' do
    @validator.end = nil
    assert_not @validator.valid?
  end

  test 'min_rate must be present' do
    @validator.min_rate = nil
    assert_not @validator.valid?
  end

  test 'max_rate must be present' do
    @validator.max_rate = nil
    assert_not @validator.valid?
  end

  test 'persons must be present' do
    @validator.persons = nil
    assert_not @validator.valid?
  end

  test 'min_rate must be a number' do
    @validator.min_rate = 'number'
    assert_not @validator.valid?

    @validator.min_rate = { number: 7 }
    assert_not @validator.valid?

    @validator.min_rate = [4]
    assert_not @validator.valid?

    @validator.min_rate = 2
    assert @validator.valid?
  end

  test 'max_rate must be a number' do
    @validator.max_rate = 'number'
    assert_not @validator.valid?

    @validator.max_rate = { number: 7 }
    assert_not @validator.valid?

    @validator.max_rate = [4]
    assert_not @validator.valid?

    @validator.max_rate = 2
    assert @validator.valid?
  end

  test 'persons must be a number' do
    @validator.persons = 'number'
    assert_not @validator.valid?

    @validator.persons = { number: 7 }
    assert_not @validator.valid?

    @validator.persons = [4]
    assert_not @validator.valid?

    @validator.persons = 2
    assert @validator.valid?
  end

  test 'persons must be an integer' do
    @validator.persons = 7.7
    assert_not @validator.valid?
  end
end
