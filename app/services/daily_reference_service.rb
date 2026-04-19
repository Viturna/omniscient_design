class DailyReferenceService
  def self.call
    service = new
    service.pick_for_today
    service.send_notifications
  end

  def pick_for_today
    return @daily_ref if (@daily_ref = DailyReference.for_today)

    # Sélectionner une référence validée
    # On évite celles déjà choisies
    sent_reference_ids = DailyReference.pluck(:reference_id)
    reference = Reference.where(validation: true).where.not(id: sent_reference_ids).order("RANDOM()").first
    return nil unless reference

    @daily_ref = DailyReference.create!(reference: reference, date: Date.today)
  end

  def send_notifications
    return unless @daily_ref
    reference = @daily_ref.reference
    title = "La réf du jour"
    message = "Aujourd'hui découvre \"#{reference.nom_reference}\" par #{reference.designers.map(&:nom_designer).join(', ')}"
    link = "/fr/references/#{reference.slug}" # On pourrait utiliser les helpers mais Rails.application.routes.url_helpers est plus sûr ici

    # Notifications Push via le modèle Notification existant
    User.where(daily_reference_push: true).find_each do |user|
      Notification.create!(
        user: user,
        title: title,
        message: message,
        link: link,
        status: :unread,
        notifiable: reference
      )
    end

    # Notifications Email
    User.where(daily_reference_email: true).find_each do |user|
      DailyReferenceMailer.daily_discovery(user, reference).deliver_later
    end
  end
end
