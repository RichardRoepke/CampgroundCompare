require 'test_helper'

class ReviewValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { username: 'Test User',
                rating: 5,
                body: 'A fine test review.',
                title: 'Test',
                createdOn: '1111-11-11',
                arrival: '1111-11-11',
                departure: '1111-11-11',
                underReview: true,
                location: 4 }
    @validator = ReviewValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.username == @params[:username]
    assert @validator.rating == @params[:rating]
    assert @validator.body == @params[:body]
    assert @validator.title == @params[:title]
    assert @validator.created == @params[:createdOn]
    assert @validator.arrival == @params[:arrival]
    assert @validator.departure == @params[:departure]
    assert @validator.reviewed == @params[:underReview]
    assert @validator.location == @params[:location]
  end

  test 'username must be present' do
    @validator.username = nil
    assert_not @validator.valid?
  end

  test 'rating must be present' do
    @validator.rating = nil
    assert_not @validator.valid?
  end

  test 'body must be present' do
    @validator.body = nil
    assert_not @validator.valid?
  end

  test 'title must be present' do
    @validator.title = nil
    assert_not @validator.valid?
  end

  test 'created must be present' do
    @validator.created = nil
    assert_not @validator.valid?
  end

  test 'reviewed must be present' do
    @validator.reviewed = nil
    assert_not @validator.valid?
  end

  test 'username must be at most 255 characters' do
    @validator.username = generate_random_string(255)
    assert @validator.valid?

    @validator.username = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'rating must be a number' do
    @validator.rating = generate_random_string(5, 15)
    assert_not @validator.valid?
  end

  test 'title must be at most 255 characters' do
    @validator.title = generate_random_string(255)
    assert @validator.valid?

    @validator.title = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'reviewed must be a boolean' do
    @validator.reviewed = generate_random_string(5, 15)
    assert_not @validator.valid?
  end

  test 'rating must be between 1 and 5' do
    @validator.rating = 0
    assert_not @validator.valid?

    1.upto(5) do |i|
      @validator.rating = i
      assert @validator.valid?
    end

    @validator.rating = 6
    assert_not @validator.valid?
  end

  test 'created must be a valid date' do
    @validator.created = 'Foobar'
    assert_not @validator.valid?

    @validator.created = '99999999999'
    assert_not @validator.valid?

    @validator.created = '2018-08-08'
    assert @validator.valid?
  end

  test 'arrival must be a valid date' do
    @validator.arrival = 'Foobar'
    assert_not @validator.valid?

    @validator.arrival = '99999999999'
    assert_not @validator.valid?

    @validator.arrival = '2018-08-08'
    assert @validator.valid?
  end

  test 'departure must be a valid date' do
    @validator.departure = 'Foobar'
    assert_not @validator.valid?

    @validator.departure = '99999999999'
    assert_not @validator.valid?

    @validator.departure = '2018-08-08'
    assert @validator.valid?
  end
end