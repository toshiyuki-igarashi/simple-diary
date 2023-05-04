require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get login_url
    assert_response :success
  end

  test "should get create" do
    post login_url, params: { session: { email: 'taro@test.com', password: 'taro1234' }}
    assert_response :success
  end

  test "should get destroy" do
    delete logout_url
    assert_response :redirect
  end

end
