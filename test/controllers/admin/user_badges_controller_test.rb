require "test_helper"

class Admin::UserBadgesControllerTest < ActionDispatch::IntegrationTest
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

    @user = User.create!(
      firstname: "Regular",
      lastname: "User",
      email: "regular@example.com",
      pseudo: "regular_user",
      password: "Password123!",
      role: "user",
      statut: "autre",
      rgpd_consent: true,
      confirmed_at: Time.current
    )

    @badge = Badge.find_or_create_by!(name: "Test Badge") do |b|
      b.category = :special
      b.level = :standard
      b.image_name = "test_badge.png"
      b.description = "A badge for testing"
    end
  end

  test "non-admin should be redirected to root for new" do
    sign_in @user
    get new_admin_user_badge_url
    assert_redirected_to root_path
  end

  test "admin should get new" do
    sign_in @admin
    get new_admin_user_badge_url
    assert_response :success
    assert_select "h1", text: "Gestion des Badges Membres"
  end

  test "admin can assign a badge" do
    sign_in @admin
    assert_difference "UserBadge.count", 1 do
      post admin_user_badges_url, params: { user_id: @user.id, badge_id: @badge.id }
    end
    assert_redirected_to new_admin_user_badge_path
    assert_equal "Le badge '#{@badge.name}' a été attribué à #{@user.pseudo}.", flash[:notice]
  end

  test "admin can search assigned badges" do
    sign_in @admin
    UserBadge.create!(user: @user, badge: @badge)

    # Search with matching query
    get new_admin_user_badge_url, params: { search: "regular" }
    assert_response :success
    assert_select "span.user-email", text: "regular@example.com"

    # Search with non-matching query
    get new_admin_user_badge_url, params: { search: "nomatch" }
    assert_response :success
    assert_select "td", text: "Aucun badge trouvé."
  end

  test "admin can remove a badge" do
    sign_in @admin
    user_badge = UserBadge.create!(user: @user, badge: @badge)

    assert_difference "UserBadge.count", -1 do
      delete admin_user_badge_url(user_badge)
    end
    assert_redirected_to new_admin_user_badge_path
    assert_equal "Le badge '#{@badge.name}' a été retiré avec succès à #{@user.pseudo}.", flash[:notice]
  end

  test "admin can sort assigned badges" do
    sign_in @admin
    
    badge_a = Badge.create!(name: "Alpha Badge", category: :special, level: :standard, image_name: "a.png", description: "A")
    badge_z = Badge.create!(name: "Omega Badge", category: :special, level: :standard, image_name: "z.png", description: "Z")
    
    UserBadge.create!(user: @user, badge: badge_z)
    UserBadge.create!(user: @user, badge: badge_a)

    get new_admin_user_badge_url, params: { sort: "badge", direction: "asc" }
    assert_response :success

    user_badges = assigns(:user_badges)
    assert_equal "Alpha Badge", user_badges.first.badge.name
    assert_equal "Omega Badge", user_badges.second.badge.name
  end
end
