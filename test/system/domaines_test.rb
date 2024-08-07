require "application_system_test_case"

class DomainesTest < ApplicationSystemTestCase
  setup do
    @domaine = domaines(:one)
  end

  test "visiting the index" do
    visit domaines_url
    assert_selector "h1", text: "Domaines"
  end

  test "should create domaine" do
    visit domaines_url
    click_on "New domaine"

    fill_in "Couleur", with: @domaine.couleur
    fill_in "Domaine", with: @domaine.domaine
    fill_in "Svg", with: @domaine.svg
    click_on "Create Domaine"

    assert_text "Domaine was successfully created"
    click_on "Back"
  end

  test "should update Domaine" do
    visit domaine_url(@domaine)
    click_on "Edit this domaine", match: :first

    fill_in "Couleur", with: @domaine.couleur
    fill_in "Domaine", with: @domaine.domaine
    fill_in "Svg", with: @domaine.svg
    click_on "Update Domaine"

    assert_text "Domaine was successfully updated"
    click_on "Back"
  end

  test "should destroy Domaine" do
    visit domaine_url(@domaine)
    click_on "Destroy this domaine", match: :first

    assert_text "Domaine was successfully destroyed"
  end
end
