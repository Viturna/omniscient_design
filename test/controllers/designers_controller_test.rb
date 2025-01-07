require "test_helper"

class DesignersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get designers_index_url
    assert_response :success
  end

  test "should get show" do
    get designers_show_url
    assert_response :success
  end

  test "should get new" do
    get designers_new_url
    assert_response :success
  end

  test "should get edit" do
    get designers_edit_url
    assert_response :success
  end
end
