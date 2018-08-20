require 'test_helper'

class ComparerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get comparer_index_url
    assert_response :success
  end

  test "should get entry" do
    get comparer_entry_url
    assert_response :success
  end

end
