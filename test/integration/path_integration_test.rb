require 'test_helper'

class PathIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @empty_get = { new_user_session: :success, new_user_password: :success }
    @user_get = { root: :success, edit_user_password: :found}
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
  end
end
