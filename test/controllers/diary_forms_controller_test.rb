require 'test_helper'

class DiaryFormsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get diary_forms_edit_url
    assert_response :success
  end

  test "should get update" do
    get diary_forms_update_url
    assert_response :success
  end

end
