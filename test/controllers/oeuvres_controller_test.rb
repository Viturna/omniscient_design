require "test_helper"

class OeuvresControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get oeuvres_index_url
    assert_response :success
  end

  test "should get show" do
    get oeuvres_show_url
    assert_response :success
  end

  test "should get new" do
    get oeuvres_new_url
    assert_response :success
  end

  test "should get edit" do
    get oeuvres_edit_url
    assert_response :success
  end
end
