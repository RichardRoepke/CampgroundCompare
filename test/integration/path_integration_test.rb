require 'test_helper'

class PathIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @empty_get = { new_user_session: :success, new_user_password: :success }
    @user_get = { root: :success, edit_user_password: :found }
    @user_delete = { destroy_user_session: :found }
    @admin_get = { users: :success, new_user: :success, user_index: :success }
  end

  test 'no session paths are valid' do
    @empty_get.each do |route, response|
      get polymorphic_url(route.to_s)
      assert_response response
    end
  end

  test 'user paths are valid' do
    sign_in users(:one)
    @user_get.each do |route, response|
      get polymorphic_url(route.to_s)
      assert_response response
    end

    delete destroy_user_session_path
    assert_response :found
  end

  test 'admin paths are valid' do
    sign_in users(:admin)
    @admin_get.each do |route, response|
      get polymorphic_url(route.to_s)
      assert_response response
    end

    get edit_user_path(1)
    assert_response :success

    get user_path(1)
    assert_response :success

    put user_path(1)
    assert_response :found

    delete user_path(3)
    assert_response :success
  end
end
