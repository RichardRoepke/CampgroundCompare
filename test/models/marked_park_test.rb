require 'test_helper'

class MarkedParkTest < ActiveSupport::TestCase
  def setup
    @params = { name: 'Test Park',
                uuid: 'true',
                slug: 'slug',
                rvparky_id: 11,
                editable: true,
                force_update: 0,
                status: 'NULL' }
    @park = MarkedPark.new(@params)
  end

  test 'marked park was created as valid' do
    assert @park.valid?
  end
end
