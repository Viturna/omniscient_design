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

  test "should sort users by establishment name for admin" do
    sign_in @admin
    
    etab_a = Etablissement.create!(name: "Academy A")
    etab_b = Etablissement.create!(name: "School B")

    user_a = User.create!(
      firstname: "Alice",
      lastname: "User",
      email: "alice@example.com",
      pseudo: "alice_user",
      password: "Password123!",
      role: "user",
      statut: "etudiant",
      rgpd_consent: true,
      confirmed_at: Time.current,
      etablissement: etab_b
    )

    user_b = User.create!(
      firstname: "Bob",
      lastname: "User",
      email: "bob@example.com",
      pseudo: "bob_user",
      password: "Password123!",
      role: "user",
      statut: "etudiant",
      rgpd_consent: true,
      confirmed_at: Time.current,
      etablissement: etab_a
    )

    # Sort ASC: etab_a (Academy A) first, then etab_b (School B)
    get users_url, params: { sort: "etablissement_asc" }
    assert_response :success
    
    # We can inspect the order of users in the assigned instance variable
    users = assigns(:paginated_users)
    assert_includes users, user_a
    assert_includes users, user_b
    
    # Filter only those with establishment to compare easily
    sorted_users = users.select { |u| [user_a.id, user_b.id].include?(u.id) }
    assert_equal user_b.id, sorted_users.first.id # etab_a is "Academy A" (Bob)
    assert_equal user_a.id, sorted_users.last.id  # etab_b is "School B" (Alice)
  end
end
