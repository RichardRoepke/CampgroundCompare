require 'test_helper'
 class DifferenceTest < ActiveSupport::TestCase
  def setup
    @params = { catalogue_field: 'body',
                catalogue_value: 'none',
                rvparky_field: 'text',
                rvparky_value: 'none',
                kind: :catalogue_blank }
    @difference = Difference.new(@params)
  end

  test 'validator should be setup properly' do
    assert @difference.valid?
    assert @difference.catalogue_field == @params[:catalogue_field]
    assert @difference.catalogue_value == @params[:catalogue_value]
    assert @difference.rvparky_field == @params[:rvparky_field]
    assert @difference.rvparky_value == @params[:rvparky_value]
    assert @difference.catalogue_blank?
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
    @difference.kind = :rvparky_blank
    assert @difference.valid?
    assert @difference.rvparky_blank?
    assert_not @difference.catalogue_blank?
    assert_not @difference.mismatch?
    assert_not @difference.match?

    @difference.kind = :catalogue_blank
    assert @difference.valid?
    assert_not @difference.rvparky_blank?
    assert @difference.catalogue_blank?
    assert_not @difference.mismatch?
    assert_not @difference.match?

    @difference.kind = :mismatch
    assert @difference.valid?
    assert_not @difference.rvparky_blank?
    assert_not @difference.catalogue_blank?
    assert @difference.mismatch?
    assert_not @difference.match?

    @difference.kind = :match
    assert @difference.valid?
    assert_not @difference.rvparky_blank?
    assert_not @difference.catalogue_blank?
    assert_not @difference.mismatch?
    assert @difference.match?
  end
end