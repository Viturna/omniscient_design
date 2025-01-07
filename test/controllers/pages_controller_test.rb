require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get add_elements" do
    get pages_add_elements_url
    assert_response :success
  end

  test "should get changelog" do
    get pages_changelog_url
    assert_response :success
  end

  test "should get cookies" do
    get pages_cookies_url
    assert_response :success
  end

  test "should get mentionslegales" do
    get pages_mentionslegales_url
    assert_response :success
  end

  test "should get parrainage" do
    get pages_parrainage_url
    assert_response :success
  end

  test "should get politiquedeconfidentialite" do
    get pages_politiquedeconfidentialite_url
    assert_response :success
  end

  test "should get presentation" do
    get pages_presentation_url
    assert_response :success
  end

  test "should get profil" do
    get pages_profil_url
    assert_response :success
  end

  test "should get search_category" do
    get pages_search_category_url
    assert_response :success
  end

  test "should get search_frise" do
    get pages_search_frise_url
    assert_response :success
  end

  test "should get suivi_references" do
    get pages_suivi_references_url
    assert_response :success
  end

  test "should get validation" do
    get pages_validation_url
    assert_response :success
  end
end
