class DailyReferenceMailerPreview < ActionMailer::Preview
  def daily_discovery
    user = User.last
    reference = Reference.where(validation: true).order("RANDOM()").first
    DailyReferenceMailer.daily_discovery(user, reference)
  end
end
