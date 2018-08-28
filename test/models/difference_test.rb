require 'test_helper'
 class DifferenceTest < ActiveSupport::TestCase
  def setup
    @params = { catalogue_field: 'body',
                catalogue_value: 'none',
                rvparky_field: 'text',
                rvparky_value: 'none',
                kind: 'Catalogue Blank' }
    @difference = Difference.new(@params)
  end

  test 'validator should be setup properly' do
    assert @difference.valid?
    assert @difference.catalogue_field == @params[:catalogue_field]
    assert @difference.catalogue_value == @params[:catalogue_value]
    assert @difference.rvparky_field == @params[:rvparky_field]
    assert @difference.rvparky_value == @params[:rvparky_value]
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

  test 'kind accepts limited inputs' do
    @difference.kind = 'RVParky Blank'
    assert @difference.valid?

    @difference.kind = 'Catalogue Blank'
    assert @difference.valid?

    @difference.kind = 'Value Mismatch'
    assert @difference.valid?

    @difference.kind = generate_random_string(5, 15)
    assert_not @difference.valid?
  end
end