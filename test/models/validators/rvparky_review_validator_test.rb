require 'test_helper'

class RvparkyReviewValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { rating: 5,
                text: 'A fine test review.',
                date_stayed_start: '1111-11-11',
                author_name: 'Test Sam',
                date_stayed_end: '1111-11-11',
                date: '1111-11-11',
                author: 7,
                title: 'Test',
                comments: ['Test Comment'],
                location: 4,
                id: 3 }
    @validator = RvparkyReviewValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.rating == @params[:rating]
    assert @validator.text == @params[:text]
    assert @validator.start == @params[:date_stayed_start]
    assert @validator.author_name == @params[:author_name]
    assert @validator.end == @params[:date_stayed_end]
    assert @validator.date == @params[:date]
    assert @validator.author == @params[:author]
    assert @validator.title == @params[:title]
    assert @validator.comments == @params[:comments]
    assert @validator.location == @params[:location]
    assert @validator.id == @params[:id]
  end

  test 'rating must be present' do
    @validator.rating = nil
    assert_not @validator.valid?
  end

  test 'author_name must be present' do
    @validator.author_name = nil
    assert_not @validator.valid?
  end

  test 'date must be present' do
    @validator.date = nil
    assert_not @validator.valid?
  end

  test 'author must be present' do
    @validator.author = nil
    assert_not @validator.valid?
  end

  test 'rating must be a number' do
    @validator.rating = generate_random_string(5, 15)
    assert_not @validator.valid?
  end

  test 'author must be a number' do
    @validator.author = generate_random_string(5, 15)
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

  test 'start must be a valid date' do
    @validator.start = 'Foobar'
    assert_not @validator.valid?

    @validator.start = '99999999999'
    assert_not @validator.valid?

    @validator.start = '2018-08-08'
    assert @validator.valid?
  end

  test 'end must be a valid date' do
    @validator.end = 'Foobar'
    assert_not @validator.valid?

    @validator.end = '99999999999'
    assert_not @validator.valid?

    @validator.end = '2018-08-08'
    assert @validator.valid?
  end

  test 'date must be a valid date' do
    @validator.date = 'Foobar'
    assert_not @validator.valid?

    @validator.date = '99999999999'
    assert_not @validator.valid?

    @validator.date = '2018-08-08'
    assert @validator.valid?
  end
end