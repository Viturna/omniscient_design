class SchoolAdsMailer < ApplicationMailer
  def contact_email(school_name:, email:, message:)
    @school_name = school_name
    @email = email
    @message = message

    mail(
      to: 'contact@omniscientdesign.fr',
      reply_to: @email,
      subject: "Nouvelle demande de partenariat école : #{@school_name}"
    )
  end
end
