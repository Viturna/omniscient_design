require "test_helper"

class DomainesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @domaine = domaines(:one)
  end

  test "should get index" do
    get domaines_url
    assert_response :success
  end

  test "should get new" do
    get new_domaine_url
    assert_response :success
  end

  test "should create domaine" do
    assert_difference("Domaine.count") do
      post domaines_url, params: { domaine: { couleur: @domaine.couleur, domaine: @domaine.domaine, svg: @domaine.svg } }
    end

    assert_redirected_to domaine_url(Domaine.last)
  end

  test "should show domaine" do
    get domaine_url(@domaine)
    assert_response :success
  end

  test "should get edit" do
    get edit_domaine_url(@domaine)
    assert_response :success
  end

  test "should update domaine" do
    patch domaine_url(@domaine), params: { domaine: { couleur: @domaine.couleur, domaine: @domaine.domaine, svg: @domaine.svg } }
    assert_redirected_to domaine_url(@domaine)
  end

  test "should destroy domaine" do
    assert_difference("Domaine.count", -1) do
      delete domaine_url(@domaine)
    end

    assert_redirected_to domaines_url
  end
end
