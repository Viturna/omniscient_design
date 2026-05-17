require "test_helper"

class BadgeTest < ActiveSupport::TestCase
  setup do
    @new_user = User.create!(
      firstname: "New",
      lastname: "User",
      email: "new@example.com",
      pseudo: "new_user",
      password: "Password123!",
      role: "user",
      statut: "autre",
      rgpd_consent: true,
      created_at: Time.current
    )
    
    @old_user = User.create!(
      firstname: "Old",
      lastname: "User",
      email: "old@example.com",
      pseudo: "old_user",
      password: "Password123!",
      role: "user",
      statut: "autre",
      rgpd_consent: true,
      created_at: 13.months.ago
    )
  end

  test "should not give seniority badge to new user" do
    service = GamificationService.new(@new_user)
    service.check_seniority
    
    assert_not @new_user.badges.exists?(name: "L'Aaaancien")
  end

  test "should give seniority badge to old user (> 1 year)" do
    service = GamificationService.new(@old_user)
    service.check_seniority
    
    assert @old_user.badges.exists?(name: "L'Aaaancien")
    badge = @old_user.badges.find_by(name: "L'Aaaancien")
    assert_equal "l_aaaancien.png", badge.image_name
    assert_equal "special", badge.category
    assert_equal "standard", badge.level
  end
end
