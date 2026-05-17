require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(
      firstname: "Admin",
      lastname: "User",
      email: "admin@example.com",
      pseudo: "admin_user",
      password: "Password123!",
      role: "admin",
      statut: "autre",
      rgpd_consent: true,
      confirmed_at: Time.current
    )
    @user_subscribed = User.create!(
      firstname: "Subscribed",
      lastname: "User",
      email: "subscribed@example.com",
      pseudo: "sub_user",
      password: "Password123!",
      role: "user",
      statut: "etudiant",
      newsletter: true,
      rgpd_consent: true,
      confirmed_at: Time.current
    )
  end

  test "should get export_newsletter as admin" do
    sign_in @admin
    get export_newsletter_users_url(format: :csv)
    assert_response :success
    assert_equal "text/csv", response.media_type
    assert response.body.include?("subscribed@example.com")
    assert response.body.include?("Subscribed")
  end

  test "should redirect export_newsletter to root for non-admin" do
    sign_in @user_subscribed
    get export_newsletter_users_url(format: :csv)
    assert_redirected_to root_path
  end
end
