require 'test_helper'

class DifferenceTest < ActiveSupport::TestCase
  def setup
    @params = { catalogue_field: 'body',
                rvparky_field: 'text',
                kind: 'catalogue_blank' }
    @difference = Difference.new(@params)
  end

  test 'validator should be setup properly' do
    assert @difference.valid?
    assert @difference.catalogue_field == @params[:catalogue_field]
    assert @difference.rvparky_field == @params[:rvparky_field]
    assert @difference.kind == @params[:kind]
  end

  test 'catalogue_field must be present' do
    @difference.catalogue_field = nil
    assert_not @difference.valid?
  end

  test 'rvparky_field must be present' do
    @difference.rvparky_field = nil
    assert_not @difference.valid?
  end

  test 'kind must be present' do
    @difference.kind = nil
    assert_not @difference.valid?
  end

  test 'kind is an enum' do
    @difference.catalogue_blank!
    assert @difference.kind == 'catalogue_blank'
    assert @difference.catalogue_blank?

    @difference.rvparky_blank!
    assert @difference.kind == 'rvparky_blank'
    assert @difference.rvparky_blank?

    @difference.mismatch!
    assert @difference.kind == 'mismatch'
    assert @difference.mismatch?
  end
end
