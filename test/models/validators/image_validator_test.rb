require 'test_helper'

class ImageValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { id: 7, alt: 'alternative', title: 'Image Title', caption: 'No' }
    @validator = ImageValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.id == @params[:id]
    assert @validator.alt == @params[:alt]
    assert @validator.title == @params[:title]
    assert @validator.caption == @params[:caption]
  end

  test 'alt should be present' do
    @validator.alt = nil
    assert_not @validator.valid?
  end

  test 'caption should be present' do
    @validator.caption = nil
    assert_not @validator.valid?
  end

  test 'alt must be at most 255 characters' do
    @validator.alt = generate_random_string(255)
    assert @validator.valid?

    @validator.alt = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'title must be at most 255 characters' do
    @validator.title = generate_random_string(255)
    assert @validator.valid?

    @validator.title = generate_random_string(256)
    assert_not @validator.valid?
  end

  test 'caption must be at most 255 characters' do
    @validator.caption = generate_random_string(255)
    assert @validator.valid?

    @validator.caption = generate_random_string(256)
    assert_not @validator.valid?
  end
end