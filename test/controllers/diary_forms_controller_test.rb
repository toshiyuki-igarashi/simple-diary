require 'test_helper'

class DiaryFormsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_diary_form_url(DiaryForm.first)
    assert_response :redirect
  end

  test "should get update" do
    put diary_form_url(DiaryForm.first)
    assert_response :redirect
  end

end
