require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in users(:admin)
  end

  test 'can create new user' do
    get new_user_path, params: { user: { email: 'new@email.com',
                                         password: 'foobar',
                                         password_confirmation: 'foobar',
                                         admin: false } }
    assert_response :found
    assert flash[:success].present?
    assert_not flash[:alert].present?
  end

  test 'cannot create invalid user' do
    get new_user_path, params: { user: { email: 'new@email.com',
                                         password: 'foobar',
                                         password_confirmation: 'barfoo',
                                         admin: false } }
    assert_response :success
    assert flash[:alert].present?
    assert_not flash[:success].present?
  end

  test 'can update user' do
    patch user_path(1), params: { user: { admin: true },
                                  commit: 'Update',
                                  id: '1'}
    assert_response :found
    assert_redirected_to user_index_path
    assert flash[:success].present?
    assert_not flash[:alert].present?

    user = User.find(1)
    assert user.admin.present?
    assert_not user.admin.blank?
  end

  test 'cannot update user to invalid state' do
    patch user_path(1), params: { user: { admin: true,
                                          password: 'foobar',
                                          password_confirmation: 'barfoo' },
                                  commit: 'Update',
                                  id: '1'}
    assert_response :found
    assert_redirected_to edit_user_path
    assert_not flash[:success].present?
    assert flash[:alert].present?

    user = User.find(1)
    assert_not user.admin.present?
    assert user.admin.blank?
  end

  test 'can delete users' do
    delete user_path(1), params: { commit: 'Delete User', confirm: '1' }
    assert_response :found
    assert flash[:success].present?
    assert_not flash[:alert].present?
  end

  test 'must confirm user deletion' do
    delete user_path(1), params: { commit: 'Delete User', confirm: '4' }
    assert_response :success
    assert_not flash[:success].present?
    assert flash[:alert].present?
  end

  test 'cannot delete currently logged in user' do
    delete user_path(4), params: { commit: 'Delete User', confirm: '1' }
    assert_response :found
    assert flash[:alert].present?
    assert_not flash[:success].present?
  end

  test 'can update own password' do
    sign_out users(:admin)
    sign_in users(:one)
    patch user_path(1), params: { user: { personal: true,
                                          password: 'foobar',
                                          password_confirmation: 'foobar' },
                                  commit: 'Update',
                                  id: '1'}
    assert_response :found
    assert_redirected_to password_path
    assert flash[:success].present?
    assert_not flash[:alert].present?
  end

  test 'cannot set invalid password' do
    sign_out users(:admin)
    sign_in users(:one)
    patch user_path(1), params: { user: { personal: true,
                                          password: 'foobar',
                                          password_confirmation: 'barfoo' },
                                  commit: 'Update',
                                  id: '1'}
    assert_response :found
    assert_redirected_to password_path
    assert_not flash[:success].present?
    assert flash[:alert].present?
  end

  test 'cannot set self as admin' do
    sign_out users(:admin)
    sign_in users(:one)
    patch user_path(1), params: { user: { personal: true,
                                          admin: true },
                                  commit: 'Update',
                                  id: '1'}
    assert_response :found
    assert_redirected_to password_path
    assert flash[:success].present?
    assert_not flash[:alert].present?

    user = User.find(1)
    assert_not user.admin.present?
    assert user.admin.blank?
  end
end
