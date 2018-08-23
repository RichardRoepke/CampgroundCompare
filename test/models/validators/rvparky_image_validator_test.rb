require 'test_helper'

class RvparkyImageValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { url: '5',
                thumbUrl: '7' }
    @validator = RvparkyImageValidator.new(@params)
  end

  test 'validator should set up properly' do
    assert @validator.valid?
    assert @validator.url == @params[:url]
    assert @validator.thumb == @params[:thumbUrl]
  end

  test 'url must be present' do
    @validator.url = nil
    assert_not @validator.valid?
  end

  test 'thumb url must be present' do
    @validator.thumb = nil
    assert_not @validator.valid?
  end
end
