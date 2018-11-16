require 'test_helper'

class PendingParkTest < ActiveSupport::TestCase
  def setup
    @params = { uuid: 'body',
                slug: 'none',
                rvparky_id: 'text',
                status: :awaiting_check }
    @park = PendingPark.new(@params)
  end

  test 'pending park uuid must be unique if present' do
    @park.uuid = 'aa'
    assert_not @park.valid?
  end

  test 'pending park slug must be unique if present' do
    @park.slug = 'validslug'
    assert_not @park.valid?
  end

  test 'pending park rvparky_id must be unique if present' do
    @park.rvparky_id = 2
    assert_not @park.valid?
  end

  test 'pending park must have uuid, slug or rvparky_id' do
    new_park = PendingPark.new()
    assert_not new_park.valid?
  end

  test 'pending park must not have uuid matching existing marked park' do
    @park.uuid = 'test'
    assert_not @park.valid?
  end

  test 'pending park must not have slug matching existing marked park' do
    @park.slug = 'newslug'
    assert_not @park.valid?
  end

  test 'pending park must not have rvparky_id matching existing marked park' do
    @park.rvparky_id = 3
    assert_not @park.valid?
  end
end
