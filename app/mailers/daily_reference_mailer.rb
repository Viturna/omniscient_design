class DailyReferenceMailer < ApplicationMailer
  def daily_discovery(user, reference)
    @user = user
    @reference = reference

    if @reference.reference_images.any? && @reference.reference_images.first.file.attached?
      attachments[@reference.reference_images.first.file.filename.to_s] = @reference.reference_images.first.file.download
    end

    mail(to: @user.email, subject: "La réf du jour : #{@reference.nom_reference}")
  end

  def admin_stock_alert(admin_email)
    @admin_email = admin_email
    mail(to: @admin_email, subject: "⚠️ PLUS DE RÉFÉRENCES DISPONIBLES - Omniscient Design")
  end
end
