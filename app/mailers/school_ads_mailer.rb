class SchoolAdsMailer < ApplicationMailer
  def contact_email(school_name:, email:, message:, contact_record: nil)
    @school_name = school_name
    @email = email
    @message = message
    @contact_record = contact_record

    if @contact_record.present? && @contact_record.images.attached?
      @contact_record.images.each do |img|
        attachments[img.filename.to_s] = img.download
      end
    end

    mail(
      to: 'contact@omniscientdesign.fr',
      reply_to: @email,
      subject: "Nouvelle demande de partenariat école : #{@school_name}"
    )
  end
end
