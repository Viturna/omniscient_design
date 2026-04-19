class DailyReferenceMailer < ApplicationMailer
  def daily_discovery(user, reference)
    @user = user
    @reference = reference

    if @reference.reference_images.any?
      image = @reference.reference_images.first.file
      attachments[image.filename.to_s] = image.download
    end

    subject = "La réf du jour : #{@reference.nom_reference}"
    mail(to: @user.email, subject: subject)
  end
end
